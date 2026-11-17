#!/usr/bin/env bash
#
# run_juiceshop.sh — start a LOCAL OWASP Juice Shop instance in Docker.
#
# Juice Shop is an intentionally vulnerable training app. Per the assignment we
# only ever run and test our OWN local instance — never a shared or public one.
#
#   ./run_juiceshop.sh          # start it on http://localhost:3000
#   ./run_juiceshop.sh stop     # stop + remove the container
#
set -euo pipefail

NAME="juice-shop"
PORT="3000"
IMAGE="bkimminich/juice-shop"

if [ "${1:-}" = "stop" ]; then
    docker rm -f "$NAME" >/dev/null 2>&1 || true
    echo "Juice Shop stopped."
    exit 0
fi

command -v docker >/dev/null || { echo "ERROR: docker not installed. Install Docker, then re-run."; exit 1; }

if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
    echo "Juice Shop already running at http://localhost:${PORT}"
    exit 0
fi

docker rm -f "$NAME" >/dev/null 2>&1 || true
echo "Pulling + starting Juice Shop (first run downloads the image)..."
docker run -d --name "$NAME" -p "${PORT}:3000" "$IMAGE" >/dev/null

# wait for it to answer
echo -n "Waiting for Juice Shop to come up"
for i in $(seq 1 60); do
    if curl -s -o /dev/null "http://localhost:${PORT}/"; then
        echo " — up at http://localhost:${PORT}"
        exit 0
    fi
    echo -n "."; sleep 1
done
echo
echo "ERROR: Juice Shop didn't answer on :${PORT} after 60s. Check 'docker logs ${NAME}'."
exit 1
