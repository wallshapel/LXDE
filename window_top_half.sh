WIN_ID=$(xdotool getactivewindow)
echo "Ventana activa: $WIN_ID"

# Quitar estado maximizado
xdotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$WIN_ID"
sleep 0.2

# Esperar a que la ventana deje de estar maximizada (opcional robustez)
for i in {1..5}; do
    WIN_STATE=$(xprop -id "$WIN_ID" _NET_WM_STATE)
    if [[ "$WIN_STATE" != *"_NET_WM_STATE_MAXIMIZED"* ]]; then
        break
    fi
    sleep 0.1
done

# Obtener coordenada X para saber en qué monitor está
WIN_X=$(xwininfo -id "$WIN_ID" | awk '/Absolute upper-left X:/ {print $NF}')
echo "X de ventana activa (borde izquierdo): $WIN_X"

# Recorrer monitores
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
    xdotool windowmove "$WIN_ID" "$X_OFF" "$Y_OFF"
    xdotool windowsize "$WIN_ID" "$WIDTH" "$HALF_HEIGHT"
    break
  fi
done < <(xrandr | grep " connected")
