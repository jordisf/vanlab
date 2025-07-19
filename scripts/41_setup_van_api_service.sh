#!/bin/bash
set -e
set -u

echo "--> Copiando configuración de Gunicorn para la API..."

sudo cp ./configs/gunicorn/van_api.service /etc/systemd/system/van_api.service || { echo "ERROR: No se pudo copiar el archivo de servicio de Gunicorn."; exit 1; }