#!/bin/bash
set -e
set -u

echo "--> Instalando y configurando Nginx como servidor web..."

# 1. Instalar Nginx
echo "  Instalando el paquete Nginx..."
sudo apt update
sudo apt install -y nginx

echo "  Configurando Nginx..."

# 3. Crear o modificar la configuración de Nginx
# Vamos a crear un nuevo archivo de configuración para nuestro sitio
# y deshabilitar el sitio por defecto de Nginx.

NGINX_SITE_CONFIG="/etc/nginx/sites-available/van-webui"
NGINX_SITE_SYMLINK="/etc/nginx/sites-enabled/van-webui"
NGINX_DEFAULT_SYMLINK="/etc/nginx/sites-enabled/default"

# Contenido de la configuración del servidor Nginx
# Esto crea un bloque de servidor que escucha en el puerto 80 y sirve archivos desde WEB_PROJECT_ROOT
cp ./configs/nginx/van-webui /etc/nginx/sites-available/van-webui

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

echo "--> Nginx configurado para servir el proyecto van-webui."
