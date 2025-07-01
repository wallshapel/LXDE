#!/bin/bash

# Obtener ID de la ventana activa
WIN_ID=$(xdotool getactivewindow)

# Obtener geometría de ventana
read WIN_X WIN_Y < <(
  xwininfo -id "$WIN_ID" |
    awk '/Absolute upper-left X:/ {x=$NF}
         /Absolute upper-left Y:/ {y=$NF}
         END {print x, y}'
)

# Detectar monitor
while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  GEOM=$(echo "$LINE" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')

  WIDTH=$(echo "$GEOM" | cut -d'x' -f1)
  HEIGHT=$(echo "$GEOM" | cut -d'x' -f2 | cut -d'+' -f1)
  X_OFF=$(echo "$GEOM" | cut -d'+' -f2)
  Y_OFF=$(echo "$GEOM" | cut -d'+' -f3)

  if (( WIN_X >= X_OFF && WIN_X < X_OFF + WIDTH && WIN_Y >= Y_OFF && WIN_Y < Y_OFF + HEIGHT )); then
    MONITOR_INDEX=$(xrandr --listmonitors | awk -v name="$NAME" '$0 ~ name {print $1}' | tr -d ':')

    PANEL_FILE=$(grep -l "monitor=$MONITOR_INDEX" "$HOME/.config/lxpanel/LXDE/panels"/*)
    PANEL_THICKNESS=$(awk -F '=' '/height=/ {print $2}' "$PANEL_FILE")
    PANEL_EDGE=$(awk -F '=' '/edge=/ {print $2}' "$PANEL_FILE" | tr -d '[:space:]')

    echo "🖥 Monitor: $NAME"
    echo "📏 Tamaño: ${WIDTH}x${HEIGHT}"
    echo "📐 Panel: $PANEL_EDGE con grosor $PANEL_THICKNESS"

    # Maximizar con o sin compensación
    case "$PANEL_EDGE" in
      right)
        NEW_WIDTH=$((WIDTH - PANEL_THICKNESS))
        xdotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$WIN_ID"
        xdotool windowmove "$WIN_ID" "$X_OFF" "$Y_OFF"
        xdotool windowsize "$WIN_ID" "$NEW_WIDTH" "$HEIGHT"
        echo "📐 Maximización simulada (sin solaparse con panel derecho)"
        ;;
      *)
        xdotool windowstate --add MAXIMIZED_VERT --add MAXIMIZED_HORZ "$WIN_ID"
        echo "✅ Maximización completa"
        ;;
    esac
    break
  fi
done < <(xrandr | grep " connected")
