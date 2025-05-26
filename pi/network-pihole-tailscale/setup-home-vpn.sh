#!/bin/bash

set -e

# === CONFIGURATION ===
LAN_IFACE="wlan0"  # or eth0 if wired
SUBNET="192.168.68.0/24"

echo "=== Updating system..."
sudo apt update && sudo apt upgrade -y

# === Install Pi-hole ===
echo "=== Installing Pi-hole..."
curl -sSL https://install.pi-hole.net | bash

# === Install Tailscale ===
echo "=== Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "=== Starting and configuring Tailscale (with exit node support)..."
sudo tailscale up \
  --advertise-routes=$SUBNET \
  --advertise-exit-node \
  --exit-node-allow-lan-access \
  --accept-dns=false \
  --snat-subnet-routes \
  --ssh

# === Enable IP forwarding ===
echo "=== Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# === iptables for routing Tailscale traffic to LAN ===
echo "=== Applying iptables rules..."
sudo iptables -t nat -A POSTROUTING -s 100.64.0.0/10 -o $LAN_IFACE -j MASQUERADE
sudo iptables -A FORWARD -i tailscale0 -o $LAN_IFACE -j ACCEPT
sudo iptables -A FORWARD -i $LAN_IFACE -o tailscale0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# === Reinstall and enable Lighttpd for Pi-hole UI ===
sudo apt install --reinstall lighttpd -y
sudo lighty-enable-mod fastcgi fastcgi-php
sudo systemctl restart lighttpd

# === Remove port override if present ===
sudo sed -i '/^BLOCKINGPORT/d' /etc/pihole/pihole-FTL.conf
sudo sed -i '/^WEB_PORT/d' /etc/pihole/setupVars.conf
sudo systemctl restart pihole-FTL

# === Optional: Persist iptables rules ===
read -p "Do you want to persist iptables rules across reboot? (y/n): " persist
if [[ "$persist" =~ ^[Yy]$ ]]; then
  sudo apt install -y iptables-persistent
  sudo netfilter-persistent save
fi

echo "Setup complete: Pi-hole running, Tailscale VPN + exit node enabled."
