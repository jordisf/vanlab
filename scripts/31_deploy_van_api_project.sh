#!/bin/bash
set -e
set -u


# --- CONFIGURACIÓN INTERNA ---
SOURCE_DIR="/home/pi/vanlab/projects/van-api" # Ruta al directorio del código fuente de la API
BACKEND_PROD_DIR="/opt/van-api"
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

# 4. Crear y configurar el entorno virtual en el directorio de producción
echo "Configurando entorno virtual para la API en $BACKEND_PROD_DIR..."
pushd "$BACKEND_PROD_DIR" > /dev/null # Moverse al directorio de producción de la API

if [ ! -d "venv" ]; then
    echo "Entorno virtual no encontrado en $BACKEND_PROD_DIR, creando uno nuevo..."
    sudo python3 -m venv venv || { echo "ERROR: No se pudo crear el entorno virtual de la API."; popd > /dev/null; exit 1; }
fi
source venv/bin/activate || { echo "ERROR: No se pudo activar el entorno virtual de la API."; popd > /dev/null; exit 1; }

echo "Instalando dependencias de Python para la API desde requirements.txt..."
sudo -u "$SERVICE_USER" "$VENV_PATH/bin/pip" install --upgrade pip || { echo "ERROR: Falló la actualización de pip en el entorno virtual."; exit 1; }
sudo -u "$SERVICE_USER" "$VENV_PATH/bin/pip" install -r "$BACKEND_PROD_DIR/requirements.txt" || { echo "ERROR: Falló la instalación de dependencias de Python para la API."; exit 1; }


deactivate # Desactivar el entorno virtual
popd > /dev/null # Volver al directorio original

echo "Archivos del Backend API desplegados y entorno virtual configurado."