#!/bin/bash
set -e
set -u

API_PATH="/opt/van-api"
VENV_PATH="$API_PATH/venv" # Asegúrate de que esta ruta coincida con donde se creó tu venv
SERVICE_NAME="van-api.service"
GUNICORN_SOCKET_NAME="van-api.socket"

echo "--> Configurando y habilitando el socket y servicio Gunicorn para la API..."

# 1. Configurar el archivo de socket de systemd para Gunicorn
echo "--> Creando archivo de socket systemd para Gunicorn en /etc/systemd/system/$GUNICORN_SOCKET_NAME..."
sudo tee "/etc/systemd/system/$GUNICORN_SOCKET_NAME" > /dev/null <<EOF
[Unit]
Description=Gunicorn socket for Van API
Requires=network.target

[Socket]
ListenStream=/run/van-api.sock
SocketUser=www-data
SocketGroup=www-data
SocketMode=0660

[Install]
WantedBy=sockets.target
EOF

# 2. Configurar el archivo de servicio de systemd para Gunicorn
echo "--> Creando archivo de servicio systemd para Gunicorn en /etc/systemd/system/$SERVICE_NAME..."
sudo tee "/etc/systemd/system/$SERVICE_NAME" > /dev/null <<EOF
[Unit]
Description=Gunicorn instance to serve Van API
After=network.target
Requires=$GUNICORN_SOCKET_NAME

[Service]
User=www-data
Group=www-data
WorkingDirectory=$API_PATH
ExecStart=$VENV_PATH/bin/gunicorn --workers 3 --bind unix:/run/van-api.sock app:app
Restart=on-failure
StandardOutput=journal
StandardError=journal
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "--> Archivos de servicio y socket systemd creados."

# 3. Recargar systemd, habilitar e iniciar los servicios
echo "--> Recargando systemd y habilitando/iniciando servicios..."
echo "Intentando habilitar socket: $GUNICORN_SOCKET_NAME"
sudo systemctl daemon-reload # Recarga las definiciones de servicio de systemd
sudo systemctl start "$GUNICORN_SOCKET_NAME" # Inicia el socket
sudo systemctl enable "$GUNICORN_SOCKET_NAME" # Habilita el socket para que inicie con el arranque
echo "Intentando habilitar servicio: $SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME" # Inicia el servicio Gunicorn
sudo systemctl enable "$SERVICE_NAME" # Habilita el servicio para que inicie con el arranque

echo "--> Servicio van-api configurado y en ejecución."
echo "Puedes verificar su estado con: sudo systemctl status $SERVICE_NAME"
echo "Para ver los logs de la API: sudo journalctl -u $SERVICE_NAME -f"