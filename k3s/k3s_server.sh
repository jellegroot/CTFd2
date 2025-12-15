#!/usr/bin/env bash

set -e

# ===== CONFIG =====
DB_NAME="k3s"
DB_USER="cybermeister"
DB_PASS="cyber123"
DB_PORT="33306"
K3S_VERSION=""
LOADBALANCER_IP="192.168.2.24"
# ==================

echo "==> Update system"
sudo apt update

#====== Let no Pods run on server =========
curl -sfL https://get.k3s.io sh -s - server --node-taint CriticalAddonsOnly=true:NoExecute --tls-san ${LOADBALANCER_IP}





curl -sfL https://get.k3s.io |  INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - server \
  --datastore-endpoint="mysql://${DB_USER}:${DB_PASS}@localhost:${DB_PORT}/${DB_NAME}"