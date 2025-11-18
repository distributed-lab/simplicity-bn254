#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${PWD}/scripts/auxiliary"
MAINFILE="inverse.go"

FP12_INPUT="$1"

echo "=== FP12 BN254 inverse example (gnark-crypto) ==="
echo "Working directory: $WORKDIR"
echo

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ ! -f "go.mod" ]; then
  go mod init auxiliary >/dev/null
fi

if [ ! -f "$MAINFILE" ]; then
  echo "Error: $MAINFILE not found in $WORKDIR"
  exit 1
fi

go mod tidy >/dev/null

echo "Running inverse computation..."
go run "$MAINFILE" "$FP12_INPUT"
