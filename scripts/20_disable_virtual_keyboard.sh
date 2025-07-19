# Contenido del script 21_disable_virtual_keyboard.sh
#!/bin/bash
set -e
set -u

echo "--> Iniciando proceso de deshabilitación del teclado virtual permanentemente..."

# --- Variables de teclado virtual comunes ---
# Añade aquí otros nombres si los descubres
KEYBOARD_NAMES=("florence" "matchbox-keyboard" "onboard") 

# --- 1. Intentar deshabilitar el autoinicio basado en .desktop ---
echo "  Buscando y deshabilitando archivos .desktop de autoinicio..."

for NAME in "${KEYBOARD_NAMES[@]}"; do
    KEYBOARD_DESKTOP_FILE="${NAME}-autostart.desktop" # Nombres típicos: florence-autostart.desktop, onboard-autostart.desktop
    
    # Intenta con el nombre base del teclado
    if [ -f "/etc/xdg/autostart/${NAME}.desktop" ]; then
        echo "    Moviemdo /etc/xdg/autostart/${NAME}.desktop..."
        sudo mv "/etc/xdg/autostart/${NAME}.desktop" "/etc/xdg/autostart/${NAME}.desktop.DISABLED"
    fi
    if [ -f "$HOME/.config/autostart/${NAME}.desktop" ]; then
        echo "    Moviemdo $HOME/.config/autostart/${NAME}.desktop..."
        mv "$HOME/.config/autostart/${NAME}.desktop" "$HOME/.config/autostart/${NAME}.desktop.DISABLED"
    fi

    # Intenta con el nombre específico de autostart (ej. florence-autostart.desktop)
    if [ -f "/etc/xdg/autostart/$KEYBOARD_DESKTOP_FILE" ]; then
        echo "    Moviemdo /etc/xdg/autostart/$KEYBOARD_DESKTOP_FILE..."
        sudo mv "/etc/xdg/autostart/$KEYBOARD_DESKTOP_FILE" "/etc/xdg/autostart/${KEYBOARD_DESKTOP_FILE}.DISABLED"
    fi
    if [ -f "$HOME/.config/autostart/$KEYBOARD_DESKTOP_FILE" ]; then
        echo "    Moviemdo $HOME/.config/autostart/$KEYBOARD_DESKTOP_FILE..."
        mv "$HOME/.config/autostart/$KEYBOARD_DESKTOP_FILE" "$HOME/.config/autostart/${KEYBOARD_DESKTOP_FILE}.DISABLED"
    fi
done

# --- 2. Intentar deshabilitar servicios systemd (si aplican) ---
echo "  Intentando deshabilitar y detener servicios de teclado virtual (si existen)..."

for NAME in "${KEYBOARD_NAMES[@]}"; do
    # Deshabilitar y detener servicio de usuario (más probable para un teclado virtual)
    echo "    Intentando para el usuario '$USER': ${NAME}.service"
    systemctl --user disable "${NAME}.service" 2>/dev/null || true
    systemctl --user stop "${NAME}.service" 2>/dev/null || true

    # Deshabilitar y detener servicio de sistema (menos probable)
    echo "    Intentando a nivel de sistema: ${NAME}.service"
    sudo systemctl disable "${NAME}.service" 2>/dev/null || true
    sudo systemctl stop "${NAME}.service" 2>/dev/null || true
done


echo "--> Proceso de deshabilitación de teclado virtual completado. Es **altamente probable que necesites reiniciar** tu Raspberry Pi para que los cambios surtan efecto."
echo "Si el teclado virtual persiste, por favor, sigue los pasos de diagnóstico indicados para identificar el proceso exacto."