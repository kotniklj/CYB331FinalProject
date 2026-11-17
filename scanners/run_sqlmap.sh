#!/usr/bin/env bash
#
# run_sqlmap.sh — SQL-injection scan of local Juice Shop with sqlmap.
#
# Targets Juice Shop's login endpoint, whose `email` field is the classic
# SQLi (`' OR 1=1--`). Raw output is saved for the triage step.
#
#   ./run_sqlmap.sh [base_url]      # default http://localhost:3000
#
set -euo pipefail

BASE="${1:-http://localhost:3000}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/results"
mkdir -p "$OUT/sqlmap"

command -v sqlmap >/dev/null || { echo "ERROR: sqlmap not installed."; exit 2; }

echo "[sqlmap] scanning $BASE/rest/user/login (param: email)"
# --batch: no prompts. --flush-session: fresh run each time.
sqlmap -u "$BASE/rest/user/login" \
    --data='{"email":"test@test.com","password":"test"}' \
    --headers="Content-Type: application/json" \
    -p email \
    --ignore-code=401 \
    --batch --flush-session --level=5 --risk=3 --dbms=sqlite \
    --output-dir="$OUT/sqlmap" \
    2>&1 | tee "$OUT/sqlmap.txt"

echo "[sqlmap] raw output -> results/sqlmap.txt"
