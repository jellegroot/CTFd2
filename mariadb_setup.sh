#!/usr/bin/env bash

set -e

# ===== CONFIG =====
DB_NAME="k3s"
DB_USER="cybermeister"
DB_PASS="cyber123"
# ==================

echo "==> Update system"
sudo apt update

echo "==> Install MariaDB client + server"
sudo apt install -y mariadb-server mariadb-client

echo "==> Enable & start service"
if systemctl list-unit-files | grep -q mariadb.service; then
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
elif systemctl list-unit-files | grep -q mysql.service; then
    sudo systemctl enable mysql
    sudo systemctl start mysql
else
    echo "ERROR: MariaDB/MySQL service not found"
    exit 1
fi

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

echo "==> Test login with new user"
mariadb -u${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SHOW TABLES;"

echo "==> DONE"
