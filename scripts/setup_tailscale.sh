#!/bin/bash

echo "Instalando Tailscale using auth key: [$TAILSCALE_AUTH_KEY]"
curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --auth-key=$TAILSCALE_AUTH_KEY --accept-routes

echo "Tailscale configurado. Usa 'sudo tailscale status' para verificar."