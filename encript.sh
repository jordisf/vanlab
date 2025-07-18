
echo "Introduce la contraseña de cifrado para el archivo secrets.env:"
read PASSWORD

#encriptaremos el archivo secrets.env
# para que no se suba a GitHub sin encriptar
# y así evitar exponer datos sensibles. 

openssl enc -aes-256-cbc -salt -pbkdf2 -in ./secret/secrets.env -out ./secret.enc/secrets.enc -k "$PASSWORD"

openssl enc -aes-256-cbc -salt -pbkdf2 -in ./secret/id_rsa -out ./secret.enc/id_rsa.enc -k "$PASSWORD"

openssl enc -aes-256-cbc -salt -pbkdf2 -in ./secret/id_rsa.pub -out ./secret.enc/id_rsa.pub.enc -k "$PASSWORD"
