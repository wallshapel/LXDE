# 💻 Personalización y mejoras de LXDE

✨ Este repositorio contiene una versión **personalizada y mejorada** del archivo `lxde-rc.xml`, diseñada para maximizar la productividad en entornos LXDE.

> ⚙️ ¡Adiós a las configuraciones por defecto! Dale superpoderes a tu escritorio con atajos bien pensados, scripts útiles y una experiencia más fluida.

----------

## 🧠 Funcionalidades Incluidas

### 🎮 Gestión de Ventanas

Acción

Atajo

🔕 Minimizar ventana activa

`Super` + `PgDn`

🔖 Maximizar ventana activa

`Super` + `PgUp`

🔳 Restaurar ventana maximizada

`Super` + `Home`

### 🎵 Control Multimedia

Acción

Atajo

🔇 Mutear volumen

`AudioMute` (tecla dedicada)

🔈 Subir volumen

`AudioRaiseVolume`

🔉 Bajar volumen

`AudioLowerVolume`

▶️ Reproducir / Pausar

`AudioPlay`

### 📊 Multimonitor y Ajuste de Ventanas

Acción

Atajo

→ Mandar ventana al monitor derecho

`Ctrl` + `Alt` + `Shift` + →

← Mandar ventana al monitor izquierdo

`Ctrl` + `Alt` + `Shift` + ←

→ Ajustar ventana a la derecha

`Super` + →

← Ajustar ventana a la izquierda

`Super` + ←

↑ Ajustar ventana arriba

`Super` + ↑

↓ Ajustar ventana abajo

`Super` + ↓

### ⚙️ Lanzadores

Aplicación

Atajo

=⃣ Calculadora

`Ctrl` + `Alt` + `C`

💪 Terminal

`Ctrl` + `Alt` + `T`

----------

## 📄 Escritorios Virtuales

Puedes aumentar o disminuir el número de escritorios modificando el valor de:

```xml
<number>4</number>

```

En la sección correspondiente del archivo `lxde-rc.xml`.

----------

## ❌ Mejora de Experiencia con Sublime Text

-   Desactivado el gesto `Alt + clic izquierdo` para evitar conflictos con selección múltiple en Sublime Text.
    

----------

## 🔧 Scripts Personalizados

Los  scripts `.sh` deben ubicarse en:

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

## 📁 Estructura del Repositorio

```
.
├── lxde-rc.xml
├── README.md
└── ~/.local/bin/
    ├── move_window_left.sh
    └── move_window_right.sh

```

----------

## 🚀 Listo para Usar

1.  Reemplaza tu archivo `~/.config/openbox/lxde-rc.xml` con el proporcionado.
    
2.  Coloca los scripts en `~/.local/bin/` y otórgales permisos de ejecución:
    
    ```bash
    chmod +x ~/.local/bin/*.sh
    
    ```
    
3.  Reinicia LXDE o ejecuta:
    
    ```bash
    openbox --reconfigure
    
    ```
    

----------

## 🚀 Tu escritorio, a otro nivel.

Disfruta una experiencia LXDE más fluida, potente y personalizada. ✨

----------

_Hecho con ❤️ por Legato_