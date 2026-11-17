#!/usr/bin/env bash
#
# lab_up.sh — one-command launcher for the CYB331 Juice Shop pipeline (run inside the VM).
#
# Opens two terminal windows — Juice Shop and Pipeline — starts a LOCAL Juice
# Shop container, runs sqlmap / Dalfox / fuxploider against it, triages the
# output, and opens Juice Shop + the findings report in the browser.
# Run from a WRITABLE copy in your home (not the read-only /mnt share).
#
#   ./scripts/lab_up.sh                  # full run: all three scanners
#   ./scripts/lab_up.sh --only sqlmap    # just one scanner (sqlmap | dalfox | fuxploider)
#   ./scripts/lab_up.sh --stop           # stop + remove the Juice Shop container
#
# If your user isn't in the docker group yet you'll be asked for your sudo
# password in the Juice Shop window.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE="http://localhost:3000"
REPORT="$PROJ/results/report.html"

# docker without sudo only works once the user is in the docker group (needs a re-login).
DOCKER="docker"
docker ps >/dev/null 2>&1 || DOCKER="sudo docker"

if [ "${1:-}" = "--stop" ]; then
  $DOCKER rm -f juice-shop >/dev/null 2>&1 || true
  echo "Juice Shop stopped."; exit 0
fi

ONLY=""
if [ "${1:-}" = "--only" ]; then
  case "${2:-}" in sqlmap|dalfox|fuxploider) ONLY="--only $2";;
    *) echo "ERROR: --only takes sqlmap, dalfox or fuxploider"; exit 1;; esac
fi

# ---- preflight -------------------------------------------------------------
[ -f "$PROJ/pipeline/run_pipeline.py" ] || { echo "ERROR: can't find the project (pipeline/run_pipeline.py missing)."; exit 1; }
case "$PROJ" in
  /mnt/*) echo "ERROR: this is the read-only share ($PROJ) — results can't be written there."
          echo "Copy it to your home first:  cp -r /mnt/cyb331/CYB331_pkg ~/cyb331 && ~/cyb331/scripts/lab_up.sh"; exit 1;;
esac
command -v docker >/dev/null || { echo "ERROR: docker not installed (sudo apt install -y docker.io)."; exit 1; }

missing=()
command -v sqlmap >/dev/null || missing+=("sqlmap")
command -v dalfox >/dev/null || missing+=("dalfox")
{ [ -n "${FUXPLOIDER:-}" ] && [ -f "$FUXPLOIDER" ]; } || command -v fuxploider >/dev/null || missing+=("fuxploider (set FUXPLOIDER)")
[ ${#missing[@]} -eq 0 ] || echo "WARNING: not installed, will be skipped: ${missing[*]}"

chmod +x "$PROJ"/scripts/*.sh "$PROJ"/scanners/*.sh "$PROJ"/target/*.sh 2>/dev/null || true
rm -rf "$PROJ/results"            # fresh report each run

echo "Project: $PROJ"
echo "Target:  $BASE (local only)"

# ---- launch ----------------------------------------------------------------
# Window 1: start Juice Shop, then follow its logs so you can watch the scans land.
T1="cd \"$PROJ\"; D='$DOCKER'; \
  if ! \$D ps --format '{{.Names}}' | grep -q '^juice-shop\$'; then \
    \$D rm -f juice-shop >/dev/null 2>&1; \
    echo 'Starting Juice Shop (first run downloads the image)...'; \
    \$D run -d --name juice-shop -p 3000:3000 bkimminich/juice-shop >/dev/null; \
  fi; \
  echo 'Juice Shop logs (Ctrl+C stops following; the container keeps running):'; \
  \$D logs -f juice-shop; exec bash"

# Window 2: wait for Juice Shop to answer, run scan -> triage, open the report.
T2="cd \"$PROJ\"; echo -n 'Waiting for Juice Shop'; \
  for i in \$(seq 1 180); do curl -s -o /dev/null $BASE/ && break; echo -n .; sleep 1; done; echo; \
  curl -s -o /dev/null $BASE/ || { echo 'ERROR: Juice Shop never came up. Check the Juice Shop window.'; exec bash; }; \
  python3 pipeline/run_pipeline.py --base $BASE $ONLY; \
  xdg-open \"$REPORT\" >/dev/null 2>&1 || true; \
  echo; echo \"Report: $REPORT\"; echo 'Stop Juice Shop with: ./scripts/lab_up.sh --stop'; exec bash"

if command -v gnome-terminal >/dev/null; then
  # Separate windows: multi --tab in one call is broken on modern Ubuntu.
  gnome-terminal --title="1-JuiceShop" -- bash -c "$T1" || true
  sleep 2
  gnome-terminal --title="2-Pipeline"  -- bash -c "$T2" || true
  ( for i in $(seq 1 180); do curl -s -o /dev/null "$BASE/" && break; sleep 1; done
    xdg-open "$BASE" >/dev/null 2>&1 || true ) &
  echo "Two windows opening (Juice Shop / Pipeline). The report opens when the scans finish."
else
  # No GUI terminal (e.g. over SSH): run everything inline.
  bash "$PROJ/target/run_juiceshop.sh"
  python3 "$PROJ/pipeline/run_pipeline.py" --base "$BASE" $ONLY
  echo "Report: $REPORT"
fi
