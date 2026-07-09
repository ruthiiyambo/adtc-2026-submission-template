#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${1:-$ROOT_DIR/submission.json}"
LOG_PATH="${2:-$ROOT_DIR/submission.log}"
LLAMA_BIN_DIR="${LLAMA_BIN_DIR:-$ROOT_DIR/llama.cpp/build/bin}"
PROFILER_BIN="${PROFILER_BIN:-$ROOT_DIR/.venv/bin/adtc-profiler}"
PYTHON_BIN="${PYTHON_BIN:-$ROOT_DIR/.venv/bin/python}"

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -f "$path" ]]; then
    echo "missing $label: $path" >&2
    exit 1
  fi
}

require_exec() {
  local path="$1"
  local label="$2"
  if [[ ! -x "$path" ]]; then
    echo "missing executable for $label: $path" >&2
    exit 1
  fi
}

echo "running x86 VM participant smoke test"
echo "repo:   $ROOT_DIR"
echo "output: $OUTPUT_PATH"
echo "log:    $LOG_PATH"
echo

if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
  echo "warning: this helper is intended for an x86_64 Linux VM; current host is $(uname -s) $(uname -m)" >&2
fi

require_file "$ROOT_DIR/metadata.json" "submission metadata"
require_file "$ROOT_DIR/download_model.sh" "download script"
require_exec "$LLAMA_BIN_DIR/llama-bench" "llama-bench"
require_exec "$LLAMA_BIN_DIR/llama-server" "llama-server"
require_exec "$PROFILER_BIN" "adtc-profiler"
require_exec "$PYTHON_BIN" "python"

export PATH="$LLAMA_BIN_DIR:$PATH"
export LLAMA_ARG_N_GPU_LAYERS=0
export LLAMA_ARG_DEVICE=none

bash "$ROOT_DIR/download_model.sh"

# Avoid interactive terminal input from interfering with the foreground run.
exec </dev/null

"$PROFILER_BIN" run \
  --submission "$ROOT_DIR" \
  --mode participant \
  --output "$OUTPUT_PATH" \
  --skip-accuracy \
  >"$LOG_PATH" 2>&1

"$PYTHON_BIN" - "$OUTPUT_PATH" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

throughput = data["throughput"]["tokens_per_second_generation"]
peak_rss = data["memory"]["peak_rss_mb"]

print(f"throughput.tokens_per_second_generation={throughput}")
print(f"memory.peak_rss_mb={peak_rss}")
PY

echo "done: $OUTPUT_PATH"
