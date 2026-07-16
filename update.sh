#!/usr/bin/env bash
# Pull the latest code, refresh dependencies, and restart the running service.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="discord-log-forwarder"

cd "$SCRIPT_DIR"

echo "==> Pulling latest changes"
git pull

echo "==> Updating dependencies"
./venv/bin/pip install -r requirements.txt -q

echo "==> Restarting service"
sudo systemctl restart "$SERVICE_NAME"

echo "Done. Tail logs with: sudo journalctl -u $SERVICE_NAME -f"
