#!/usr/bin/env bash
#
# run_fuxploider.sh — file-upload scan of local Juice Shop with fuxploider.
#
# fuxploider probes an upload form for which file types/extensions it wrongly
# accepts. Juice Shop's upload endpoints (complaint upload, profile image) are
# SPA-driven, so the exact URL/field usually needs tuning — that's Aerin's
# branch work. This wrapper keeps the invocation in one place.
#
#   ./run_fuxploider.sh [upload_url]
#   default upload URL: http://localhost:3000/file-upload
#
set -euo pipefail

UPLOAD_URL="${1:-http://localhost:3000/file-upload}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/results"
mkdir -p "$OUT"

# fuxploider is usually run as a cloned repo (python3 fuxploider.py ...). Allow
# either a PATH-installed `fuxploider` or a FUXPLOIDER env var pointing at the script.
FUX="${FUXPLOIDER:-fuxploider}"
if ! command -v "$FUX" >/dev/null 2>&1 && [ ! -f "$FUX" ]; then
    echo "ERROR: fuxploider not found. Install it (git clone https://github.com/almandin/fuxploider)"
    echo "       then set FUXPLOIDER=/path/to/fuxploider.py, or put it on PATH."
    exit 2
fi

echo "[fuxploider] probing upload at $UPLOAD_URL"
# --not-regex: text that marks a REJECTED upload (tune per target).
if [ -f "$FUX" ]; then
    python3 "$FUX" --url "$UPLOAD_URL" --not-regex "was blocked|not allowed|error" --skip-recon \
        2>&1 | tee "$OUT/fuxploider.txt" || true
else
    "$FUX" --url "$UPLOAD_URL" --not-regex "was blocked|not allowed|error" --skip-recon \
        2>&1 | tee "$OUT/fuxploider.txt" || true
fi

echo "[fuxploider] raw output -> results/fuxploider.txt"
