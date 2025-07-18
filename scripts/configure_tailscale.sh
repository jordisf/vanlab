#!/bin/bash

echo "Instalando Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey=$TAILSCALE_AUTH_KEY # NO RECOMENDADO DIRECTAMENTE

# Método seguro: autenticación manual si no usas un auth key efímero
echo "Iniciando Tailscale. Por favor, abre la URL que aparecerá para autenticarte en tu navegador."
sudo tailscale up

echo "Tailscale configurado. Usa 'sudo tailscale status' para verificar."