#!/bin/bash
set -euo pipefail

# Move to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v bats &>/dev/null; then
  echo "[ERROR] Bats is not installed. Install it from https://github.com/bats-core/bats-core"
  exit 1
fi

echo "[INFO] Discovering test files..."

test_files=$(find tests -name '*.bats' | sort)

if [[ -z "$test_files" ]]; then
  echo "[WARN] No test files found."
  exit 0
fi

echo "[INFO] Running Bats tests:"
echo "$test_files"

for file in $test_files; do
  echo "========================================"
  echo "Running: $file"
  bats "$file"
done
