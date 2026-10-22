#!/usr/bin/env bash
# Creates .env with random secrets and a best-guess HOST_IP.
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] && { echo ".env already exists - not overwriting"; exit 0; }
cp .env.example .env
ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
sed -i "s|^HOST_IP=.*|HOST_IP=${ip:-127.0.0.1}|" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$(openssl rand -hex 16)|" .env
sed -i "s|^JOIN_KEY=.*|JOIN_KEY=$(openssl rand -hex 32)|" .env
echo "Created .env (HOST_IP=${ip:-127.0.0.1}). Edit it, then set XRAY_VERSION before installing Xray."
