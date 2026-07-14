#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="${HOST:-127.0.0.1}"
DEMO_PORT="${DEMO_PORT:-3000}"
MODEL_PORT="${MODEL_PORT:-8080}"
BACKEND_URL="${BACKEND_URL:-http://$HOST:$MODEL_PORT}"
MODEL_PATH="${MODEL_PATH:-$ROOT_DIR/model/Phi-4-mini-instruct-Q4_K_M.gguf}"
MODEL_NAME="${MODEL_NAME:-Phi-4-mini-instruct-Q4_K_M}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LLAMA_SERVER_BIN="${LLAMA_SERVER_BIN:-$ROOT_DIR/llama.cpp/build/bin/llama-server}"
BACKEND_PID=""

require_cmd_or_exec() {
  local cmd="$1"
  if [[ -x "$cmd" ]]; then
    return 0
  fi

  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  echo "missing required command: $cmd" >&2
  exit 1
}

if [[ ! -x "$LLAMA_SERVER_BIN" ]]; then
  if command -v llama-server >/dev/null 2>&1; then
    LLAMA_SERVER_BIN="$(command -v llama-server)"
  else
    echo "missing llama-server executable. Build llama.cpp first." >&2
    exit 1
  fi
fi

require_cmd_or_exec "$PYTHON_BIN"
require_cmd_or_exec curl

cleanup() {
  if [[ -n "$BACKEND_PID" ]] && kill -0 "$BACKEND_PID" >/dev/null 2>&1; then
    kill "$BACKEND_PID" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT INT TERM

cd "$ROOT_DIR"

echo "starting FarmHand NA local demo"
echo "repo:      $ROOT_DIR"
echo "demo url:  http://$HOST:$DEMO_PORT"
echo "backend:   $BACKEND_URL"
echo "model:     $MODEL_PATH"
echo

bash "$ROOT_DIR/download_model.sh"

if curl -fsS "$BACKEND_URL/health" >/dev/null 2>&1; then
  echo "reusing existing llama-server at $BACKEND_URL"
else
  if [[ ! -f "$MODEL_PATH" ]]; then
    echo "model file not found: $MODEL_PATH" >&2
    exit 1
  fi

  BACKEND_LOG="$(mktemp "${TMPDIR:-/tmp}/farmhand-llama-server.XXXXXX.log")"
  echo "starting llama-server in the background"
  echo "backend log: $BACKEND_LOG"

  "$LLAMA_SERVER_BIN" \
    -m "$MODEL_PATH" \
    --port "$MODEL_PORT" \
    >"$BACKEND_LOG" 2>&1 &
  BACKEND_PID="$!"

  for _ in $(seq 1 90); do
    if curl -fsS "$BACKEND_URL/health" >/dev/null 2>&1; then
      echo "llama-server is ready"
      break
    fi

    if ! kill -0 "$BACKEND_PID" >/dev/null 2>&1; then
      echo "llama-server exited before becoming ready" >&2
      tail -n 40 "$BACKEND_LOG" >&2 || true
      exit 1
    fi

    sleep 1
  done

  if ! curl -fsS "$BACKEND_URL/health" >/dev/null 2>&1; then
    echo "llama-server did not become ready in time" >&2
    tail -n 40 "$BACKEND_LOG" >&2 || true
    exit 1
  fi
fi

"$PYTHON_BIN" "$ROOT_DIR/scripts/run_local_demo.py" \
  --host "$HOST" \
  --port "$DEMO_PORT" \
  --backend "$BACKEND_URL" \
  --model-name "$MODEL_NAME"
