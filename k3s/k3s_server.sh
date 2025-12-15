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

echo "==> Configure kubeconfig for user"

mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

echo "==> Update kubeconfig server endpoint"
sed -i "s|https://127.0.0.1:6443|https://${LOADBALANCER_IP}:6443|g" ~/.kube/config

echo "==> Installation complete"
echo "kubectl will now connect via https://${LOADBALANCER_IP}:6443"







echo "==> DONE"
