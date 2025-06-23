#!/bin/bash

WIN_ID=$(xdotool getactivewindow)

# Obtener X,Y absolutos de la ventana
WIN_X=$(xwininfo -id "$WIN_ID" | awk '/Absolute upper-left X:/ {print $NF}')
WIN_Y=$(xwininfo -id "$WIN_ID" | awk '/Absolute upper-left Y:/ {print $NF}')

# Recorrer monitores para encontrar en cuál está la ventana
while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  GEOM=$(echo "$LINE" | awk '{print $3}')
  WIDTH=$(echo "$GEOM" | cut -d'x' -f1)
  HEIGHT=$(echo "$GEOM" | cut -d'x' -f2 | cut -d'+' -f1)
  X_OFF=$(echo "$GEOM" | cut -d'+' -f2)
  Y_OFF=$(echo "$GEOM" | cut -d'+' -f3)

  X_END=$((X_OFF + WIDTH))
  Y_END=$((Y_OFF + HEIGHT))

  if (( WIN_X >= X_OFF && WIN_X < X_END && WIN_Y >= Y_OFF && WIN_Y < Y_END )); then
    # Desmaximizar si está max
    xdotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$WIN_ID"
    # Mover al lado derecho
    HALF_WIDTH=$((WIDTH / 2))
    NEW_X=$((X_OFF + HALF_WIDTH))
    xdotool windowmove "$WIN_ID" "$NEW_X" "$Y_OFF"
    xdotool windowsize "$WIN_ID" "$HALF_WIDTH" "$HEIGHT"
    break
  fi
done < <(xrandr | grep " connected")
