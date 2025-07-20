#!/bin/bash

echo "Instalando Tailscale en Raspberry Pi..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "Tailscale configurado. Usa 'sudo tailscale status' para verificar. Usa 'sudo tailscale up --accept-routes' para iniciar el servicio"
echo "Si no usaste una auth key, autentica Tailscale manualmente con 'sudo tailscale up' y sigue las instrucciones en pantalla."
