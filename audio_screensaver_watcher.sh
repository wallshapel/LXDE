#!/bin/bash

# Script que detecta audio y evita que se active el protector de pantalla
# sin deshabilitarlo permanentemente, permitiendo que funcione cuando no hay audio.

CHECK_SCRIPT="$HOME/.local/bin/is_audio_active.sh"
LAST_STATE="INACTIVE"

while true; do

    # Ejecuta el detector y oculta su salida
    "$CHECK_SCRIPT" > /dev/null 2>&1
    STATUS=$?

    if [[ $STATUS -eq 0 ]]; then
        # Hay audio → enviar "deactivate" continuamente
        xscreensaver-command -deactivate > /dev/null 2>&1

        if [[ "$LAST_STATE" != "ACTIVE" ]]; then
            echo "⏸️  Audio activo: salvapantallas inhibido"
            LAST_STATE="ACTIVE"
        fi

    else
        # No hay audio → permitir que el salvapantallas se active normalmente
        if [[ "$LAST_STATE" != "INACTIVE" ]]; then
            echo "▶️  Silencio: salvapantallas permitido"
            LAST_STATE="INACTIVE"
        fi
    fi

    sleep 0.5
done
