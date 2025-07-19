#!/bin/bash
set -e
set -u

echo "--> Desplegando archivos web a /var/www/html/van-webui/..."

SOURCE_PATH="/home/pi/vanlab/projects/van-webui/www" # Ruta de tu proyecto clonado
DEST_PATH="/var/www/html/van-webui/www"          # Ruta donde Nginx servirá los archivos

# Crear el directorio de destino si no existe
sudo mkdir -p "$DEST_PATH"

# Copiar los archivos (usamos rsync para ser más eficiente en futuras copias)
# -a: modo archivo (preserva permisos, timestamps, etc.)
# --delete: elimina archivos en DEST_PATH que no están en SOURCE_PATH
sudo rsync -av --delete "$SOURCE_PATH/" "$DEST_PATH/"

# Ajustar permisos para Nginx (usuario www-data)
# Dar propiedad al usuario pi y grupo www-data para que pi pueda editar y www-data leer
sudo chown -R pi:www-data "$DEST_PATH"
# Directorios: lectura/escritura/ejecución para owner, lectura/ejecución para grupo y otros
sudo chmod -R 755 "$DEST_PATH"
# Archivos: lectura para todos (el 755 anterior ya cubre esto, pero a veces el umask puede interferir)
sudo find "$DEST_PATH" -type f -exec sudo chmod a+r {} +

echo "--> Archivos web desplegados y permisos ajustados en $DEST_PATH"