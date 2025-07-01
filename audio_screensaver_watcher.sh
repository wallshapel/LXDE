#!/bin/bash

# Ruta absoluta del script de detección
CHECK_SCRIPT="$HOME/.local/bin/is_audio_active.sh"

# Último estado conocido
LAST_STATE=""

while true; do
    # Ejecutar el script
    "$CHECK_SCRIPT" > /dev/null
    STATUS=$?

    # Solo si hay audio activo y no lo sabíamos antes
    if [[ $STATUS -eq 0 && "$LAST_STATE" != "ACTIVE" ]]; then
        xscreensaver-command -deactivate > /dev/null
        echo "⏸️  Audio activo: protector desactivado"
        LAST_STATE="ACTIVE"

    # Si no hay audio y antes lo había
    elif [[ $STATUS -ne 0 && "$LAST_STATE" != "INACTIVE" ]]; then
        echo "▶️  Silencio: protector en estado normal"
        LAST_STATE="INACTIVE"
    fi

    # Espera medio segundo
    sleep 0.5
done
