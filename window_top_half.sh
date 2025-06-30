#!/bin/bash

WIN_ID=$(xdotool getactivewindow)
echo "🪟 Ventana activa: $WIN_ID"

# Ejecutar macro Super + Home (opcional)
echo "🪄 Comando Super + Home..."
xdotool keydown Super
xdotool key Home
xdotool keyup Super

# Obtener posición actual de la ventana
read WIN_X WIN_Y < <(
  xwininfo -id "$WIN_ID" |
    awk '/Absolute upper-left X:/ {x=$NF}
         /Absolute upper-left Y:/ {y=$NF}
         END {print x, y}'
)

# Buscar monitor al que pertenece la ventana
while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  GEOM=$(echo "$LINE" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')

  WIDTH=$(echo "$GEOM" | cut -d'x' -f1)
  HEIGHT=$(echo "$GEOM" | cut -d'x' -f2 | cut -d'+' -f1)
  X_OFF=$(echo "$GEOM" | cut -d'+' -f2)
  Y_OFF=$(echo "$GEOM" | cut -d'+' -f3)
  X_END=$((X_OFF + WIDTH))
  Y_END=$((Y_OFF + HEIGHT))

  if (( WIN_X >= X_OFF && WIN_X < X_END && WIN_Y >= Y_OFF && WIN_Y < Y_END )); then
    echo "✅ Ventana se encuentra en monitor $NAME"

    # Obtener índice del monitor (0, 1, etc.)
    MONITOR_INDEX=$(xrandr --listmonitors | awk -v name="$NAME" '$0 ~ name {print $1}' | tr -d ':')
    echo "🔢 Índice del monitor: $MONITOR_INDEX"

    # Buscar archivo de panel correspondiente
    PANEL_DIR="$HOME/.config/lxpanel/LXDE/panels"
    PANEL_FILE=""
    for file in "$PANEL_DIR"/*; do
      MON=$(awk -F '=' '/monitor=/ {print $2}' "$file")
      if [[ "$MON" == "$MONITOR_INDEX" ]]; then
        PANEL_FILE="$file"
        break
      fi
    done

    # Leer altura y borde del panel
    PANEL_HEIGHT=0
    PANEL_EDGE=""
    if [[ -n "$PANEL_FILE" ]]; then
      PANEL_HEIGHT=$(awk -F '=' '/height=/ {print $2}' "$PANEL_FILE")
      PANEL_EDGE=$(awk -F '=' '/edge=/ {print $2}' "$PANEL_FILE")
      echo "📄 Archivo de panel: $(basename "$PANEL_FILE")"
      echo "📏 Altura del panel: $PANEL_HEIGHT"
      echo "📐 Posición del panel: $PANEL_EDGE"
    else
      echo "⚠ No se encontró archivo de panel para el monitor."
    fi

    # Calcular dimensiones útiles y posición final
    ADJUSTED_WIDTH=$WIDTH
    ADJUSTED_HEIGHT=$HEIGHT
    FINAL_WIDTH=$WIDTH
    FINAL_HEIGHT=$((HEIGHT / 2))
    NEW_X=$X_OFF
    NEW_Y=$Y_OFF

    case "$PANEL_EDGE" in
      bottom)
        ADJUSTED_HEIGHT=$((HEIGHT - PANEL_HEIGHT))
        FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2))
        NEW_Y=$((Y_OFF))
        echo "🔽 Panel inferior: Altura visible $ADJUSTED_HEIGHT"
        echo "🟢 Altura ajustada: inicio desplazado 25px → Y=$NEW_Y, alto=$FINAL_HEIGHT"
        ;;
      top)
        ADJUSTED_HEIGHT=$((HEIGHT - PANEL_HEIGHT))
        FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2))
        NEW_Y=$((Y_OFF + PANEL_HEIGHT))
        echo "🔼 Panel superior: Altura visible $ADJUSTED_HEIGHT"
        echo "🟢 Altura ajustada: inicio desplazado 25px → Y=$NEW_Y, alto=$FINAL_HEIGHT"
        ;;
      left)
        ADJUSTED_WIDTH=$((WIDTH - PANEL_HEIGHT))
        FINAL_WIDTH=$ADJUSTED_WIDTH
        NEW_X=$((X_OFF + PANEL_HEIGHT))
        FINAL_HEIGHT=$((HEIGHT / 2))
        echo "◀️ Panel izquierdo: Ancho visible $ADJUSTED_WIDTH"
        echo "🟢 Altura ajustada: alto reducido 25px → alto=$FINAL_HEIGHT"
        ;;
      right)
        ADJUSTED_WIDTH=$((WIDTH - PANEL_HEIGHT))
        FINAL_WIDTH=$ADJUSTED_WIDTH
        FINAL_HEIGHT=$((HEIGHT / 2))
        echo "▶️ Panel derecho: Ancho visible $ADJUSTED_WIDTH"
        echo "🟢 Altura ajustada: alto reducido 25px → alto=$FINAL_HEIGHT"
        ;;
    esac

    echo "📦 Moviendo ventana a X=$NEW_X, Y=$NEW_Y"
    echo "📐 Redimensionando a ancho=$FINAL_WIDTH, alto=$FINAL_HEIGHT"
    xdotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$WIN_ID"
    xdotool windowmove "$WIN_ID" "$NEW_X" "$NEW_Y"
    xdotool windowsize "$WIN_ID" "$FINAL_WIDTH" "$FINAL_HEIGHT"
    break
  fi
done < <(xrandr | grep " connected")
