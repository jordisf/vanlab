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

# 2. Instalar unclutter para ocultar el cursor
sudo apt install -y unclutter

# 3. Crear el archivo de servicio systemd para el modo quiosco
cat <<EOF | sudo tee "$KIOSK_SERVICE_FILE"
[Unit]
Description=Chromium Kiosk Mode
After=network.target graphical.target

[Service]
User=$KIOSK_USER
Group=$KIOSK_USER

# Set environment variables, specifically for Xorg display
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/$KIOSK_USER/.Xauthority"

ExecStartPre=/bin/sh -c 'sleep 5' # Dar tiempo al servidor X para iniciar
# Chromium flags:
# --kiosk: MODO QUIOSCO (pantalla completa, sin interfaz)
# --incognito: No guarda historial/cookies
# --disable-features=TranslateUI: Deshabilita la barra de traducción
# --noerrdialogs: No muestra diálogos de error
# --disable-infobars: Deshabilita las barras de información
# --window-position=0,0: Posiciona la ventana en la esquina superior izquierda
# --disk-cache-dir=/dev/null: Deshabilita la caché en disco
# --ozone-platform-hint=x11: Fuerza el uso de X11 si estás en un entorno Wayland con XWayland
# --disable-gpu-vsync: Puede ayudar a mejorar el rendimiento
# --enable-features=OverlayScrollbar: Barras de desplazamiento más finas
# --app: Abre la URL como una aplicación web
ExecStart=/usr/bin/chromium-browser --kiosk --incognito --disable-features=TranslateUI --noerrdialogs --disable-infobars --window-position=0,0 --disk-cache-dir=/dev/null --ozone-platform-hint=x11 --disable-gpu-vsync --enable-features=OverlayScrollbar --start-fullscreen --app="$WEB_PAGE_URL"

Restart=on-failure
RestartSec=10

# Ocultar el cursor del ratón después de inactividad
# ExecStartPost=/usr/bin/unclutter -idle 1 -root &

[Install]
WantedBy=graphical.target
EOF

# 4. Recargar systemd, habilitar e iniciar el servicio
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

echo "--> Servicio de modo quiosco configurado y iniciado."
echo "    La página '$WEB_PAGE_URL' debería aparecer pronto."