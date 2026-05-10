#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_ZIP="$SCRIPT_DIR/plan-view.zip"
STAGE_ROOT="$SCRIPT_DIR/.pack-tmp"
STAGE_DIR="$STAGE_ROOT/package"

require_path() {
  local path="$1"
  if [ ! -e "$path" ]; then
    echo "Missing required path: $path" >&2
    exit 1
  fi
}

require_path "$SCRIPT_DIR/server.py"
require_path "$SCRIPT_DIR/index.html"
require_path "$SCRIPT_DIR/res"

if ! command -v zip >/dev/null 2>&1; then
  echo "zip command not found. Please install zip and try again." >&2
  exit 1
fi

if [ -e "$OUTPUT_ZIP" ]; then
  printf 'plan-view.zip already exists. Overwrite? [y/N] '
  read -r answer
  case "$answer" in
    y|Y)
      rm -f "$OUTPUT_ZIP"
      ;;
    *)
      echo "Cancelled."
      exit 0
      ;;
  esac
fi

rm -rf "$STAGE_ROOT"
mkdir -p "$STAGE_DIR"

cleanup() {
  rm -rf "$STAGE_ROOT"
}

trap cleanup EXIT

cp "$SCRIPT_DIR/server.py" "$STAGE_DIR/"
cp "$SCRIPT_DIR/index.html" "$STAGE_DIR/"
cp -R "$SCRIPT_DIR/res" "$STAGE_DIR/"

(
  cd "$STAGE_DIR"
  zip -rq "$OUTPUT_ZIP" .
)

echo "Created $OUTPUT_ZIP"
