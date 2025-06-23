#!/bin/bash

WIN_ID=$(xdotool getactivewindow)
echo "Ventana activa: $WIN_ID"

# Obtener geometría y tamaño actual
read WIN_X WIN_Y WIN_W WIN_H < <(
  xwininfo -id "$WIN_ID" |
  awk '/Absolute upper-left X:/ {x=$NF}
       /Absolute upper-left Y:/ {y=$NF}
       /Width:/ {w=$2}
       /Height:/ {h=$2}
       END {print x, y, w, h}'
)
echo "Posición actual: X=$WIN_X Y=$WIN_Y W=$WIN_W H=$WIN_H"

# Detectar monitores ordenados por X
mapfile -t MONITORS < <(xrandr | grep " connected" | awk '{print $3}' | sort -t '+' -k2n)
echo "Monitores detectados:"
printf '  %s\n' "${MONITORS[@]}"

CURRENT_MONITOR_INDEX=-1

# Determinar en qué monitor está actualmente la ventana
for i in "${!MONITORS[@]}"; do
  MON="${MONITORS[$i]}"
  X_OFF=$(echo "$MON" | cut -d'+' -f2)
  WIDTH=$(echo "$MON" | cut -d'x' -f1)
  
  if (( WIN_X >= X_OFF && WIN_X < X_OFF + WIDTH )); then
    CURRENT_MONITOR_INDEX=$i
    echo "La ventana está en el monitor $i: $MON"
    break
  fi
done

# Si no se detecta monitor actual o ya estamos en el primero, no hacemos nada
if (( CURRENT_MONITOR_INDEX <= 0 )); then
  echo "No hay monitor a la izquierda o no se detectó el monitor actual."
  exit 0
fi

# Monitor destino: anterior en la lista
DEST_MON="${MONITORS[$((CURRENT_MONITOR_INDEX - 1))]}"
WIDTH=$(echo "$DEST_MON" | cut -d'x' -f1)
HEIGHT=$(echo "$DEST_MON" | cut -d'x' -f2 | cut -d'+' -f1)
X=$(echo "$DEST_MON" | cut -d'+' -f2)
Y=$(echo "$DEST_MON" | cut -d'+' -f3)

echo "Monitor destino detectado. Nueva posición: X=$X Y=$Y Tamaño máximo: W=$WIDTH H=$HEIGHT"

# Ajuste si excede
NEW_W=$WIN_W
NEW_H=$WIN_H
(( WIN_W > WIDTH )) && NEW_W=$WIDTH
(( WIN_H > HEIGHT )) && NEW_H=$HEIGHT

echo "Redimensionando a: W=$NEW_W H=$NEW_H"
xdotool windowmove "$WIN_ID" "$X" "$Y"
xdotool windowsize "$WIN_ID" "$NEW_W" "$NEW_H"
