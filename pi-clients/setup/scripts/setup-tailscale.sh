 #!/bin/bash
set -e

TAILSCALE_AUTHKEY=$1
EXIT_NODE=$2

if [ -z "$TAILSCALE_AUTHKEY" ] || [ -z "$EXIT_NODE" ]; then
  echo "Usage: ./setup-tailscale.sh <authkey> <exit-node-IP>"
  exit 1
fi

echo "[*] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "[*] Starting Tailscale..."
sudo systemctl enable --now tailscaled
sudo tailscale up --authkey $TAILSCALE_AUTHKEY --exit-node=$EXIT_NODE --accept-routes
