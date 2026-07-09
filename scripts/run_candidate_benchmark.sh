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
LLAMA_PERPLEXITY_BIN="${LLAMA_PERPLEXITY_BIN:-llama-perplexity}"
TIME_BIN="${TIME_BIN:-}"
THREADS="${THREADS:-4}"
CTX_SIZE="${CTX_SIZE:-2048}"
BATCH_SIZE="${BATCH_SIZE:-2048}"
UBATCH_SIZE="${UBATCH_SIZE:-512}"
REPETITIONS="${REPETITIONS:-5}"
MCQ_SEED_JSONL="${MCQ_SEED_JSONL:-eval/mcq/farmhand_na_mcq_seed.jsonl}"
MCQ_CTX_SIZE="${MCQ_CTX_SIZE:-512}"
MCQ_BATCH_SIZE="${MCQ_BATCH_SIZE:-512}"
MCQ_UBATCH_SIZE="${MCQ_UBATCH_SIZE:-128}"
MCQ_PARALLEL="${MCQ_PARALLEL:-4}"

RUN_DIR="$OUTPUT_ROOT/$LABEL"
LLAMA_BENCH_SQL="$RUN_DIR/llama_bench.sql"
LLAMA_BENCH_TIME="$RUN_DIR/llama_bench.time.txt"
MCQ_EVAL_TIME="$RUN_DIR/mcq_eval.time.txt"
MCQ_EVAL_STDOUT="$RUN_DIR/mcq_eval.stdout.txt"
MCQ_BINARY="$RUN_DIR/farmhand_na_mcq_seed.bin"
MCQ_PREPARE_LOG="$RUN_DIR/mcq_eval.prepare.txt"

mkdir -p "$RUN_DIR"

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

if [[ ! -f "$MCQ_SEED_JSONL" ]]; then
  echo "MCQ seed file not found: $MCQ_SEED_JSONL" >&2
  exit 1
fi

require_command "$LLAMA_BENCH_BIN" "llama-bench" || exit 1
require_command "$LLAMA_PERPLEXITY_BIN" "llama-perplexity" || exit 1
pick_time_bin || exit 1

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

echo "[$LABEL] building native multiple-choice task file"
python3 "$ROOT_DIR/scripts/build_llama_multiple_choice.py" \
  "$MCQ_SEED_JSONL" \
  "$MCQ_BINARY" \
  >"$MCQ_PREPARE_LOG"

echo "[$LABEL] running native MCQ scorer"
"$TIME_BIN" -v -o "$MCQ_EVAL_TIME" \
  "$LLAMA_PERPLEXITY_BIN" \
  -m "$MODEL_PATH" \
  -t "$THREADS" \
  -c "$MCQ_CTX_SIZE" \
  -b "$MCQ_BATCH_SIZE" \
  -ub "$MCQ_UBATCH_SIZE" \
  -np "$MCQ_PARALLEL" \
  --multiple-choice \
  -bf "$MCQ_BINARY" \
  -ngl 0 \
  -dev none \
  >"$MCQ_EVAL_STDOUT" 2>&1

python3 scripts/summarize_benchmark.py "$RUN_DIR"
echo "[$LABEL] done -> $RUN_DIR"
