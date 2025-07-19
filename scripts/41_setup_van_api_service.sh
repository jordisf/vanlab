#!/bin/bash
set -e
set -u

API_PATH="/opt/van-api"
VENV_PATH="$API_PATH/venv" # Asegúrate de que esta ruta coincida con donde se creó tu venv
SERVICE_NAME="van-api.service"
GUNICORN_SOCKET_NAME="van-api.socket" # Usaremos un socket UNIX para Gunicorn

echo "--> Configurando y habilitando el socket y servicio Gunicorn para la API..."

# 1. Configurar el archivo de socket de systemd para Gunicorn
# Este socket será el punto de comunicación entre Nginx y Gunicorn.
# Nginx se conectará a /run/van-api.sock
echo "--> Creando archivo de socket systemd para Gunicorn en /etc/systemd/system/$GUNICORN_SOCKET_NAME..."
sudo tee "/etc/systemd/system/$GUNICORN_SOCKET_NAME" > /dev/null <<EOF
[Unit]
Description=Gunicorn socket for Van API
Requires=network.target

[Socket]
ListenStream=/run/van-api.sock
SocketUser=www-data
SocketGroup=www-data
SocketMode=0660 # Permisos para que Nginx (como www-data) pueda acceder

[Install]
WantedBy=sockets.target
EOF

# 2. Configurar el archivo de servicio de systemd para Gunicorn
# Este servicio ejecutará Gunicorn, atendiéndolo al socket.
echo "--> Creando archivo de servicio systemd para Gunicorn en /etc/systemd/system/$SERVICE_NAME..."
sudo tee "/etc/systemd/system/$SERVICE_NAME" > /dev/null <<EOF
[Unit]
Description=Gunicorn instance to serve Van API
After=network.target
Requires=$GUNICORN_SOCKET_NAME # Asegura que el socket esté activo antes que el servicio

[Service]
User=www-data # Gunicorn se ejecutará como el usuario www-data
Group=www-data
WorkingDirectory=$API_PATH # El directorio de trabajo para la API
# Ejecuta Gunicorn usando el python y gunicorn del entorno virtual
ExecStart=$VENV_PATH/bin/gunicorn --workers 3 --bind unix:/run/van-api.sock app:app 
# --workers 3: Número de procesos Gunicorn (ajusta según los núcleos de tu Pi 5)
# --bind unix:/run/van-api.sock: Gunicorn escuchará en el socket UNIX
# app:app: Asume que tu aplicación Flask está en 'app.py' y el objeto Flask se llama 'app'.
# Si tu app se llama 'api' en 'main.py', sería 'main:api'.
Restart=on-failure # Si Gunicorn falla, systemd intentará reiniciarlo
StandardOutput=journal # Envía la salida estándar a journald
StandardError=journal  # Envía el error estándar a journald
PrivateTmp=true # Aísla los directorios temporales del servicio

[Install]
WantedBy=multi-user.target # Inicia el servicio cuando el sistema está listo
EOF

echo "--> Archivos de servicio y socket systemd creados."

# 3. Recargar systemd, habilitar e iniciar los servicios
echo "--> Recargando systemd y habilitando/iniciando servicios..."
sudo systemctl daemon-reload 
sudo systemctl start "$GUNICORN_SOCKET_NAME" 
sudo systemctl enable "$GUNICORN_SOCKET_NAME" 
sudo systemctl start "$SERVICE_NAME" 
sudo systemctl enable "$SERVICE_NAME" 

echo "--> Servicio van-api configurado y en ejecución."
echo "Puedes verificar su estado con: sudo systemctl status $SERVICE_NAME"
echo "Para ver los logs de la API: sudo journalctl -u $SERVICE_NAME -f"