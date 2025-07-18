#!/bin/bash
set -e # Salir inmediatamente si un comando falla
set -u # Tratar las variables no definidas como un error

# --- Variables de configuración del script ---
ENCRYPTED_SECRETS_FILE="secret/secrets.enc"
# Usamos /tmp/ ya que se limpia al reiniciar y es un buen lugar para archivos temporales
DECRYPTED_SECRETS_FILE="/tmp/rpi_secrets_$(date +%s).env" # Añadir timestamp para unicidad


# --- Función para descifrar los secretos ---
decrypt_secrets() {
    if [ -f "$ENCRYPTED_SECRETS_FILE" ]; then
        echo "--> Se encontró el archivo de secretos cifrado. Por favor, introduce la contraseña:"
        read -s -p "Contraseña de los secretos: " DECRYPT_PASS
        echo # Nueva línea para una mejor visualización

        echo "--> Descifrando secretos..."
        if ! openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$ENCRYPTED_SECRETS_FILE" -out "$DECRYPTED_SECRETS_FILE" -k "$DECRYPT_PASS"; then
            echo "ERROR: Contraseña incorrecta, archivo de secretos corrupto o error de OpenSSL. Abortando." >&2
            exit 1
        fi
        # Asegurar que solo el propietario pueda leer el archivo desencriptado
        chmod 600 "$DECRYPTED_SECRETS_FILE"

        echo "--> Secretos descifrados temporalmente. Cargando variables de entorno..."
        source "$DECRYPTED_SECRETS_FILE" # ¡Esto carga las variables en el entorno del script!
        rm "$DECRYPTED_SECRETS_FILE"     # ¡Eliminar el archivo temporal inmediatamente después de cargarlo!
        echo "--> Archivo de secretos temporal eliminado del disco."
    else
        echo "AVISO: No se encontró el archivo de secretos cifrado ($ENCRYPTED_SECRETS_FILE). Procediendo sin secretos automáticos."
    fi
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -in secret/id_rsa.enc -out ~/.ssh/id_rsa -k "$DECRYPT_PASS"
    chmod 600 ~/.ssh/id_rsa
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -in secret/id_rsa.pub.enc -out ~/.ssh/id_rsa.pub -k "$DECRYPT_PASS"
    chmod 644 ~/.ssh/id_rsa.pub

}

# --- Funciones para cada fase de la configuración ---

# Función para actualizar el sistema y dependencias básicas
install_system_dependencies() {
    echo "--> Actualizando el sistema e instalando dependencias básicas..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt install git curl wget unzip python3-pip -y # Ejemplos de paquetes básicos
    sudo apt autoremove -y
    sudo apt clean
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
    ./scripts/setup_tailscale.sh
}

# Función para configurar el servidor web y copiar configs
configure_web_server() {
    echo "--> Ejecutando script de configuración del servidor web..."
    ./scripts/configure_webserver.sh
}

# Función para inicializar y actualizar submódulos de Git (tus proyectos)
clone_projects() {
    echo "--> Inicializando y actualizando submódulos de Git..."
    git submodule update --init --recursive
    echo "--> Submódulos actualizados. Tu proyecto web debería estar en projects/my_website/."
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

# Paso 1: Descifrar y cargar los secretos (si existen)
decrypt_secrets

# Paso 2: Instalar dependencias del sistema y actualizar
install_system_dependencies

# Paso 3: Configurar claves SSH
# configure_ssh_keys

# Paso 4: Configurar Tailscale (usará $TAILSCALE_AUTH_KEY si se cargó desde los secretos)
setup_tailscale

# Paso 5: Inicializar y clonar los proyectos (submódulos)
clone_projects

# Paso 6: Configurar el servidor web (ej. Nginx para el proyecto web)
# configure_web_server

# Paso 7: Copiar otras configuraciones personalizadas
# copy_custom_configs

echo "--- Configuración de Raspberry Pi completada. ---"
echo "Por favor, revisa los mensajes anteriores para cualquier acción manual pendiente (ej. añadir clave SSH a GitHub, autenticar Tailscale si no usaste auth key)."