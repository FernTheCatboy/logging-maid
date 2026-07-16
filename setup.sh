#!/usr/bin/env bash
# Run this on the Ubuntu machine, from inside the cloned repo, to install
# dependencies and register the bot as a systemd service.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="discord-log-forwarder"
SERVICE_USER="${SUDO_USER:-$USER}"

cd "$SCRIPT_DIR"

echo "==> Installing system packages"
sudo apt-get update -qq
sudo apt-get install -y python3 python3-venv python3-pip

echo "==> Creating virtual environment"
if [ ! -d venv ]; then
  python3 -m venv venv
fi

echo "==> Installing Python dependencies"
./venv/bin/pip install --upgrade pip -q
./venv/bin/pip install -r requirements.txt -q

if [ ! -f .env ]; then
  echo "==> Creating .env from .env.example"
  cp .env.example .env
  chmod 600 .env
fi

echo "==> Installing systemd service (running as user: $SERVICE_USER)"
sed \
  -e "s|__WORKING_DIR__|$SCRIPT_DIR|g" \
  -e "s|__USER__|$SERVICE_USER|g" \
  discord-log-forwarder.service.template | sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

echo
echo "Setup complete."
echo "1. Edit $SCRIPT_DIR/.env with your bot token and channel IDs (if you haven't already)."
echo "2. Start the bot:   sudo systemctl start $SERVICE_NAME"
echo "3. Watch the logs:  sudo journalctl -u $SERVICE_NAME -f"
