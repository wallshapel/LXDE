#!/bin/bash

echo "🔍 Observando ventanas maximizadas..."

# Archivo de cache temporal
CACHE="/tmp/.maximized_windows_seen"
> "$CACHE"

while true; do
  sleep 0.5

  # Obtener lista de ventanas visibles
  for WIN_ID in $(xprop -root _NET_CLIENT_LIST | grep -o '0x[0-9a-fA-F]\+'); do
    STATE=$(xprop -id "$WIN_ID" _NET_WM_STATE 2>/dev/null)

    # Verificar si está maximizada horizontal y verticalmente
    if echo "$STATE" | grep -q "_NET_WM_STATE_MAXIMIZED_VERT" && echo "$STATE" | grep -q "_NET_WM_STATE_MAXIMIZED_HORZ"; then
      if ! grep -q "$WIN_ID" "$CACHE"; then
        echo "🆕 Ventana maximizándose: $WIN_ID"
        
        # Llamamos al script de maximización personalizada
        ~/.local/bin/maximize_window.sh "$WIN_ID"

        # Marcar como procesada
        echo "$WIN_ID" >> "$CACHE"
      fi
    else
      # Si ya no está maximizada, eliminarla del cache
      sed -i "/$WIN_ID/d" "$CACHE"
    fi
  done
done
