#!/usr/bin/env bash
#
# run_dalfox.sh — XSS scan of local Juice Shop with Dalfox.
#
# Points Dalfox at the product-search parameter. Juice Shop has several XSS
# issues (some DOM-based); the search reflection is the most scanner-friendly
# starting point. Tuning the endpoint list is Liam's branch work.
#
#   ./run_dalfox.sh [base_url]     # default http://localhost:3000
#
set -euo pipefail

BASE="${1:-http://localhost:3000}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/results"
mkdir -p "$OUT"

command -v dalfox >/dev/null || { echo "ERROR: dalfox not installed."; exit 2; }

echo "[dalfox] scanning $BASE search parameter for XSS"
dalfox url "$BASE/rest/products/search?q=test" \
    --format json \
    -o "$OUT/dalfox.json" \
    2>&1 | tee "$OUT/dalfox.txt"

echo "[dalfox] raw output -> results/dalfox.txt (+ dalfox.json)"
