#!/bin/bash
set -e

STATIC_IP=$1
ROUTER_IP=$2

if [ -z "$STATIC_IP" ] || [ -z "$ROUTER_IP" ]; then
  echo "Usage: ./set-static-ip.sh <static-ip> <router-ip>"
  exit 1
fi

echo "🧭 Configuring static IP on eth0..."
STATIC_CONFIG="\ninterface eth0\nstatic ip_address=$STATIC_IP/24\nstatic routers=$ROUTER_IP\nstatic domain_name_servers=$ROUTER_IP"
echo -e "$STATIC_CONFIG" | sudo tee -a /etc/dhcpcd.conf > /dev/null
