#!/bin/bash
set -e
set -u

echo "--> Actualizando el sistema e instalando dependencias básicas..."
sudo apt update
sudo apt upgrade -y
sudo apt install git curl wget unzip python3-pip -y # Ejemplos de paquetes básicos
sudo apt purge squeekboard -y # Elimina el teclado virtual predeterminado de Raspberry Pi
sudo apt autoremove -y
sudo apt clean


