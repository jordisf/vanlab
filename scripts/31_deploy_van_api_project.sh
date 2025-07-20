#!/bin/bash
set -e
set -u

# --- CONFIGURACIÓN INTERNA ---
SOURCE_DIR="/home/pi/vanlab/projects/van-api" # Ruta al directorio del código fuente de la API
BACKEND_PROD_DIR="/opt/van-api"
SOURCE_SCRIPTS_DIR="/home/pi/vanlab/sys_scripts" # Ruta al directorio de scripts fuente
BACKEND_SCRIPTS_DIR="/usr/local/bin/van-api" # Ruta al directorio de scripts de la API
SERVICE_USER="www-data" # Usuario bajo el que Gunicorn correrá

echo "--- Desplegando archivos del Backend API (van-api) ---"
echo "Origen del código: $SOURCE_DIR"
echo "Destino de producción: $BACKEND_PROD_DIR"

# 1. Crear el directorio de producción para el backend si no existe
if [ ! -d "$BACKEND_PROD_DIR" ]; then
    echo "Creando directorio de destino para el backend: $BACKEND_PROD_DIR"
    sudo mkdir -p "$BACKEND_PROD_DIR" || { echo "ERROR: No se pudo crear el directorio de destino del backend."; exit 1; }
fi

# 2. Sincronizar los archivos del código de la API
echo "Sincronizando archivos del código de la API desde '$SOURCE_DIR' a '$BACKEND_PROD_DIR'..."
sudo rsync -av --exclude 'venv/' "$SOURCE_DIR/" "$BACKEND_PROD_DIR/" || { echo "ERROR: Falló la sincronización de archivos del backend."; exit 1; }

# 3. Asegurar permisos correctos para el usuario del servicio
echo "Ajustando permisos de archivos para el usuario del servicio ($SERVICE_USER)..."
sudo chown -R "$SERVICE_USER":"$SERVICE_USER" "$BACKEND_PROD_DIR" || { echo "ERROR: No se pudieron ajustar los permisos."; exit 1; }
sudo chmod -R ugo+rX "$BACKEND_PROD_DIR" || { echo "ERROR: No se pudieron ajustar los permisos (lectura/ejecución)."; exit 1; }

# 1. Crear el directorio de scripts si no existe
if [ ! -d "$BACKEND_SCRIPTS_DIR" ]; then
    echo "Creando directorio de scripts para el backend: $BACKEND_SCRIPTS_DIR"
    sudo mkdir -p "$BACKEND_SCRIPTS_DIR" || { echo "ERROR: No se pudo crear el directorio de scripts del backend."; exit 1; }
fi

# 2. Sincronizar los scripts del backend
echo "Sincronizando scripts del backend desde '$SOURCE_SCRIPTS_DIR' a '$BACKEND_SCRIPTS_DIR'..."
sudo rsync -av "$SOURCE_SCRIPTS_DIR/" "$BACKEND_SCRIPTS_DIR/" || { echo "ERROR: Falló la sincronización de scripts del backend."; exit 1; }

echo "Archivos del Backend API desplegados."