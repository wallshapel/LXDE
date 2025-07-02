# 💻 Personalización y mejoras de LXDE

✨ Este repositorio contiene una versión **personalizada y mejorada** del archivo `lxde-rc.xml`, diseñada para maximizar la productividad en entornos LXDE.

> ⚙️ ¡Adiós a las configuraciones por defecto! Dale superpoderes a tu escritorio con atajos bien pensados, scripts útiles y una experiencia más fluida.

---

## 🔧 Requisitos previos

- Tener instalada una distribución Linux con entorno LXDE.
- Tener instalados los siguientes paquetes:
  - `xdotool`
  - `xrandr`
  - `xprintidle`
  - `xautolock`
  - `ffmpeg`
  - `pulseaudio`
  - `xscreensaver`
  - `bc`
  - `libreoffice` (Writer, Calc, Impress)
- Tener los directorios `~/.local/bin/` y `~/.local/share/applications/` disponibles.
- Tener permisos para editar archivos de configuración en `~/.config/lxsession/LXDE/`.

---

## 🚀 Funcionalidades incorporadas

- Atajos de teclado para:
  - Minimizar, maximizar, restaurar ventanas activas
  - Control multimedia desde el teclado
  - Movimiento de ventanas entre monitores y ajuste por bordes
  - Lanzadores rápidos para calculadora y terminal
- Botón personalizado para mostrar el escritorio (toggle)
- Scripts para lanzar LibreOffice desde el runner (`Ctrl + R`) con palabras clave nostálgicas
- Suspensión automática tras inactividad **solo si no hay audio reproduciéndose**
- Prevención del protector de pantalla mientras hay audio activo
- Las ventanas se abren en el monitor donde se encuentra el cursor

> ⚠️ Importante: los ajustadores de ventanas están diseñados para funcionar correctamente **solo si hay un panel por monitor**.

---

## 🎮 Gestión de Ventanas

| Acción                      | Atajo            |
| --------------------------- | ---------------- |
| 🗅 Minimizar ventana activa | `Super` + `PgDn` |
| 🗆 Maximizar ventana activa | `Super` + `PgUp` |
| 🔳 Restaurar ventana        | `Super` + `Home` |

---

## 🎵 Control Multimedia

| Acción               | Atajo              |
| -------------------- | ------------------ |
| 🔇 Mutear volumen    | `AudioMute`        |
| 🔊 Subir volumen     | `AudioRaiseVolume` |
| 🔉 Bajar volumen     | `AudioLowerVolume` |
| ▶️ Reproducir/Pausar | `AudioPlay`        |

---

## 📺 Multimonitor y Ajuste de Ventanas

| Acción                               | Atajo                        |
| ------------------------------------ | ---------------------------- |
| ➡️ Mover ventana a monitor derecho   | `Ctrl` + `Alt` + `Shift` + → |
| ⬅️ Mover ventana a monitor izquierdo | `Ctrl` + `Alt` + `Shift` + ← |
| ➡️ Ajustar a la derecha              | `Super` + →                  |
| ⬅️ Ajustar a la izquierda            | `Super` + ←                  |
| ⬆️ Ajustar arriba                    | `Super` + ↑                  |
| ⬇️ Ajustar abajo                     | `Super` + ↓                  |

---

## ⚙️ Lanzadores

| Aplicación     | Atajo              |
| -------------- | ------------------ |
| 🧶 Calculadora | `Ctrl` + `Alt` + C |
| 💪 Terminal    | `Ctrl` + `Alt` + T |

---

## 📂 Escritorios Virtuales

Puedes aumentar o disminuir el número de escritorios virtuales modificando:

```xml
<number>4</number>
```

En la sección correspondiente del archivo `lxde-rc.xml`.

---

## ❌ Mejora de Experiencia con Sublime Text

- Desactivado `Alt + clic izquierdo` para evitar conflicto con selección múltiple.

---

## 🧰 Scripts Personalizados

Todos los scripts deben ir en `~/.local/bin/` y se les debe dar permisos de ejecución:

```bash
chmod +x ~/.local/bin/*
```

### Scripts incluidos:

- `move_window_left.sh`
- `move_window_right.sh`
- `window_top_half.sh`
- `window_bottom_half.sh`
- `window_left_half.sh`
- `window_right_half.sh`
- `smart-launcher.sh`
- `suspend_if_idle.sh`
- `audio_screensaver_watcher.sh`
- `is_audio_active.sh`
- `word`  → LibreOffice Writer
- `excel` → LibreOffice Calc
- `point` → LibreOffice Impress

> Asegúrate de que `~/.local/bin` esté en tu `PATH`. Añádelo en tu `~/.bashrc` y `~/.profile` si es necesario.

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

---

## 💻 Mostrar Escritorio (toggle real)

### Archivo

`~/.local/share/applications/show-desktop-toggle.desktop`

### Contenido

```ini
[Desktop Entry]
Type=Application
Name=Mostrar Escritorio
Exec=xdotool key Ctrl+Alt+d
Icon=desktop
Terminal=false
Categories=Utility;
NoDisplay=true
```

### Instrucciones

1. Cambia temporalmente `NoDisplay=true` a `false`.
2. Agrega el botón desde: `Preferencias del panel → Miniaplicaciones del panel → Barra de aplicaciones → Preferencias`
3. Añade el botón "Mostrar Escritorio" desde Accesorios.
4. Luego puedes volver a dejar `NoDisplay=true`.
5. Elimina el botón por defecto de minimizar todas.

---

## 🌙 Suspender si está inactivo

### Script

- `suspend_if_idle.sh`

### Requiere:

- `xautolock`
- `xprintidle`

### Configuración

Agrega al final del archivo:

```bash
~/.config/lxsession/LXDE/autostart
```

La siguiente línea (ajustando minutos):

```bash
@xautolock -time 10 -locker ~/.local/bin/suspend_if_idle.sh
```

> Asegúrate de que ningún protector de pantalla (como xscreensaver) tenga un tiempo superior o se puede interrumpir la suspensión.

> ⚠️ Este script ahora **solo activa la suspensión si no hay actividad y no hay audio en reproducción**. Ambas condiciones deben cumplirse.

---

## 🚡 Abrir ventanas donde esté el cursor

### Scripts

- `window_watcher.sh`
- `smart-launcher.sh`

Agrega al final de `~/.config/lxsession/LXDE/autostart`:

```bash
@/home/<tu_usuario>/.local/bin/window_watcher.sh
```

Reinicia LXDE o ejecuta:

```bash
openbox --reconfigure
```

---

## ⛔️ Prevenir protector de pantalla si hay audio

### Scripts

- `audio_screensaver_watcher.sh`
- `is_audio_active.sh`

### Requiere:

- `ffmpeg`
- `pulseaudio`
- `xscreensaver`
- `bc`

### Configuración

Agrega al final del archivo:

```bash
~/.config/lxsession/LXDE/autostart
```

La siguiente línea:

```bash
@/home/<tu_usuario>/.local/bin/audio_screensaver_watcher.sh
```

> Este sistema evita tanto que se active el protector de pantalla **como que se suspenda el sistema** si hay audio en reproducción.

---

## 📁 Estructura del repositorio

```
.
├── lxde-rc.xml
├── README.md
├── ~/.local/bin/
│   ├── move_window_left.sh
│   ├── move_window_right.sh
│   ├── window_top_half.sh
│   ├── window_bottom_half.sh
│   ├── window_left_half.sh
│   ├── window_right_half.sh
│   ├── smart-launcher.sh
│   ├── suspend_if_idle.sh
│   ├── audio_screensaver_watcher.sh
│   ├── is_audio_active.sh
│   ├── word
│   ├── excel
│   └── point
└── ~/.local/share/applications/
    └── show-desktop-toggle.desktop
```

---

## ✅ Activación final

1. Reemplaza `~/.config/openbox/lxde-rc.xml` con el archivo personalizado.
2. Agrega las líneas necesarias a `~/.config/lxsession/LXDE/autostart` según funcionalidad.
3. Reinicia LXDE o ejecuta:

```bash
openbox --reconfigure
```

4. Cierra sesión o reinicia el sistema para asegurar que todos los procesos de fondo inicien correctamente.

---

## 🎯 Resultado

Una experiencia LXDE más potente, moderna, productiva y perfectamente adaptada a tus flujos de trabajo. ✨

