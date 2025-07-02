#!/bin/bash

# Constantes de ajuste
RIGHT_MARGIN=6 # Reducción del ancho total para que no se vea los bordes en el siguiente monitor

WIN_ID=$(xdotool getactivewindow)
echo "🪟 Ventana activa: $WIN_ID"

# Detectar clase de ventana
CLASS_LINE=$(xprop -id "$WIN_ID" WM_CLASS)
echo "🧾 Línea completa WM_CLASS: $CLASS_LINE"

WIN_CLASS=$(echo "$CLASS_LINE" | awk -F '"' '{print $(NF-1)}' | tr '[:upper:]' '[:lower:]')
echo "🔍 Clase de ventana: $WIN_CLASS"

IS_BROWSER=false
if echo "$WIN_CLASS" | grep -qE 'chrome|brave|firefox|tor|web|browser|navigator'; then
  IS_BROWSER=true
  echo "🌐 Aplicación identificada como navegador"
else
  echo "🧱 Aplicación identificada como no-navegador"
fi

# Macro Super + Home
echo "🪄 Ejecutando Super + Home..."
xdotool keydown Super
xdotool key Home
xdotool keyup Super

# Posición actual de la ventana
read WIN_X WIN_Y < <(
  xwininfo -id "$WIN_ID" |
    awk '/Absolute upper-left X:/ {x=$NF}
         /Absolute upper-left Y:/ {y=$NF}
         END {print x, y}'
)

# Monitor al que pertenece
while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  GEOM=$(echo "$LINE" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')

  WIDTH=$(echo "$GEOM" | cut -d'x' -f1)
  HEIGHT=$(echo "$GEOM" | cut -d'x' -f2 | cut -d'+' -f1)
  X_OFF=$(echo "$GEOM" | cut -d'+' -f2)
  Y_OFF=$(echo "$GEOM" | cut -d'+' -f3)

  if (( WIN_X >= X_OFF && WIN_X < X_OFF + WIDTH && WIN_Y >= Y_OFF && WIN_Y < Y_OFF + HEIGHT )); then
    echo "✅ Ventana en monitor: $NAME"

    MONITOR_INDEX=$(xrandr --listmonitors | awk -v name="$NAME" '$0 ~ name {print $1}' | tr -d ':')

    PANEL_FILE=$(grep -l "monitor=$MONITOR_INDEX" "$HOME/.config/lxpanel/LXDE/panels"/*)
    PANEL_THICKNESS=$(awk -F '=' '/height=/ {print $2}' "$PANEL_FILE")
    PANEL_EDGE=$(awk -F '=' '/edge=/ {print $2}' "$PANEL_FILE" | tr -d '[:space:]')

    echo "📄 Panel: $(basename "$PANEL_FILE")"
    echo "📏 Grosor: $PANEL_THICKNESS"
    echo "📐 Borde: $PANEL_EDGE"

    NEW_X=$X_OFF
    NEW_Y=$Y_OFF
    FINAL_WIDTH=$WIDTH
    FINAL_HEIGHT=$((HEIGHT / 2))

    case "$PANEL_EDGE" in
      bottom)        
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_WIDTH=$FINAL_WIDTH
          FINAL_HEIGHT=$(((HEIGHT - PANEL_THICKNESS) / 2))
        else
          FINAL_WIDTH=$((FINAL_WIDTH - RIGHT_MARGIN))
          FINAL_HEIGHT=$(((HEIGHT - PANEL_THICKNESS - 43) / 2))
        fi
        ;;
      top)
        NEW_Y=$((NEW_Y + PANEL_THICKNESS))
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_WIDTH=$FINAL_WIDTH
          FINAL_HEIGHT=$(((HEIGHT - PANEL_THICKNESS) / 2))
        else
          FINAL_WIDTH=$((FINAL_WIDTH - RIGHT_MARGIN))
          FINAL_HEIGHT=$(((HEIGHT - PANEL_THICKNESS - 43) / 2))
        fi
        ;;
      left)
        NEW_X=$((NEW_X + PANEL_THICKNESS))        
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_WIDTH=$((WIDTH - PANEL_THICKNESS))
          FINAL_HEIGHT=$((FINAL_HEIGHT - 3))
        else
          FINAL_WIDTH=$((WIDTH - PANEL_THICKNESS - RIGHT_MARGIN))
          FINAL_HEIGHT=$((FINAL_HEIGHT - 23))
        fi
        ;;
      right)
        FINAL_WIDTH=$((WIDTH - PANEL_THICKNESS))
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_HEIGHT=$((FINAL_HEIGHT - 3))
        else
          FINAL_HEIGHT=$((FINAL_HEIGHT - 23))
        fi
        ;;
    esac

    echo "📦 Posición final: X=$NEW_X, Y=$NEW_Y"
    echo "📐 Tamaño final: ancho=$FINAL_WIDTH, alto=$FINAL_HEIGHT"

    xdotool windowmove "$WIN_ID" "$NEW_X" "$NEW_Y"
    xdotool windowsize "$WIN_ID" "$FINAL_WIDTH" "$FINAL_HEIGHT"
    break
  fi
done < <(xrandr | grep " connected")