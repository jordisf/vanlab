#!/bin/bash
set -e # Salir inmediatamente si un comando falla
set -u # Tratar las variables no definidas como un error

SCRIPTS_PATH="./scripts"

# --- Función para verificar permisos ---
set_file_permissions() {
    chmod u+x "${SCRIPTS_PATH}/"*.sh
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
source "${SCRIPTS_PATH}/11_setup_tailscale.sh"

# Inicializar y clonar los proyectos (submódulos)
source "${SCRIPTS_PATH}/19_clone_projects.sh"

# Configurar el servidor web (ej. Nginx para el proyecto web)
# configure_web_server
source "${SCRIPTS_PATH}/30_setup_web_server.sh"

# Copiar otras configuraciones personalizadas

# source "${SCRIPTS_PATH}/20_disable_virtual_keyboard.sh"  ## Esto ya se consigue desinstalando squeekboard
source "${SCRIPTS_PATH}/21_setup_kiosk_mode.sh"

echo "--- Configuración de Raspberry Pi completada. ---"
echo "Por favor, revisa los mensajes anteriores para cualquier acción manual pendiente (ej. añadir clave SSH a GitHub, autenticar Tailscale si no usaste auth key)."