#!/usr/bin/env python3

from __future__ import annotations

import json
import sqlite3
import sys
from pathlib import Path


def parse_gnu_time(path: Path) -> float | None:
    if not path.exists():
        return None
    for line in path.read_text().splitlines():
        if "Maximum resident set size (kbytes):" in line:
            value = int(line.split(":", 1)[1].strip())
            return round(value / 1024, 2)
    return None


def parse_llama_bench_sql(path: Path) -> dict[str, float | int | None]:
    result = {
        "throughput_tps": None,
        "throughput_stddev_tps": None,
        "n_prompt": None,
        "n_gen": None,
    }
    if not path.exists():
        return result

    conn = sqlite3.connect(":memory:")
    try:
        conn.executescript(path.read_text())
        row = conn.execute(
            """
            SELECT n_prompt, n_gen, avg_ts, stddev_ts
            FROM llama_bench
            WHERE n_gen > 0
            ORDER BY test_time DESC
            LIMIT 1
            """
        ).fetchone()
    finally:
        conn.close()

    if row is None:
        return result

    n_prompt, n_gen, avg_ts, stddev_ts = row
    result["n_prompt"] = n_prompt
    result["n_gen"] = n_gen
    result["throughput_tps"] = round(float(avg_ts), 4)
    result["throughput_stddev_tps"] = round(float(stddev_ts), 4)
    return result


def find_lm_eval_results(dir_path: Path) -> Path | None:
    for path in sorted(dir_path.rglob("*.json")):
        try:
            data = json.loads(path.read_text())
        except Exception:
            continue
        if isinstance(data, dict) and "results" in data:
            return path
    return None


def parse_lm_eval(path: Path | None) -> dict[str, float | str | None]:
    result = {
        "mcq_task": None,
        "mcq_accuracy": None,
        "mcq_metric_key": None,
    }
    if path is None:
        return result

    data = json.loads(path.read_text())
    results = data.get("results", {})
    for task_name, metrics in results.items():
        if not isinstance(metrics, dict):
            continue
        for key, value in metrics.items():
            if key.startswith("acc"):
                result["mcq_task"] = task_name
                result["mcq_metric_key"] = key
                result["mcq_accuracy"] = round(float(value), 6)
                return result
    return result


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: summarize_benchmark.py <run_dir>", file=sys.stderr)
        return 1

    run_dir = Path(sys.argv[1]).resolve()
    lm_eval_dir = run_dir / "lm_eval"
    summary = {
        "label": run_dir.name,
        "run_dir": str(run_dir),
        "throughput_peak_rss_mb": parse_gnu_time(run_dir / "llama_bench.time.txt"),
        "lm_eval_peak_rss_mb": parse_gnu_time(run_dir / "lm_eval.time.txt"),
    }
    summary.update(parse_llama_bench_sql(run_dir / "llama_bench.sql"))
    summary.update(parse_lm_eval(find_lm_eval_results(lm_eval_dir)))

    summary_path = run_dir / "summary.json"
    summary_path.write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
