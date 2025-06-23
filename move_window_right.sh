#!/bin/bash

WIN_ID=$(xdotool getactivewindow)

# Obtener geometría y tamaño actual
read WIN_X WIN_Y WIN_W WIN_H < <(
  xwininfo -id "$WIN_ID" |
  awk '/Absolute upper-left X:/ {x=$NF}
       /Absolute upper-left Y:/ {y=$NF}
       /Width:/ {w=$2}
       /Height:/ {h=$2}
       END {print x, y, w, h}'
)

# Detectar monitores ordenados por X
mapfile -t MONITORS < <(xrandr | grep " connected" | awk '{print $3}' | sort -t '+' -k2n)

for i in "${!MONITORS[@]}"; do
  MON="${MONITORS[$i]}"
  X_OFF=$(echo "$MON" | cut -d'+' -f2)

  if (( WIN_X < X_OFF )); then
    # Monitor destino
    WIDTH=$(echo "$MON" | cut -d'x' -f1)
    HEIGHT=$(echo "$MON" | cut -d'x' -f2 | cut -d'+' -f1)
    X=$(echo "$MON" | cut -d'+' -f2)
    Y=$(echo "$MON" | cut -d'+' -f3)

    # Ajuste si excede
    NEW_W=$WIN_W
    NEW_H=$WIN_H
    (( WIN_W > WIDTH )) && NEW_W=$WIDTH
    (( WIN_H > HEIGHT )) && NEW_H=$HEIGHT

    xdotool windowmove "$WIN_ID" "$X" "$Y"
    xdotool windowsize "$WIN_ID" "$NEW_W" "$NEW_H"
    break
  fi
done
