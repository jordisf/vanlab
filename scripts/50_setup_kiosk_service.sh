#!/bin/bash
set -e # Salir si un comando falla
set -u # Tratar las variables no definidas como un error

echo "--> Configurando el entorno de escritorio y Chromium para modo quiosco..."

# ¡IMPORTANTE! Ajusta esta URL a tu página web real.
WEB_PAGE_URL="http://localhost/"
KIOSK_SERVICE_FILE="/etc/systemd/system/kiosk.service"
KIOSK_USER="pi" # Definir el usuario bajo el que se ejecutará el servicio

# 1. Asegurar que Chromium esté instalado (viene por defecto con RPi OS Desktop)
if ! command -v chromium-browser &> /dev/null; then
    echo "ATENCIÓN: Chromium no encontrado. Intentando instalarlo."
    sudo apt update && sudo apt install -y chromium-browser
fi

# 3. Crear el archivo de servicio systemd para el modo quiosco
sudo cp ./configs/kiosk_service/kiosk.service "$KIOSK_SERVICE_FILE" || {
    echo "ERROR: No se pudo copiar el archivo de servicio de quiosco."
    exit 1
}

# 4. Recargar systemd, habilitar e iniciar el servicio
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

echo "--> Servicio de modo quiosco configurado y iniciado."
echo "    La página '$WEB_PAGE_URL' debería aparecer pronto."