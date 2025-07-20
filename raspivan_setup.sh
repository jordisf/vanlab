#!/bin/bash
set -e # Salir inmediatamente si un comando falla
set -u # Tratar las variables no definidas como un error

SCRIPTS_PATH="./scripts"
SYS_SCRIPTS_PATH="./sys_scripts"
CALL_SCRIPT="./scripts/_call_script.sh"

# --- Función para verificar permisos ---
set_file_permissions() {
    chmod u+x "${SCRIPTS_PATH}/"*.sh
    sudo chown root:root "${SYS_SCRIPTS_PATH}/"*.sh
    chmod u+x "${SYS_SCRIPTS_PATH}/"*.sh
}

# --- Flujo principal de ejecución ---
echo "--- Iniciando configuración automatizada de Raspberry Pi ---"

set_file_permissions

source $CALL_SCRIPT "${SCRIPTS_PATH}/00_load_secrets.sh"
source $CALL_SCRIPT "${SCRIPTS_PATH}/10_install_system_dependencies.sh"
source $CALL_SCRIPT "${SCRIPTS_PATH}/11_setup_tailscale.sh"
source $CALL_SCRIPT "${SCRIPTS_PATH}/19_clone_projects.sh"
source $CALL_SCRIPT "${SCRIPTS_PATH}/42_setup_kiosk_service.sh"

source "${SCRIPTS_PATH}/30_deploy_web_project.sh"
source "${SCRIPTS_PATH}/31_deploy_van_api_project.sh"

source $CALL_SCRIPT "${SCRIPTS_PATH}/32_set_van_api_environment.sh"
source $CALL_SCRIPT "${SCRIPTS_PATH}/40_setup_web_server.sh"
source $CALL_SCRIPT "${SCRIPTS_PATH}/41_setup_van_api_service.sh"

echo "--- Configuración de Raspberry Pi completada. ---"
echo "Por favor, revisa los mensajes anteriores para cualquier acción manual pendiente (ej. añadir clave SSH a GitHub, autenticar Tailscale si no usaste auth key)."