#!/bin/bash
set -e # Salir si un comando falla
set -u # Tratar las variables no definidas como un error

echo "--> Configurando el screen manager..."

SCREEN_MANAGER_SERVICE_FILE="/etc/systemd/system/screen_manager.service"

# 3. Crear el archivo de servicio systemd para el screen manager
sudo cp ./configs/screen_manager_service/screen_manager.service "$SCREEN_MANAGER_SERVICE_FILE" || {
    echo "ERROR: No se pudo copiar el archivo de servicio del screen manager."
    exit 1
}

# 4. Recargar systemd, habilitar e iniciar el servicio
sudo systemctl daemon-reload
sudo systemctl enable screen_manager.service
sudo systemctl start screen_manager.service

echo "--> Servicio del screen manager configurado y iniciado."