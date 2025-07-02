#!/bin/bash

# Esperar unos segundos opcionalmente
sleep 1

# Ejecutar script de audio
~/.local/bin/is_audio_active.sh > /dev/null
STATUS=$?

if [[ $STATUS -eq 0 ]]; then
  echo "🎵 Audio detectado, se evita suspensión"
  exit 0
fi

# Solo suspender si no hay audio
systemctl suspend
