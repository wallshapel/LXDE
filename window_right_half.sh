#!/bin/bash

WIN_ID=$(xdotool getactivewindow)
echo "🪟 Ventana activa: $WIN_ID"

# Ejecutar la combinación Super + Home (macro personalizada)
echo "🪄 Comando Super + Home (tecla por tecla)..."
xdotool keydown Super
xdotool key Home
xdotool keyup Super

# Obtener X,Y absolutos de la ventana
read WIN_X WIN_Y < <(
  xwininfo -id "$WIN_ID" |
    awk '/Absolute upper-left X:/ {x=$NF}
         /Absolute upper-left Y:/ {y=$NF}
         END {print x, y}'
)
echo "📍 Posición actual de la ventana: X=$WIN_X, Y=$WIN_Y"

# Recorrer monitores conectados
while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  GEOM=$(echo "$LINE" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')

  WIDTH=$(echo "$GEOM" | cut -d'x' -f1)
  HEIGHT=$(echo "$GEOM" | cut -d'x' -f2 | cut -d'+' -f1)
  X_OFF=$(echo "$GEOM" | cut -d'+' -f2)
  Y_OFF=$(echo "$GEOM" | cut -d'+' -f3)
  X_END=$((X_OFF + WIDTH))
  Y_END=$((Y_OFF + HEIGHT))

  echo "🖥 Monitor: $NAME"
  echo "  ↳ Geometría: $WIDTH x $HEIGHT, offset X=$X_OFF, Y=$Y_OFF"
  echo "  ↳ Rango X: $X_OFF → $X_END, Rango Y: $Y_OFF → $Y_END"

  if (( WIN_X >= X_OFF && WIN_X < X_END && WIN_Y >= Y_OFF && WIN_Y < Y_END )); then
    echo "✅ Ventana se encuentra dentro de este monitor ($NAME). Aplicando ajuste a la derecha..."

    HALF_WIDTH=$((WIDTH / 2))
    NEW_X=$((X_OFF + HALF_WIDTH))

    echo "📦 Moviendo a X=$NEW_X, Y=$Y_OFF"
    echo "📐 Redimensionando a ancho=$HALF_WIDTH, alto=$HEIGHT"
    xdotool windowmove "$WIN_ID" "$NEW_X" "$Y_OFF"
    xdotool windowsize "$WIN_ID" "$HALF_WIDTH" "$HEIGHT"
    break
  else
    echo "⛔ Ventana no pertenece a este monitor."
  fi
done < <(xrandr | grep " connected")
