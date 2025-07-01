#!/bin/bash

MONITOR="alsa_output.pci-0000_0b_00.4.analog-stereo.monitor"

MEAN_VOLUME=$(ffmpeg -f pulse -i "$MONITOR" -t 2 -af volumedetect -vn -sn -dn -f null /dev/null 2>&1 | grep -oP 'mean_volume:\s\K[-0-9.]+')

if [[ -z "$MEAN_VOLUME" ]]; then
    echo "⚠️  No se pudo detectar el volumen. ¿Está ffmpeg instalado y el monitor activo?"
    exit 2
fi

THRESHOLD=-80

if [[ $(echo "$MEAN_VOLUME > $THRESHOLD" | bc -l) -eq 1 ]]; then
    echo -e "✅ Hay audio activo. Volumen promedio: \033[1m$MEAN_VOLUME dB\033[0m"
    exit 0
else
    echo -e "❌ No hay audio activo. Volumen promedio: \033[1m$MEAN_VOLUME dB\033[0m"
    exit 1
fi
