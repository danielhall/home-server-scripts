#!/bin/bash
set -e

NAS_IP=$1
NAS_SHARE=$2
MOUNT_DIR="/mnt/media"
USERNAME=$3
PASSWORD=$4

if [ -z "$NAS_IP" ] || [ -z "$NAS_SHARE" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  echo "Usage: ./mount-nas.sh <nas-ip> <share-name> <username> <password>"
  exit 1
fi

echo "[*] Installing CIFS utils..."
sudo apt-get update
sudo apt-get install -y cifs-utils

echo "[*] Creating mount point..."
sudo mkdir -p $MOUNT_DIR

echo "[*] Mounting NAS share..."
echo "//$NAS_IP/$NAS_SHARE $MOUNT_DIR cifs username=$USERNAME,password=$PASSWORD,uid=1000,gid=1000,iocharset=utf8 0 0" | sudo tee -a /etc/fstab

sudo mount -a
