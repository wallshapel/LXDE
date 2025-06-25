#!/bin/bash

echo "📍 Obteniendo posición del mouse..."
eval "$(xdotool getmouselocation --shell)"
echo "  → Mouse: X=$X, Y=$Y"

echo "📍 Detectando monitores conectados..."
mapfile -t MONITORS < <(xrandr | grep " connected" | awk '{print $3}' | sort -t '+' -k2n)

MONITOR_INDEX=-1
for i in "${!MONITORS[@]}"; do
  MON="${MONITORS[$i]}"
  MON_X=$(echo "$MON" | cut -d'+' -f2)
  MON_Y=$(echo "$MON" | cut -d'+' -f3)
  MON_W=$(echo "$MON" | cut -d'x' -f1)
  MON_H=$(echo "$MON" | cut -d'x' -f2 | cut -d'+' -f1)
  if (( X >= MON_X && X < MON_X + MON_W )); then
    MONITOR_INDEX=$i
    echo "✅ Mouse está en el monitor $i → X=$MON_X a X=$(($MON_X + $MON_W - 1))"
    break
  fi
done

if (( MONITOR_INDEX == -1 )); then
  echo "❌ No se detectó el monitor para el mouse. Abortando..."
  exit 1
fi

MONITOR_GEOM="${MONITORS[$MONITOR_INDEX]}"
MON_X=$(echo "$MONITOR_GEOM" | cut -d'+' -f2)
MON_Y=$(echo "$MONITOR_GEOM" | cut -d'+' -f3)
MON_W=$(echo "$MONITOR_GEOM" | cut -d'x' -f1)
MON_H=$(echo "$MONITOR_GEOM" | cut -d'x' -f2 | cut -d'+' -f1)

echo "🖥 Monitor detectado:"
echo "  → X offset = $MON_X"
echo "  → Y offset = $MON_Y"
echo "  → Width    = $MON_W"
echo "  → Height   = $MON_H"

if [ -n "$1" ]; then
  WIN_ID="$1"
  echo "📍 Usando ventana proporcionada por argumento: $WIN_ID"
else
  echo "📍 Obteniendo ventana activa..."
  WIN_ID=$(xdotool getactivewindow)
  echo "  → Ventana activa: $WIN_ID"
fi

read WIN_X WIN_Y WIN_W WIN_H < <(
  xwininfo -id "$WIN_ID" |
  awk '/Absolute upper-left X:/ {x=$NF}
       /Absolute upper-left Y:/ {y=$NF}
       /Width:/ {w=$2}
       /Height:/ {h=$2}
       END {print x, y, w, h}'
)
echo "📐 Tamaño de la ventana:"
echo "  → W = $WIN_W, H = $WIN_H"

# Coordenadas para centrar ventana (ajustadas)
CENTER_X=$(( MON_X + (MON_W / 2) - (WIN_W / 2) ))
CENTER_Y=$(( MON_Y + (MON_H / 2) - (WIN_H / 2) ))

echo "🎯 Nueva posición centrada:"
echo "  → X = $CENTER_X"
echo "  → Y = $CENTER_Y"

# Mover ventana
xdotool windowmove "$WIN_ID" "$CENTER_X" "$CENTER_Y"
