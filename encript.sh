
echo "Introduce la contraseña de cifrado para el archivo secrets.env:"
read PASSWORD

#encriptaremos el archivo secrets.env
# para que no se suba a GitHub sin encriptar
# y así evitar exponer datos sensibles. 
ENCRYPTED_SECRETS_PATH="./secret.enc/"
SECRETS_PATH="./secret/"

rm -rf "$ENCRYPTED_SECRETS_PATH"
mkdir -p "$ENCRYPTED_SECRETS_PATH"

for file in "$SECRETS_PATH"*; do
    file_name=$(basename "$file")
    encrypted_file="$ENCRYPTED_SECRETS_PATH$file_name.enc"
    original_file="$SECRETS_PATH$file_name"
    openssl enc -aes-256-cbc -salt -pbkdf2 -in "$original_file" -out "$encrypted_file" -k "$PASSWORD"
    echo "Encriptado: $original_file a $encrypted_file"
done
