#!/usr/bin/python3
import os
import time
from evdev import InputDevice
import selectors

# --- CONFIGURACIÓN ---
# Actualizado a card1 según tu hardware
HDMI_PORT = "/sys/class/drm/card1-HDMI-A-1/status"

# Ruta al dispositivo de entrada de tu pantalla táctil
DEVICE_PATH = "/dev/input/event0"

# Tiempo de inactividad en segundos para apagar la pantalla
TIMEOUT_S = 300 # 300 segundos = 5 minutos
# --- FIN DE LA CONFIGURACIÓN ---

def set_screen_state(state):
    """Escribe 'on' u 'off' para cambiar el estado de la pantalla."""
    try:
        with open(HDMI_PORT, 'w') as f:
            f.write(state)
    except Exception as e:
        print(f"Error cambiando estado de la pantalla: {e}")

def get_screen_state():
    """Lee el estado actual de la pantalla ('connected', 'disconnected', etc.)."""
    try:
        with open(HDMI_PORT, 'r') as f:
            return f.read().strip()
    except Exception:
        return "unknown"

# --- PROGRAMA PRINCIPAL ---
try:
    print("Iniciando gestor de pantalla...")
    # Nos aseguramos de que la pantalla esté activa al iniciar
    set_screen_state("on")
    time.sleep(1) # Damos un segundo para que el estado se estabilice

    device = InputDevice(DEVICE_PATH)
    print(f"Escuchando actividad en: {device.name}")

    last_activity = time.time()

    selector = selectors.DefaultSelector()
    selector.register(device, selectors.EVENT_READ)

    while True:
        events = selector.select(timeout=1)

        if events:
            last_activity = time.time()
            for key, mask in events:
                for event in key.fileobj.read():
                    pass

        now = time.time()
        idle_time = now - last_activity
        screen_state = get_screen_state()

        if idle_time > TIMEOUT_S:
            # CORREGIDO: Comprobamos si el estado es "connected"
            if screen_state == "connected":
                print(f"Inactividad superada ({int(idle_time)}s). Apagando pantalla.")
                set_screen_state("off") # Escribimos "off" para apagar
        else:
            # CORREGIDO: Comprobamos si el estado es "disconnected"
            if screen_state == "disconnected":
                print("Actividad detectada. Encendiendo pantalla.")
                set_screen_state("on") # Escribimos "on" para encender

        time.sleep(1)

except Exception as e:
    print(f"Ocurrió un error crítico: {e}")
    print("Asegúrate de que las rutas en la configuración son correctas y de que ejecutas el script con 'sudo'.")