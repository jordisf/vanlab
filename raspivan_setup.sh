#!/bin/bash
set -e # Salir inmediatamente si un comando falla
set -u # Tratar las variables no definidas como un error

# --- Variables de configuración del script ---
ENCRYPTED_SECRETS_FILE="secret.enc/secrets.env.enc"
# Usamos /tmp/ ya que se limpia al reiniciar y es un buen lugar para archivos temporales
DECRYPTED_SECRETS_FILE="/tmp/rpi_secrets_$(date +%s).env" # Añadir timestamp para unicidad

SCRIPTS_PATH="./scripts"


# --- Función para verificar permisos ---
set_file_permissions() {
    chmod u+x "${SCRIPTS_PATH}/"*.sh
}


# Función para generar y configurar claves SSH
configure_ssh_keys() {
    echo "--> Ejecutando script de configuración SSH..."
    ./scripts/configure_ssh.sh
}

# Función para configurar Tailscale
setup_tailscale() {
    echo "--> Ejecutando script de configuración de Tailscale..."
    # Pasamos el auth key como una variable de entorno al script de tailscale si lo deseas
    # export TAILSCALE_AUTH_KEY="$TAILSCALE_AUTH_KEY" # Esto ya está cargado por 'source'
    "${SCRIPTS_PATH}/setup_tailscale.sh"
}

setup_kiosk_mode() {
    echo "--> Ejecutando script de configuración del modo quiosco..."
    "${SCRIPTS_PATH}/setup_kiosk_mode.sh"
}


# Función para configurar el servidor web y copiar configs
configure_web_server() {
    echo "--> Ejecutando script de configuración del servidor web..."
    "${SCRIPTS_PATH}/configure_webserver.sh"
}

# Función para copiar archivos de configuración personalizados
copy_custom_configs() {
    echo "--> Copiando archivos de configuración personalizados..."
    # Ejemplo: copiar un .bashrc personalizado
    if [ -f "configs/.bashrc_custom" ]; then
        cp configs/.bashrc_custom "$HOME/.bashrc"
        echo "source ~/.bashrc" # Asegurarse de que los cambios se carguen
    fi
    # Ejemplo: copiar config de Nginx para el sitio
    # sudo cp configs/nginx_site_config /etc/nginx/sites-available/my_website
    # sudo ln -s /etc/nginx/sites-available/my_website /etc/nginx/sites-enabled/
    # sudo systemctl reload nginx
}

# --- Flujo principal de ejecución ---
echo "--- Iniciando configuración automatizada de Raspberry Pi ---"

# Es crucial que este script se ejecute con 'source' para que las variables
# de los secretos se carguen en el entorno de setup.sh.
source ${SCRIPTS_PATH}/00_load_secrets.sh # <--- ¡CAMBIO CLAVE AQUÍ!

# Verificar permisos de ejecución
set_file_permissions

# Instalar dependencias del sistema y actualizar
source ${SCRIPTS_PATH}/10_install_system_dependencies.sh

# Configurar Tailscale (usará $TAILSCALE_AUTH_KEY si se cargó desde los secretos)
source "${SCRIPTS_PATH}/setup_tailscale.sh"

# Inicializar y clonar los proyectos (submódulos)
source "${SCRIPTS_PATH}/19_clone_projects.sh"

# Configurar el servidor web (ej. Nginx para el proyecto web)
# configure_web_server

# Copiar otras configuraciones personalizadas

source "${SCRIPTS_PATH}/setup_kiosk_mode.sh"
source "${SCRIPTS_PATH}/disable_virtual_keyboard.sh"

echo "--- Configuración de Raspberry Pi completada. ---"
echo "Por favor, revisa los mensajes anteriores para cualquier acción manual pendiente (ej. añadir clave SSH a GitHub, autenticar Tailscale si no usaste auth key)."