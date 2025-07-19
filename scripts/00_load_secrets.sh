#!/bin/bash
set -e
set -u

# --- Variables para este script ---
ENCRYPTED_SECRETS_FILE="secret.enc/secrets.enc" # Ruta relativa al directorio raíz del repositorio
# Usamos un archivo temporal con un timestamp para evitar colisiones y asegurar la unicidad.
DECRYPTED_SECRETS_TEMP_FILE="/tmp/rpi_secrets_$(date +%s).env"

# --- Función para Descifrar y Cargar Secretos ---
# Esta función DEBE ejecutarse con 'source' para que las variables se exporten al shell padre.
_decrypt_and_load_secrets_internal() {
    # Asegúrate de que el script principal siempre se ejecute desde la raíz del repo
    # para que $ENCRYPTED_SECRETS_FILE sea encontrado correctamente.
    # Este script asume que es llamado desde el directorio raíz del repo.

    if [ -f "$ENCRYPTED_SECRETS_FILE" ]; then
        echo "--> Se encontró el archivo de secretos cifrado. Por favor, introduce la contraseña para descifrarlo:"
        read -s SECRET_PASSWORD # Pedir contraseña de forma segura (sin eco)
        echo # Salto de línea para limpiar la consola

        echo "--> Intentando descifrar secretos..."
        if ! openssl enc -aes-256-cbc -d -salt -pbkdf2 \
            -in "$ENCRYPTED_SECRETS_FILE" \
            -out "$DECRYPTED_SECRETS_TEMP_FILE" \
            -k "$SECRET_PASSWORD"; then
            echo "ERROR: Contraseña incorrecta o el archivo de secretos está corrupto. Abortando." >&2
            exit 1 # Salir del script actual (00_load_secrets.sh)
        fi
        chmod 600 "$DECRYPTED_SECRETS_TEMP_FILE"

        echo "--> Secretos descifrados y cargando variables de entorno..."
        source "$DECRYPTED_SECRETS_TEMP_FILE" # Carga variables en el entorno del shell *actual* (que es el de setup.sh si lo sourceamos)

        # Exportar todas las variables cargadas para que estén disponibles en subshells
        # del script setup.sh y sus scripts hijos.
        while IFS='=' read -r key value; do
            if [[ ! -z "$key" && "$key" != \#* ]]; then
                export "$key"
            fi
        done < "$DECRYPTED_SECRETS_TEMP_FILE"

        rm "$DECRYPTED_SECRETS_TEMP_FILE" # Elimina el archivo temporal inmediatamente después de cargarlo
        echo "--> Archivo de secretos temporal eliminado del disco."
    else
        echo "AVISO: No se encontró el archivo de secretos cifrado ($ENCRYPTED_SECRETS_FILE). Procediendo sin cargar secretos automatizados."
    fi
    unset SECRET_PASSWORD # Limpiar la variable de la contraseña de la memoria del script.
}

echo "--> Cargando secretos..."
# Ejecutar la función cuando se 'sourcee' este script
_decrypt_and_load_secrets_internal