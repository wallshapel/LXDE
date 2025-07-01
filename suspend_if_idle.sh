#!/bin/bash

# Espera pasiva para dar tiempo al screensaver y al audio
sleep 5

# Ruta al script que detecta audio
AUDIO_CHECK="$HOME/.local/bin/is_audio_active.sh"

# Comprobar inactividad y silencio
if [[ -z "$(xprintidle)" || "$(xprintidle)" -gt 60000 ]]; then
    if ! "$AUDIO_CHECK" > /dev/null; then
        echo "🛌 Sin actividad ni audio → suspendiendo..."
        systemctl suspend
    else
        echo "🎵 Hay audio activo → NO suspende"
    fi
fi
