#!/usr/bin/env bash
set -e

# ===== CONFIG =====
DB_NAME="k3s"
DB_USER="cybermeister"
DB_PASS="cyber123"
DB_PORT="33306"
K3S_VERSION=""
LOADBALANCER_IP="192.168.2.26"
# ==================

echo "==> Update system"
sudo apt update

echo "==> Install k3s server (single run)"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - server \
  --datastore-endpoint="mysql://${DB_USER}:${DB_PASS}@tcp(127.0.0.1:${DB_PORT})/${DB_NAME}" \
  --node-taint CriticalAddonsOnly=true:NoExecute \
  --tls-san ${LOADBALANCER_IP}

echo "==> DONE"
