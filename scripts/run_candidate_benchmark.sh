#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 4 ]]; then
  echo "usage: $0 <label> <model_path> <port> <output_root>" >&2
  exit 1
fi

LABEL="$1"
MODEL_PATH="$2"
PORT="$3"
OUTPUT_ROOT="$4"

LLAMA_BENCH_BIN="${LLAMA_BENCH_BIN:-llama-bench}"
LLAMA_SERVER_BIN="${LLAMA_SERVER_BIN:-llama-server}"
LM_EVAL_BIN="${LM_EVAL_BIN:-$ROOT_DIR/scripts/run_lm_eval_gguf_compat.py}"
TIME_BIN="${TIME_BIN:-}"
THREADS="${THREADS:-4}"
THREADS_BATCH="${THREADS_BATCH:-4}"
CTX_SIZE="${CTX_SIZE:-2048}"
BATCH_SIZE="${BATCH_SIZE:-2048}"
UBATCH_SIZE="${UBATCH_SIZE:-512}"
REPETITIONS="${REPETITIONS:-5}"
TASK_NAME="${TASK_NAME:-farmhand_na_mcq_seed}"
INCLUDE_PATH="${INCLUDE_PATH:-eval/lm_eval}"

RUN_DIR="$OUTPUT_ROOT/$LABEL"
LM_EVAL_DIR="$RUN_DIR/lm_eval"
LLAMA_BENCH_SQL="$RUN_DIR/llama_bench.sql"
LLAMA_BENCH_TIME="$RUN_DIR/llama_bench.time.txt"
LLAMA_SERVER_LOG="$RUN_DIR/llama_server.log"
LM_EVAL_TIME="$RUN_DIR/lm_eval.time.txt"

mkdir -p "$RUN_DIR" "$LM_EVAL_DIR"

pick_time_bin() {
  if [[ -n "$TIME_BIN" ]]; then
    if "$TIME_BIN" -v true >/dev/null 2>&1; then
      return 0
    fi
    echo "TIME_BIN is set to '$TIME_BIN', but it does not support 'time -v'." >&2
    echo "Use GNU time. On Ubuntu this is usually /usr/bin/time. On macOS install it with 'brew install gnu-time' and export TIME_BIN=gtime." >&2
    return 1
  fi

  if command -v gtime >/dev/null 2>&1 && gtime -v true >/dev/null 2>&1; then
    TIME_BIN="gtime"
    return 0
  fi

  if /usr/bin/time -v true >/dev/null 2>&1; then
    TIME_BIN="/usr/bin/time"
    return 0
  fi

  echo "GNU time with '-v' support is required for RSS capture." >&2
  echo "On Ubuntu, install the 'time' package if needed. On macOS, run 'brew install gnu-time' and export TIME_BIN=gtime." >&2
  echo "ADTC-comparable numbers still need an x86 Ubuntu machine." >&2
  return 1
}

require_command() {
  local cmd="$1"
  local label="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing required command for $label: $cmd" >&2
    return 1
  fi
}

if [[ ! -f "$MODEL_PATH" ]]; then
  echo "model file not found: $MODEL_PATH" >&2
  echo "Replace the placeholder path with the real GGUF location before running the benchmark." >&2
  exit 1
fi

require_command "$LLAMA_BENCH_BIN" "llama-bench" || exit 1
require_command "$LLAMA_SERVER_BIN" "llama-server" || exit 1
require_command "$LM_EVAL_BIN" "lm-eval" || exit 1
pick_time_bin || exit 1

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT

echo "[$LABEL] running llama-bench"
"$TIME_BIN" -v \
  "$LLAMA_BENCH_BIN" \
  -m "$MODEL_PATH" \
  -p 512 \
  -n 128 \
  -r "$REPETITIONS" \
  -t "$THREADS" \
  -b "$BATCH_SIZE" \
  -ub "$UBATCH_SIZE" \
  -ngl 0 \
  -dev none \
  -o sql \
  >"$LLAMA_BENCH_SQL" 2>"$LLAMA_BENCH_TIME"

echo "[$LABEL] starting llama-server on port $PORT"
"$LLAMA_SERVER_BIN" \
  -m "$MODEL_PATH" \
  -t "$THREADS" \
  -tb "$THREADS_BATCH" \
  -c "$CTX_SIZE" \
  -b "$BATCH_SIZE" \
  -ub "$UBATCH_SIZE" \
  -ngl 0 \
  -dev none \
  --host 127.0.0.1 \
  --port "$PORT" \
  >"$LLAMA_SERVER_LOG" 2>&1 &
SERVER_PID="$!"

for _ in $(seq 1 180); do
  if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
  echo "[$LABEL] llama-server did not become healthy in time" >&2
  exit 1
fi

echo "[$LABEL] running lm-eval"
"$TIME_BIN" -v \
  "$LM_EVAL_BIN" run \
  --model gguf \
  --model_args "base_url=http://127.0.0.1:$PORT" \
  --tasks "$TASK_NAME" \
  --include_path "$INCLUDE_PATH" \
  --device cpu \
  --batch_size 1 \
  --output_path "$LM_EVAL_DIR" \
  --log_samples \
  >"$RUN_DIR/lm_eval.stdout.txt" 2>"$LM_EVAL_TIME"

cleanup
unset SERVER_PID

python3 scripts/summarize_benchmark.py "$RUN_DIR"
echo "[$LABEL] done -> $RUN_DIR"
