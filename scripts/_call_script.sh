#!/bin/bash
set -e
set -u

script_name="$1"
script_path="$(dirname "$0")"
script_file_name="$(basename "$script_name")"
flag_script_name="./${script_path}/.${script_file_name}.done"

echo "Ejecutando script: $script_name"
echo "Ruta del script: $script_path"
echo "Nombre del archivo: $script_file_name"
echo "Flag script name: $flag_script_name"

# Verificar si el script ya se ha ejecutado
if [ -f "$flag_script_name" ]; then
    echo "El script '$script_name' ya se ha ejecutado anteriormente. Saliendo sin hacer nada."
    exit 0
fi
# Ejecutar el script
if [ -f "$script_name" ]; then
    echo "Ejecutando el script '$script_name'..."
    source "$script_name"
else
    echo "ERROR: El script '$script_name' no se encuentra en la ruta especificada."
    exit 1
fi

# Marcar el script como ejecutado creando un archivo de flag
touch "$flag_script_name"
echo "Script '$script_name' ejecutado correctamente. Se ha creado el archivo de flag: $flag_script_name"
echo "Puedes eliminar este archivo manualmente si necesitas volver a ejecutar el script."
echo "Fin de la ejecución del script '$script_name'."