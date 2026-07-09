#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_LLAMA_BIN_DIR="$ROOT_DIR/llama.cpp/build/bin"
LOCAL_QWEN_MODEL_FALLBACK="$ROOT_DIR/model/Qwen3-4B-Q4_K_M.gguf"

FAILURES=0
WARNINGS=0

ok() {
  echo "[ok] $*"
}

warn() {
  echo "[warn] $*"
  WARNINGS=$((WARNINGS + 1))
}

fail() {
  echo "[fail] $*"
  FAILURES=$((FAILURES + 1))
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    ok "$label: $path"
  else
    fail "$label missing: $path"
  fi
}

require_dir() {
  local path="$1"
  local label="$2"
  if [[ -d "$path" ]]; then
    ok "$label: $path"
  else
    fail "$label missing: $path"
  fi
}

check_port() {
  local port="$1"
  local label="$2"
  if [[ "$port" =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
    ok "$label port looks valid: $port"
  else
    fail "$label port is invalid: $port"
  fi
}

check_positive_int() {
  local value="$1"
  local label="$2"
  if [[ "$value" =~ ^[0-9]+$ ]] && ((value >= 1)); then
    ok "$label looks valid: $value"
  else
    fail "$label must be a positive integer, got: $value"
  fi
}

check_command() {
  local cmd="$1"
  local label="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$label available on PATH: $cmd"
  else
    warn "$label not found on PATH: $cmd"
  fi
}

check_python_min_version() {
  local cmd="$1"
  local label="$2"
  local version
  if ! command -v "$cmd" >/dev/null 2>&1; then
    warn "$label not found on PATH: $cmd"
    return
  fi

  version="$("$cmd" -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' 2>/dev/null || true)"
  if [[ -z "$version" ]]; then
    warn "$label version could not be detected: $cmd"
    return
  fi

  if "$cmd" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)' >/dev/null 2>&1; then
    ok "$label version is compatible (>= 3.11): $version"
  else
    fail "$label version must be >= 3.11, got: $version"
  fi
}

check_gnu_time() {
  if command -v gtime >/dev/null 2>&1 && gtime -v true >/dev/null 2>&1; then
    ok "GNU time available on PATH: gtime"
    return
  fi

  if /usr/bin/time -v true >/dev/null 2>&1; then
    ok "GNU time available at /usr/bin/time"
    return
  fi

  warn "GNU time with '-v' support not found; RSS capture will fail in benchmark scripts"
  warn "on Ubuntu, install it with: sudo apt-get install -y time"
}

echo "Benchmark pre-flight for $ROOT_DIR"
echo

require_file "$ROOT_DIR/benchmark/README.md" "benchmark workflow doc"
require_file "$ROOT_DIR/benchmark/candidates.example.env" "candidate env example"
require_file "$ROOT_DIR/eval/lm_eval/farmhand_na_mcq.yaml" "lm-eval task config"
require_file "$ROOT_DIR/eval/mcq/farmhand_na_mcq_seed.jsonl" "MCQ seed set"
require_file "$ROOT_DIR/scripts/run_candidate_benchmark.sh" "single-model benchmark script"
require_file "$ROOT_DIR/scripts/run_benchmark_pair.sh" "pair benchmark script"
require_file "$ROOT_DIR/scripts/run_lm_eval_gguf_compat.py" "lm-eval gguf compat runner"
require_file "$ROOT_DIR/scripts/summarize_benchmark.py" "benchmark summarizer"
require_dir "$ROOT_DIR/benchmark" "benchmark directory"
require_dir "$ROOT_DIR/eval/mcq" "eval MCQ directory"

if grep -q '^task: farmhand_na_mcq_seed$' "$ROOT_DIR/eval/lm_eval/farmhand_na_mcq.yaml"; then
  ok "lm-eval task name matches benchmark script default"
else
  fail "lm-eval task name does not match expected 'farmhand_na_mcq_seed'"
fi

if grep -q 'validation: eval/mcq/farmhand_na_mcq_seed.jsonl' "$ROOT_DIR/eval/lm_eval/farmhand_na_mcq.yaml"; then
  ok "lm-eval task points at the expected MCQ seed file"
else
  fail "lm-eval task does not point at eval/mcq/farmhand_na_mcq_seed.jsonl"
fi

echo

CANDIDATES_ENV="${1:-$ROOT_DIR/benchmark/candidates.env}"

if [[ -f "$CANDIDATES_ENV" ]]; then
  ok "candidate env file found: $CANDIDATES_ENV"
  set -a
  # shellcheck disable=SC1090
  source "$CANDIDATES_ENV"
  set +a

  : "${QWEN_LABEL:=}"
  : "${QWEN_MODEL:=}"
  : "${QWEN_PORT:=}"
  : "${PHI_LABEL:=}"
  : "${PHI_MODEL:=}"
  : "${PHI_PORT:=}"
  : "${THREADS:=}"
  : "${THREADS_BATCH:=}"
  : "${CTX_SIZE:=}"
  : "${BATCH_SIZE:=}"
  : "${UBATCH_SIZE:=}"
  : "${REPETITIONS:=}"

  if [[ -n "$QWEN_LABEL" ]]; then ok "QWEN_LABEL set: $QWEN_LABEL"; else fail "QWEN_LABEL is empty"; fi
  if [[ -n "$PHI_LABEL" ]]; then
    ok "PHI_LABEL set: $PHI_LABEL"
    PHI_ENABLED=1
  else
    warn "PHI_LABEL is empty; pre-flight will treat this as a Qwen-only first pass"
    PHI_ENABLED=0
  fi

  if [[ -f "$QWEN_MODEL" ]]; then
    ok "Qwen GGUF found: $QWEN_MODEL"
  else
    fail "Qwen GGUF missing: $QWEN_MODEL"
    if [[ -f "$LOCAL_QWEN_MODEL_FALLBACK" ]]; then
      warn "repo-local Qwen smoke-test model exists at: $LOCAL_QWEN_MODEL_FALLBACK"
      warn "for a local macOS smoke test, point QWEN_MODEL there or export a different local candidates env"
    fi
  fi

  check_port "$QWEN_PORT" "Qwen"

  if ((PHI_ENABLED)); then
    if [[ -f "$PHI_MODEL" ]]; then
      ok "Phi GGUF found: $PHI_MODEL"
    else
      fail "Phi GGUF missing: $PHI_MODEL"
    fi

    check_port "$PHI_PORT" "Phi"

    if [[ "$QWEN_PORT" == "$PHI_PORT" ]]; then
      fail "Qwen and Phi ports must be different"
    else
      ok "Qwen and Phi ports are distinct"
    fi
  else
    warn "Phi candidate is not configured; pair benchmark script will not be runnable yet"
  fi

  check_positive_int "$THREADS" "THREADS"
  check_positive_int "$THREADS_BATCH" "THREADS_BATCH"
  check_positive_int "$CTX_SIZE" "CTX_SIZE"
  check_positive_int "$BATCH_SIZE" "BATCH_SIZE"
  check_positive_int "$UBATCH_SIZE" "UBATCH_SIZE"
  check_positive_int "$REPETITIONS" "REPETITIONS"
else
  warn "candidate env file not found: $CANDIDATES_ENV"
  warn "copy benchmark/candidates.example.env to benchmark/candidates.env and fill in the real GGUF paths"
fi

echo

check_command curl "health-check dependency"
check_python_min_version python3 "Python"
check_command git "Git"
check_command cmake "CMake"
check_command pkg-config "pkg-config (needed for OpenBLAS llama.cpp builds)"
check_gnu_time

if python3 -c 'import lm_eval' >/dev/null 2>&1; then
  ok "Python lm_eval package import works"
else
  warn "Python lm_eval package import failed; activate the benchmark virtualenv before running"
fi

LLAMA_BENCH_BIN_VALUE="${LLAMA_BENCH_BIN:-llama-bench}"
LLAMA_SERVER_BIN_VALUE="${LLAMA_SERVER_BIN:-llama-server}"
LM_EVAL_BIN_VALUE="${LM_EVAL_BIN:-$ROOT_DIR/scripts/run_lm_eval_gguf_compat.py}"

check_command "$LLAMA_BENCH_BIN_VALUE" "llama-bench"
check_command "$LLAMA_SERVER_BIN_VALUE" "llama-server"
check_command "$LM_EVAL_BIN_VALUE" "lm-eval compat runner"

if [[ -d "$LOCAL_LLAMA_BIN_DIR" ]]; then
  if [[ ! -x "$LOCAL_LLAMA_BIN_DIR/llama-bench" ]]; then
    warn "repo-local llama-bench binary not found at $LOCAL_LLAMA_BIN_DIR/llama-bench"
  fi
  if [[ ! -x "$LOCAL_LLAMA_BIN_DIR/llama-server" ]]; then
    warn "repo-local llama-server binary not found at $LOCAL_LLAMA_BIN_DIR/llama-server"
  fi
  if [[ -x "$LOCAL_LLAMA_BIN_DIR/llama-bench" || -x "$LOCAL_LLAMA_BIN_DIR/llama-server" ]]; then
    warn "if you built llama.cpp in this repo, export PATH=\"$LOCAL_LLAMA_BIN_DIR:\$PATH\" before running the profiler"
  fi
fi

echo

if ((FAILURES > 0)); then
  echo "Pre-flight failed with $FAILURES issue(s) and $WARNINGS warning(s)."
  exit 1
fi

echo "Pre-flight passed with $WARNINGS warning(s)."
echo "You are clear to spend VM time once the warnings are either resolved or consciously accepted."
