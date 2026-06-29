#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <candidates_env> <output_root>" >&2
  exit 1
fi

CANDIDATES_ENV="$1"
OUTPUT_ROOT="$2"

if [[ ! -f "$CANDIDATES_ENV" ]]; then
  echo "missing env file: $CANDIDATES_ENV" >&2
  exit 1
fi

set -a
source "$CANDIDATES_ENV"
set +a

mkdir -p "$OUTPUT_ROOT"

bash scripts/run_candidate_benchmark.sh "$QWEN_LABEL" "$QWEN_MODEL" "$QWEN_PORT" "$OUTPUT_ROOT"
bash scripts/run_candidate_benchmark.sh "$PHI_LABEL" "$PHI_MODEL" "$PHI_PORT" "$OUTPUT_ROOT"

echo "pair benchmark complete. Summaries:"
find "$OUTPUT_ROOT" -maxdepth 2 -name summary.json | sort
