#!/usr/bin/env python3

from __future__ import annotations

import json
import struct
import sys
from pathlib import Path


def pack_u32(value: int) -> bytes:
    return struct.pack("<I", value)


def pack_i32(value: int) -> bytes:
    return struct.pack("<i", value)


def pack_string(value: str) -> bytes:
    data = value.encode("utf-8")
    return pack_u32(len(data)) + data


def build_task_blob(question: str, choices: list[str], gold: int) -> bytes:
    if not question.strip():
        raise ValueError("question is empty")
    if not choices:
        raise ValueError("choices list is empty")
    if not 0 <= gold < len(choices):
        raise ValueError(f"gold index {gold} is out of range for {len(choices)} choices")

    blob = bytearray()
    blob.extend(pack_string(question))

    # mc1: exactly one correct answer
    blob.extend(pack_u32(len(choices)))
    for choice in choices:
        if not choice.strip():
            raise ValueError("choice is empty")
        blob.extend(pack_string(choice))
    for idx in range(len(choices)):
        blob.extend(pack_i32(1 if idx == gold else 0))

    # mc2: unused in this repo for now
    blob.extend(pack_u32(0))

    return bytes(blob)


def load_tasks(path: Path) -> list[bytes]:
    tasks: list[bytes] = []
    for lineno, raw_line in enumerate(path.read_text().splitlines(), start=1):
        line = raw_line.strip()
        if not line:
            continue
        data = json.loads(line)
        question = data["question"]
        choices = data["choices"]
        gold = int(data["gold"])
        if not isinstance(question, str):
            raise TypeError(f"line {lineno}: question must be a string")
        if not isinstance(choices, list) or not all(isinstance(choice, str) for choice in choices):
            raise TypeError(f"line {lineno}: choices must be a list of strings")
        tasks.append(build_task_blob(question, choices, gold))

    if not tasks:
        raise ValueError(f"no tasks found in {path}")

    return tasks


def write_output(tasks: list[bytes], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    header_size = 4 + 4 * len(tasks)
    positions: list[int] = []
    offset = header_size
    for task in tasks:
        positions.append(offset)
        offset += len(task)

    with output_path.open("wb") as fh:
        fh.write(pack_u32(len(tasks)))
        for pos in positions:
            fh.write(pack_u32(pos))
        for task in tasks:
            fh.write(task)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: build_llama_multiple_choice.py <input_jsonl> <output_bin>", file=sys.stderr)
        return 1

    input_path = Path(sys.argv[1]).resolve()
    output_path = Path(sys.argv[2]).resolve()

    tasks = load_tasks(input_path)
    write_output(tasks, output_path)

    print(f"wrote {len(tasks)} tasks to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
