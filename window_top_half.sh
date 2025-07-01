#!/bin/bash

# Constantes de ajuste
H_PADDING_BROWSER=3           # Ajuste horizontal adicional para navegadores
HEIGHT_REDUCTION_NORMAL=25    # Reducción de altura para ventanas no navegador
WIDTH_REDUCTION_LEFT=6        # Ajuste extra en panel izquierdo
HEIGHT_REDUCTION_SIDE=32      # Reducción vertical fija cuando el panel está en un lado
Y_OFFSET_SIDE=3               # Desplazamiento adicional en Y para ventanas con panel lateral

WIN_ID=$(xdotool getactivewindow)
echo "🪟 Ventana activa: $WIN_ID"

# Detectar si la ventana es un navegador
CLASS_LINE=$(xprop -id "$WIN_ID" WM_CLASS)
echo "🧾 Línea completa WM_CLASS: $CLASS_LINE"

WIN_CLASS=$(echo "$CLASS_LINE" | awk -F '"' '{print $(NF-1)}' | tr '[:upper:]' '[:lower:]')
echo "🔍 Clase de ventana: $WIN_CLASS"

IS_BROWSER=false
if echo "$WIN_CLASS" | grep -qE 'chrome|brave|firefox|tor|web|browser|navigator'; then
  IS_BROWSER=true
  echo "🌐 Esta ventana parece ser un navegador"
else
  echo "🧱 Esta ventana NO parece ser un navegador"
fi

# Ejecutar macro Super + Home
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

    # Obtener índice del monitor
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

    # Leer grosor del panel
    PANEL_THICKNESS=0
    PANEL_EDGE=""
    if [[ -n "$PANEL_FILE" ]]; then
      PANEL_THICKNESS=$(awk -F '=' '/height=/ {print $2}' "$PANEL_FILE")
      PANEL_EDGE=$(awk -F '=' '/edge=/ {print $2}' "$PANEL_FILE" | tr -d '[:space:]')
      echo "📄 Archivo de panel: $(basename "$PANEL_FILE")"
      echo "📏 Grosor del panel: $PANEL_THICKNESS"
      echo "📐 Posición del panel: $PANEL_EDGE"
    else
      echo "⚠ No se encontró archivo de panel para el monitor."
    fi

    # Ajustes por posición del panel
    ADJUSTED_WIDTH=$WIDTH
    ADJUSTED_HEIGHT=$HEIGHT
    FINAL_WIDTH=$WIDTH
    FINAL_HEIGHT=$((HEIGHT / 2))
    NEW_X=$X_OFF
    NEW_Y=$Y_OFF

    case "$PANEL_EDGE" in
      bottom)
        FINAL_WIDTH=$((FINAL_WIDTH - H_PADDING_BROWSER))
        ADJUSTED_HEIGHT=$((HEIGHT - PANEL_THICKNESS))
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2))
        else
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2 - HEIGHT_REDUCTION_NORMAL))
        fi
        echo "▾ Panel inferior (no afecta parte superior): altura usable $ADJUSTED_HEIGHT"
        ;;
      top)
        FINAL_WIDTH=$((FINAL_WIDTH - H_PADDING_BROWSER))
        if [[ "$IS_BROWSER" == "true" ]]; then
          ADJUSTED_HEIGHT=$((HEIGHT - PANEL_THICKNESS))
          NEW_Y=$((Y_OFF + PANEL_THICKNESS))
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2 - HEIGHT_REDUCTION_NORMAL + 11))
        else
          ADJUSTED_HEIGHT=$((HEIGHT - PANEL_THICKNESS))
          NEW_Y=$((Y_OFF + PANEL_THICKNESS))
          FINAL_HEIGHT=$((ADJUSTED_HEIGHT / 2 - HEIGHT_REDUCTION_NORMAL))
        fi
        echo "▴ Panel superior: inicio Y $NEW_Y, altura usable $ADJUSTED_HEIGHT"
        ;;
      left)
        ADJUSTED_WIDTH=$((WIDTH - PANEL_THICKNESS))
        FINAL_WIDTH=$((ADJUSTED_WIDTH - WIDTH_REDUCTION_LEFT))
        NEW_X=$((X_OFF + PANEL_THICKNESS))
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_HEIGHT=$((HEIGHT / 2))
          NEW_Y=$((Y_OFF + Y_OFFSET_SIDE))
        else
          FINAL_HEIGHT=$((HEIGHT / 2 - HEIGHT_REDUCTION_SIDE))
          NEW_Y=$((Y_OFF + Y_OFFSET_SIDE))
        fi
        echo "◂ Panel izquierdo: ancho visible $ADJUSTED_WIDTH, X inicio $NEW_X"
        ;;
      right)
        ADJUSTED_WIDTH=$((WIDTH - PANEL_THICKNESS))
        FINAL_WIDTH=$ADJUSTED_WIDTH
        if [[ "$IS_BROWSER" == "true" ]]; then
          FINAL_HEIGHT=$((HEIGHT / 2 - 20))
          NEW_Y=$((Y_OFF))
        else
          FINAL_HEIGHT=$((HEIGHT / 2 - HEIGHT_REDUCTION_SIDE))
          NEW_Y=$((Y_OFF + Y_OFFSET_SIDE))
        fi
        echo "▸ Panel derecho: ancho visible $ADJUSTED_WIDTH, X inicio $NEW_X"
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
