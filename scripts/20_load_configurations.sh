#!/bin/bash
set -e
set -u

# --- Configuración de permisos para scripts ---
echo "www-data ALL=(ALL) NOPASSWD: /usr/local/bin/van-api/*.sh" | sudo tee /etc/sudoers.d/www-data_van-api > /dev/null
sudo chmod 440 /etc/sudoers.d/www-data_van-api

