#!/bin/bash
set -e
set -u


# --- CONFIGURACIÓN INTERNA ---
BACKEND_PROD_DIR="/opt/van-api"
VENV_PATH="$BACKEND_PROD_DIR/venv"
SERVICE_USER="www-data" # Usuario bajo el que Gunicorn correrá

echo "--- Configurando environment para Backend API (van-api) ---"
echo "Destino de producción: $BACKEND_PROD_DIR"

# Check if the production directory exists
if [ ! -d "$BACKEND_PROD_DIR" ]; then
    echo "No existe el directorio de producción para el backend van-api: $BACKEND_PROD_DIR"
    exit 1
fi
# Crear y configurar el entorno virtual en el directorio de producción
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

echo "Entorno virtual configurado para la API en $BACKEND_PROD_DIR."