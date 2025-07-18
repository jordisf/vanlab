
echo "Introduce la contraseña de cifrado para el archivo secrets.env:"
read -s PASSWORD

#encriptaremos el archivo secrets.env
# para que no se suba a GitHub sin encriptar
# y así evitar exponer datos sensibles. 

openssl enc -aes-256-cbc -salt -pbkdf2 -in ./secret/secrets.env -out ./secret/secrets.enc -k "$PASSWORD"


