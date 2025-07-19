#!/bin/bash
set -e
set -u

echo "--> Instalando y configurando Nginx como servidor web..."

# 1. Instalar Nginx
echo "  Instalando el paquete Nginx..."
sudo apt update
sudo apt install -y nginx

# 2. Definir la ruta de tu proyecto web
# Usamos /home/pi/ para asegurar que la ruta es absoluta y correcta para el usuario 'pi'
WEB_PROJECT_ROOT="/home/pi/vanlab/projects/van-webui/www"

echo "  Configurando Nginx para servir desde: $WEB_PROJECT_ROOT"

# 3. Crear o modificar la configuración de Nginx
# Vamos a crear un nuevo archivo de configuración para nuestro sitio
# y deshabilitar el sitio por defecto de Nginx.

NGINX_SITE_CONFIG="/etc/nginx/sites-available/vanlab_webui"
NGINX_SITE_SYMLINK="/etc/nginx/sites-enabled/vanlab_webui"
NGINX_DEFAULT_SYMLINK="/etc/nginx/sites-enabled/default"

# Contenido de la configuración del servidor Nginx
# Esto crea un bloque de servidor que escucha en el puerto 80 y sirve archivos desde WEB_PROJECT_ROOT
sudo bash -c "cat << EOF > $NGINX_SITE_CONFIG
server {
    listen 80;
    listen [::]:80;

    root $WEB_PROJECT_ROOT;
    index index.html index.htm;

    server_name _; # Se puede usar la IP o un dominio si lo configuras

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Posibles configuraciones futuras para Victron/MQTT (proxy_pass, websockets)
    # location /victron_http_api/ {
    #     proxy_pass http://<IP_VICRON_VRM_O_DISPOSITIVO_LOCAL>:8080/; # Ejemplo
    #     proxy_set_header Host \$host;
    #     proxy_set_header X-Real-IP \$remote_addr;
    #     proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    # }

    # location /mqtt_websocket/ {
    #     proxy_pass http://localhost:9001; # Ejemplo de proxy a un broker MQTT con WebSockets
    #     proxy_http_version 1.1;
    #     proxy_set_header Upgrade \$http_upgrade;
    #     proxy_set_header Connection "upgrade";
    # }
}
EOF"

# 4. Deshabilitar la configuración por defecto de Nginx (si existe)
if [ -L "$NGINX_DEFAULT_SYMLINK" ]; then # -L para comprobar si es un enlace simbólico
    echo "  Deshabilitando la configuración de sitio por defecto de Nginx..."
    sudo rm "$NGINX_DEFAULT_SYMLINK"
fi

# 5. Habilitar nuestra nueva configuración
echo "  Habilitando la configuración 'vanlab_webui'..."
sudo ln -sf "$NGINX_SITE_CONFIG" "$NGINX_SITE_SYMLINK"

# 6. Probar la configuración de Nginx y recargar/reiniciar
echo "  Comprobando la sintaxis de la configuración de Nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "  Sintaxis de Nginx OK. Recargando servicio..."
    sudo systemctl reload nginx # Recarga la configuración sin reiniciar el servicio
else
    echo "  ERROR: La sintaxis de la configuración de Nginx es incorrecta. Por favor, revisa los logs."
    echo "  Intentando reiniciar Nginx de todos modos, pero podría fallar."
    sudo systemctl restart nginx
fi

echo "--> Nginx configurado para servir el proyecto web desde '$WEB_PROJECT_ROOT'."
echo "  Asegúrate de que los archivos dentro de '$WEB_PROJECT_ROOT' tengan permisos de lectura para el usuario 'www-data' (o el usuario de Nginx)."
echo "  Puedes verificarlo visitando la IP de tu Raspberry Pi en un navegador."