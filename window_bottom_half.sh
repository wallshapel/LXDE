#!/bin/bash

# Constantes de ajuste geométrico
WIDTH_MARGIN=3                          # Margen horizontal general
HEIGHT_MARGIN=25                        # Reducción de altura estándar
WIDTH_REDUCTION_LEFT_PANEL=6            # Reducción de ancho por panel izquierdo
HEIGHT_REDUCTION_LATERAL=32             # Reducción vertical por panel lateral
TOP_OFFSET_LATERAL=3                    # Desplazamiento vertical para panel lateral

TOP_PANEL_ADJUST_BROWSER=20             # Ajuste vertical extra (panel arriba + navegador)
RIGHT_PANEL_HEIGHT_DELTA_BROWSER=20     # Expansión de altura (panel derecho + navegador)
RIGHT_PANEL_CORRECTION_NONAPP=7         # Corrección vertical menor (panel derecho + no navegador)

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

    ADJUSTED_WIDTH=$WIDTH
    ADJUSTED_HEIGHT=$HEIGHT
    FINAL_WIDTH=$WIDTH
    FINAL_HEIGHT=$((HEIGHT / 2))
    NEW_X=$X_OFF
    NEW_Y=$((Y_OFF + HEIGHT / 2))

    case "$PANEL_EDGE" in
      bottom)
        FINAL_WIDTH=$((FINAL_WIDTH - WIDTH_MARGIN))
        ADJUSTED_HEIGHT=$((HEIGHT - PANEL_THICKNESS))
        NEW_Y=$((Y_OFF + ADJUSTED_HEIGHT / 2))
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2))
        else
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2 - HEIGHT_MARGIN))
        fi
        echo "▾ Panel inferior"
        ;;
      top)
        FINAL_WIDTH=$((FINAL_WIDTH - WIDTH_MARGIN))
        if [[ "$IS_BROWSER" == "true" ]]; then
          ADJUSTED_HEIGHT=$((HEIGHT - PANEL_THICKNESS + TOP_PANEL_ADJUST_BROWSER))
          NEW_Y=$((Y_OFF + PANEL_THICKNESS + ADJUSTED_HEIGHT / 2 - TOP_PANEL_ADJUST_BROWSER - 3))
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2 + 3))
        else
          ADJUSTED_HEIGHT=$((HEIGHT - PANEL_THICKNESS))
          NEW_Y=$((Y_OFF + PANEL_THICKNESS + ADJUSTED_HEIGHT / 2))
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2 - HEIGHT_MARGIN))
        fi
        echo "▴ Panel superior"
        ;;
      left)
        ADJUSTED_WIDTH=$((WIDTH - PANEL_THICKNESS))
        FINAL_WIDTH=$((ADJUSTED_WIDTH - WIDTH_REDUCTION_LEFT_PANEL))
        NEW_X=$((X_OFF + PANEL_THICKNESS))
        if [[ "$IS_BROWSER" == "true" ]]; then
          NEW_Y=$((Y_OFF + HEIGHT / 2 + TOP_OFFSET_LATERAL))
          FINAL_HEIGHT=$((HEIGHT / 2))
        else
          NEW_Y=$((Y_OFF + HEIGHT / 2 + TOP_OFFSET_LATERAL))
          FINAL_HEIGHT=$((HEIGHT / 2 - HEIGHT_REDUCTION_LATERAL))
        fi
        echo "◂ Panel izquierdo"
        ;;
      right)
        ADJUSTED_WIDTH=$((WIDTH - PANEL_THICKNESS))
        FINAL_WIDTH=$ADJUSTED_WIDTH
        NEW_X=$X_OFF
        if [[ "$IS_BROWSER" == "true" ]]; then
          NEW_Y=$((Y_OFF + HEIGHT / 2 - RIGHT_PANEL_HEIGHT_DELTA_BROWSER))
          FINAL_HEIGHT=$((HEIGHT / 2 + RIGHT_PANEL_HEIGHT_DELTA_BROWSER))
        else
          NEW_Y=$((Y_OFF + HEIGHT / 2 + TOP_OFFSET_LATERAL - RIGHT_PANEL_CORRECTION_NONAPP))
          FINAL_HEIGHT=$((HEIGHT / 2 - HEIGHT_REDUCTION_LATERAL + RIGHT_PANEL_CORRECTION_NONAPP))
        fi
        echo "▸ Panel derecho"
        ;;
    esac

    echo "📦 Posición final: X=$NEW_X, Y=$NEW_Y"
    echo "📐 Tamaño final: ancho=$FINAL_WIDTH, alto=$FINAL_HEIGHT"
    xdotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$WIN_ID"
    xdotool windowmove "$WIN_ID" "$NEW_X" "$NEW_Y"
    xdotool windowsize "$WIN_ID" "$FINAL_WIDTH" "$FINAL_HEIGHT"
    break
  fi
done < <(xrandr | grep " connected")
