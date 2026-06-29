#!/usr/bin/env bash
# Download your model weight file.
#
# Rules:
#   - Must be idempotent (safe to run multiple times).
#   - Must download without any credentials (public URL only).
#   - The output path must match `_runtime.model_path` in metadata.json.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIR="$HERE/model"
MODEL_FILE_NAME="FarmHand-NA-TODO-Q4_K_M.gguf"
MODEL_FILE="$MODEL_DIR/$MODEL_FILE_NAME"

# Set this to the final public, ungated GGUF URL once the winning model is chosen.
# The downloaded filename must stay in sync with metadata.json -> _runtime.model_path.
MODEL_URL=""

mkdir -p "$MODEL_DIR"

if [[ -f "$MODEL_FILE" ]]; then
  echo "model already present at $MODEL_FILE — skipping download"
  exit 0
fi

if [[ -z "$MODEL_URL" ]]; then
  echo "error: MODEL_URL is empty." >&2
  echo "edit download_model.sh and set MODEL_URL to the final public GGUF file" >&2
  echo "before submission, make sure the filename also matches metadata.json" >&2
  exit 1
fi

echo "downloading $MODEL_URL → $MODEL_FILE…"

if command -v curl > /dev/null 2>&1; then
  curl -L --fail --progress-bar -o "$MODEL_FILE.partial" "$MODEL_URL"
elif command -v wget > /dev/null 2>&1; then
  wget --show-progress -O "$MODEL_FILE.partial" "$MODEL_URL"
else
  echo "error: neither curl nor wget found" >&2
  exit 1
fi

mv "$MODEL_FILE.partial" "$MODEL_FILE"
echo "done: $MODEL_FILE"
