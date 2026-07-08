#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${1:-$ROOT_DIR/submission.json}"
LOG_PATH="${2:-$ROOT_DIR/submission.log}"

export PATH="$ROOT_DIR/llama.cpp/build/bin:$PATH"
export LLAMA_ARG_N_GPU_LAYERS=0
export LLAMA_ARG_DEVICE=none

echo "running local participant smoke test"
echo "output: $OUTPUT_PATH"
echo "log: $LOG_PATH"

# Avoid interactive terminal input from interfering with the foreground run.
exec </dev/null

"$ROOT_DIR/.venv311/bin/adtc-profiler" run \
  --submission "$ROOT_DIR" \
  --mode participant \
  --output "$OUTPUT_PATH" \
  --skip-accuracy \
  >"$LOG_PATH" 2>&1

echo "done: $OUTPUT_PATH"
