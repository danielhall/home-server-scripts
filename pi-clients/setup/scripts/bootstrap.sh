#!/bin/bash
set -e

### --- CONFIGURATION --- ###
TAILSCALE_AUTHKEY="<your-tailscale-authkey>"
EXIT_NODE_IP="<your-exit-node-ip>"

NAS_IP="<your-nas-ip>"
NAS_SHARE="<your-nas-share-name>"
NAS_USER="<nas-username>"
NAS_PASS="<nas-password>"

STATIC_IP="192.168.1.101"
ROUTER_IP="192.168.1.1"
### ---------------------- ###

echo "🔧 Updating system packages..."
sudo apt update && sudo apt install -y \
  docker.io \
  docker-compose \
  git \
  curl \
  cifs-utils

echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Setting up Tailscale..."
chmod +x ./setup-tailscale.sh
./setup-tailscale.sh "$TAILSCALE_AUTHKEY" "$EXIT_NODE_IP"

echo "Setting static IP..."
STATIC_CONFIG="\ninterface eth0\nstatic ip_address=$STATIC_IP/24\nstatic routers=$ROUTER_IP\nstatic domain_name_servers=$ROUTER_IP"
echo -e "$STATIC_CONFIG" | sudo tee -a /etc/dhcpcd.conf > /dev/null

echo "Mounting NAS media share..."
chmod +x ./mount-nas.sh
./mount-nas.sh "$NAS_IP" "$NAS_SHARE" "$NAS_USER" "$NAS_PASS"

echo "Deploying Jellyfin via Docker Compose..."
cd ../docker
docker-compose up -d

TS_NAME=$(tailscale status | grep '100.' | awk '{print $2}')
echo "All done. Jellyfin should be available at http://${STATIC_IP}:8096 and over Tailscale at http://${TS_NAME}:8096"
