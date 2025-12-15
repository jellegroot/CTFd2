#!/usr/bin/env bash

set -e

# ===== CONFIG =====
DB_NAME="k3s"
DB_USER="cybermeister"
DB_PASS="cyber123"
DB_PORT="33306"
# ==================

echo "==> Update system"
sudo apt update

echo "==> Install MariaDB client + server"
sudo apt install -y mariadb-server mariadb-client

echo "==> Configure MariaDB port"
CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

if grep -q "^port" "$CONF_FILE"; then
    sudo sed -i "s/^port.*/port = ${DB_PORT}/" "$CONF_FILE"
else
    echo "port = ${DB_PORT}" | sudo tee -a "$CONF_FILE"
fi

echo "==> Enable & start MariaDB service"
sudo systemctl enable mariadb
sudo systemctl restart mariadb

echo "==> Wait for MariaDB to come up"
sleep 3

echo "==> Create database and user"
sudo mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost'
  IDENTIFIED BY '${DB_PASS}';

GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "==> Test connection on custom port"
mariadb -h 127.0.0.1 -P ${DB_PORT} -u${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT 1;"

echo "==> DONE"
echo "Connection string:"
echo "mysql://${DB_USER}:${DB_PASS}@localhost:${DB_PORT}/${DB_NAME}"
