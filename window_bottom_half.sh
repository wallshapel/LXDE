#!/bin/bash

WIN_ID=$(xdotool getactivewindow)
echo "Ventana activa: $WIN_ID"

# Restaurar tamaño para poder moverla si está maximizada
xdotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$WIN_ID"
sleep 0.1

# Obtener posición actual del borde izquierdo
WIN_X=$(xwininfo -id "$WIN_ID" | awk '/Absolute upper-left X:/ {print $NF}')
echo "X de ventana activa (borde izquierdo): $WIN_X"

# Leer monitores conectados
while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  GEOM=$(echo "$LINE" | awk '{print $3}')

  WIDTH=$(echo "$GEOM" | cut -d'x' -f1)
  HEIGHT=$(echo "$GEOM" | cut -d'x' -f2 | cut -d'+' -f1)
  X_OFF=$(echo "$GEOM" | cut -d'+' -f2)
  Y_OFF=$(echo "$GEOM" | cut -d'+' -f3)
  X_END=$((X_OFF + WIDTH))

  echo "Monitor $NAME → X: $X_OFF → $X_END, Y: $Y_OFF, ancho: $WIDTH, alto: $HEIGHT"

  if (( WIN_X >= X_OFF && WIN_X < X_END )); then
    echo "La ventana está en el monitor: $NAME"

    HALF_HEIGHT=$((HEIGHT / 2))
    NEW_Y=$((Y_OFF + HALF_HEIGHT))

    xdotool windowmove "$WIN_ID" "$X_OFF" "$NEW_Y"
    xdotool windowsize "$WIN_ID" "$WIDTH" "$HALF_HEIGHT"
    exit 0
  fi
done < <(xrandr | grep " connected")
