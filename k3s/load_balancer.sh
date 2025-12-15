#!/usr/bin/env bash

set -e

# ===== CONFIG =====
LB_PORT=6443
K3S_SERVER_1="192.168.2.24"
K3S_SERVER_2=""   # leeg laten als je maar 1 server hebt
CONF_FILE="/etc/nginx/nginx.conf"
# ==================

echo "==> Install nginx"
sudo apt update
sudo apt install -y nginx-full

echo "==> Build upstream config"
UPSTREAM="    server ${K3S_SERVER_1}:${LB_PORT};"

if [ -n "${K3S_SERVER_2}" ]; then
    UPSTREAM="${UPSTREAM}
    server ${K3S_SERVER_2}:${LB_PORT};"
fi

echo "==> Write nginx config"
sudo tee ${CONF_FILE} > /dev/null <<EOF
load_module modules/ngx_stream_module.so;

user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {}

stream {
    upstream k3s_servers {
${UPSTREAM}
    }

    server {
        listen ${LB_PORT};
        proxy_pass k3s_servers;
    }
}
EOF

echo "==> Test nginx config"
sudo nginx -t

echo "==> Enable & restart nginx"
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "==> Open firewall (if ufw enabled)"
sudo ufw allow ${LB_PORT}/tcp || true

echo "==> DONE"
echo "k3s load balancer active on port ${LB_PORT}"
