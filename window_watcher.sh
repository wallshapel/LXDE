#!/bin/bash

echo "👀 Observando nuevas ventanas... (Ctrl+C para salir)"

# Archivo temporal para almacenar el estado anterior
TMPFILE="/tmp/.window_list_prev"
> "$TMPFILE"

while true; do
  sleep 0.5

  # Obtener lista actual de ventanas, ordenada
  xprop -root _NET_CLIENT_LIST | grep -o '0x[0-9a-fA-F]\+' | sort > /tmp/.window_list_now

  # Detectar diferencia: nuevas ventanas
  NEW_WINDOWS=$(comm -13 "$TMPFILE" /tmp/.window_list_now)

  # Si hay al menos una nueva ventana
  if [[ -n "$NEW_WINDOWS" ]]; then
    echo "🆕 Ventana(s) detectada(s):"
    echo "$NEW_WINDOWS"

    # Tomar la última ventana de la lista (probablemente la principal visible)
    LAST_WIN=$(echo "$NEW_WINDOWS" | tail -n 1)
    echo "📌 Centrando ventana principal: $LAST_WIN"

    # Llamar al script de centrado pasando la ventana
    ~/.local/bin/smart-launcher.sh "$main_win"
  fi

  # Actualizar archivo temporal para la siguiente iteración
  cp /tmp/.window_list_now "$TMPFILE"
done
