#!/bin/bash

# Espera pasiva para dar tiempo a que el screensaver se estabilice
sleep 5

# Suspende solo si sigue sin actividad
if [[ -z "$(xprintidle)" || "$(xprintidle)" -gt 60000 ]]; then
    systemctl suspend
fi
