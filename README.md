
# 💻 Personalización y mejoras de LXDE

✨ Este repositorio contiene una versión **personalizada y mejorada** del archivo `lxde-rc.xml`, diseñada para maximizar la productividad en entornos LXDE.

> ⚙️ ¡Adiós a las configuraciones por defecto! Dale superpoderes a tu escritorio con atajos bien pensados, scripts útiles y una experiencia más fluida.

----------

## 🧠 Funcionalidades Incluidas

### 🎮 Gestión de Ventanas

Acción

Atajo

🗕 Minimizar ventana activa

`Super` + `PgDn`

🗖 Maximizar ventana activa

`Super` + `PgUp`

🔳 Restaurar ventana maximizada

`Super` + `Home`

### 🎵 Control Multimedia

Acción

Atajo

🔇 Mutear volumen

`AudioMute` (tecla dedicada)

🔊 Subir volumen

`AudioRaiseVolume`

🔉 Bajar volumen

`AudioLowerVolume`

▶️ Reproducir / Pausar

`AudioPlay`

### 📺 Multimonitor y Ajuste de Ventanas

Acción

Atajo

➡️ Mandar ventana al monitor derecho

`Ctrl` + `Alt` + `Shift` + ➡️

⬅️ Mandar ventana al monitor izquierdo

`Ctrl` + `Alt` + `Shift` + ⬅️

➡️ Ajustar ventana a la derecha

`Super` + ➡️

⬅️ Ajustar ventana a la izquierda

`Super` + ⬅️

⬆️ Ajustar ventana arriba

`Super` + ⬆️

⬇️ Ajustar ventana abajo

`Super` + ⬇️

### ⚙️ Lanzadores

Aplicación

Atajo

🧮 Calculadora

`Ctrl` + `Alt` + `C`

💪 Terminal

`Ctrl` + `Alt` + `T`

----------

## 📂 Escritorios Virtuales

Puedes aumentar o disminuir el número de escritorios modificando el valor de:

```xml
<number>4</number>

```

En la sección correspondiente del archivo `lxde-rc.xml`.

----------

## ❌ Mejora de Experiencia con Sublime Text

-   Desactivado el gesto `Alt + clic izquierdo` para evitar conflictos con selección múltiple en Sublime Text.
    

----------

## 🧰 Scripts Personalizados

Los siguientes scripts `.sh` (vistos en la estructura del repositorio) deben ubicarse en:

```
~/.local/bin/

```

> Asegúrate de tener instalados los siguientes paquetes:

-   `xrandr`
    
-   `xdotool`
    

Puedes instalarlos con:

```bash
sudo pacman -S xdotool xorg-xrandr

```

----------

## 🖥️ Mostrar Escritorio (toggle real)

Se reemplazó el botón de "Minimizar todas" que viene por defecto en LXDE, ya que no restaura correctamente las ventanas. En su lugar, se añadió un lanzador más funcional:

### 📁 Ubicación

```
~/.local/share/applications/show-desktop-toggle.desktop

```

### 📄 Contenido del archivo

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

### 🛠️ Instrucciones

1.  Cambia temporalmente `NoDisplay=true` a `NoDisplay=false`.
    
2.  Ve a `Preferencias del panel` → `Miniaplicaciones del panel` → `Barra de aplicaciones` → `Preferencias`.
    
3.  Busca en la categoría **Accesorios / Utility** el lanzador **Mostrar Escritorio** y añádelo.
    
4.  Luego, puedes volver a dejar `NoDisplay=true` si no quieres que aparezca en el menú.
    
5.  Elimina el botón original de minimizar todas, ya que este nuevo reemplazo es más funcional y reversible.
    

----------

## 📁 Estructura del Repositorio

```
.
├── lxde-rc.xml
├── README.md
├── ~/.local/bin/
│   ├── move_window_left.sh
│   └── move_window_right.sh
└── ~/.local/share/applications/
    └── show-desktop-toggle.desktop

```

----------

## 🚀 Listo para Usar

1.  Reemplaza tu archivo `~/.config/openbox/lxde-rc.xml` con el proporcionado.
    
2.  Coloca los scripts en `~/.local/bin/` y otórgales permisos de ejecución:
    
    ```bash
    chmod +x ~/.local/bin/*.sh
    
    ```
    
3.  Coloca el archivo `.desktop` en `~/.local/share/applications/`.
    
4.  Reinicia LXDE o ejecuta:
    
    ```bash
    openbox --reconfigure
    
    ```
    

----------

## 🚀 Tu escritorio, a otro nivel.

Disfruta una experiencia LXDE más fluida, potente y personalizada. ✨