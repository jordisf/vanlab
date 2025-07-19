#!/bin/bash
set -e
set -u

echo "--> Deshabilitando el teclado virtual permanentemente..."

# --- 1. Intentar deshabilitar el autoinicio basado en .desktop ---
KEYBOARD_DESKTOP_FILE="florence-autostart.desktop" # Nombre más común, ajusta si es diferente (ej. matchbox-keyboard.desktop)

# Deshabilitar a nivel de sistema (para todos los usuarios)
if [ -f "/etc/xdg/autostart/$KEYBOARD_DESKTOP_FILE" ]; then
    echo "  Moviemdo /etc/xdg/autostart/$KEYBOARD_DESKTOP_FILE..."
    sudo mv "/etc/xdg/autostart/$KEYBOARD_DESKTOP_FILE" "/etc/xdg/autostart/${KEYBOARD_DESKTOP_FILE}.DISABLED"
fi

# Deshabilitar a nivel de usuario (para el usuario 'pi')
# Asegúrate de que este script se ejecute como el usuario 'pi' o ajusta la ruta
if [ -f "$HOME/.config/autostart/$KEYBOARD_DESKTOP_FILE" ]; then
    echo "  Moviemdo $HOME/.config/autostart/$KEYBOARD_DESKTOP_FILE..."
    mv "$HOME/.config/autostart/$KEYBOARD_DESKTOP_FILE" "$HOME/.config/autostart/${KEYBOARD_DESKTOP_FILE}.DISABLED"
fi

# --- 2. Intentar deshabilitar servicios systemd (si aplican) ---
# Deshabilitar servicio de usuario (más probable para un teclado virtual)
echo "  Intentando deshabilitar servicios de teclado virtual (si existen)..."
systemctl --user disable florence.service 2>/dev/null || true # 2>/dev/null para suprimir errores si no existe
systemctl --user stop florence.service 2>/dev/null || true
systemctl --user disable matchbox-keyboard.service 2>/dev/null || true
systemctl --user stop matchbox-keyboard.service 2>/dev/null || true

# Deshabilitar servicio de sistema (menos probable para un teclado virtual, pero lo incluimos)
sudo systemctl disable florence.service 2>/dev/null || true
sudo systemctl stop florence.service 2>/dev/null || true
sudo systemctl disable matchbox-keyboard.service 2>/dev/null || true
sudo systemctl stop matchbox-keyboard.service 2>/dev/null || true


echo "--> Proceso de deshabilitación de teclado virtual completado. Es posible que necesites reiniciar."