# 💻 Personalización y mejoras de LXDE

✨ Este repositorio contiene una versión **personalizada y mejorada** del archivo `lxde-rc.xml`, diseñada para maximizar la productividad en entornos LXDE.

> ⚙️ ¡Adiós a las configuraciones por defecto! Dale superpoderes a tu escritorio con atajos bien pensados, scripts útiles y una experiencia más fluida.

---

## 🔧 Requisitos Previos

- Tener instalado un entorno LXDE.
- Instalar las siguientes herramientas:

```bash
sudo pacman -S xdotool xorg-xrandr libreoffice-fresh xautolock xprintidle
```

> `libreoffice-fresh` incluye Writer, Calc e Impress.

---

## 🧠 Funcionalidades Incluidas

1. Gestión avanzada de ventanas: minimizar, maximizar, restaurar.
2. Control multimedia desde el teclado.
3. Envío de ventanas entre monitores y ajuste a bordes.
4. Lanzadores personalizados (calculadora, terminal).
5. Mejora en el manejo de escritorios virtuales.
6. Desactivación de `Alt + clic izquierdo` para compatibilidad con Sublime Text.
7. Mostrar escritorio con comportamiento toggle real.
8. Las aplicaciones nuevas se abren automáticamente en el monitor donde se encuentra el cursor.
9. Accesos nostálgicos vía runner (`Ctrl + R`) para abrir Word, Excel e Impress.
10. Suspender automáticamente el sistema tras un período de inactividad.

---

## 🎮 Gestión de Ventanas

| Acción       | Atajo            |
| ------------ | ---------------- |
| 🗕 Minimizar | `Super` + `PgDn` |
| 🗖 Maximizar | `Super` + `PgUp` |
| 🔳 Restaurar | `Super` + `Home` |

## 🎵 Control Multimedia

| Acción                 | Atajo              |
| ---------------------- | ------------------ |
| 🔇 Mutear volumen      | `AudioMute`        |
| 🔊 Subir volumen       | `AudioRaiseVolume` |
| 🔉 Bajar volumen       | `AudioLowerVolume` |
| ▶️ Reproducir / Pausar | `AudioPlay`        |

## 📺 Multimonitor y Ajuste de Ventanas

| Acción                                 | Atajo                         |
| -------------------------------------- | ----------------------------- |
| ➡️ Mandar ventana al monitor derecho   | `Ctrl` + `Alt` + `Shift` + ➡️ |
| ⬅️ Mandar ventana al monitor izquierdo | `Ctrl` + `Alt` + `Shift` + ⬅️ |
| ➡️ Ajustar a la derecha                | `Super` + ➡️                  |
| ⬅️ Ajustar a la izquierda              | `Super` + ⬅️                  |
| ⬆️ Ajustar arriba                      | `Super` + ⬆️                  |
| ⬇️ Ajustar abajo                       | `Super` + ⬇️                  |

## ⚙️ Lanzadores

| Aplicación     | Atajo                |
| -------------- | -------------------- |
| 🧮 Calculadora | `Ctrl` + `Alt` + `C` |
| 💪 Terminal    | `Ctrl` + `Alt` + `T` |

---

## 📂 Escritorios Virtuales

Puedes aumentar o disminuir el número de escritorios modificando el valor de:

```xml
<number>4</number>
```

En la sección correspondiente del archivo `lxde-rc.xml`.

---

## ❌ Mejora de Experiencia con Sublime Text

- Desactivado el gesto `Alt + clic izquierdo` para evitar conflictos con selección múltiple en Sublime Text.

---

## 🧰 Scripts Personalizados

Ubicar todos los siguientes scripts en:

```
~/.local/bin/
```

Y otorgar permisos de ejecución:

```bash
chmod +x ~/.local/bin/*.sh
```

Scripts incluidos:

- `move_window_left.sh`
- `move_window_right.sh`
- `window_top_half.sh`
- `window_bottom_half.sh`
- `window_left_half.sh`
- `window_right_half.sh`
- `smart-launcher.sh`
- `window_watcher.sh`
- `suspend_if_idle.sh`
- `word`
- `excel`
- `point`

Para que `window_watcher.sh` funcione correctamente al inicio del sistema, añade la siguiente línea al archivo:

```
~/.config/lxsession/LXDE/autostart
```

```bash
@/home/<tu_usuario>/.local/bin/window_watcher.sh
```

> Reemplaza `<tu_usuario>` por tu nombre de usuario real. Luego **reinicia el sistema**.

Este script asegura que **las aplicaciones nuevas se abran centradas en el monitor donde se encuentra el cursor del mouse**.

---

## 🌙 Suspender automáticamente tras inactividad

Puedes hacer que tu sistema entre en suspensión automáticamente si no hay actividad del usuario.

### 📁 Script necesario

Ubica `suspend_if_idle.sh` en `~/.local/bin` con permisos de ejecución.

### 🛠️ Configuración

Edita:

```bash
nano ~/.config/lxsession/LXDE/autostart
```

Agrega al final:

```bash
@xautolock -time <minutos> -locker ~/.local/bin/suspend_if_idle.sh
```

> Reemplaza `<minutos>` por el tiempo deseado de inactividad antes de suspender (por ejemplo, 10).

**Importante**: si usas algo como `xscreensaver`, asegúrate de que ninguna configuración tenga un tiempo de espera superior al configurado con `xautolock`, ya que podría **despertar automáticamente al sistema tras la suspensión**.

---

## 🖱️ Accesos desde Runner (Ctrl + R)

Puedes abrir aplicaciones de LibreOffice usando nombres simples desde el lanzador (runner) de LXDE:

| Comando | Abre                |
| ------- | ------------------- |
| `word`  | LibreOffice Writer  |
| `excel` | LibreOffice Calc    |
| `point` | LibreOffice Impress |

### 📌 Pasos necesarios

1. Asegúrate de tener los scripts `word.sh`, `excel.sh`, `point.sh` en `~/.local/bin` con permisos de ejecución.
2. Verifica que `~/.local/bin` esté en tu `$PATH`:

```bash
echo $PATH
```

Si no está, añade lo siguiente:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

3. **Cierra sesión** y vuelve a entrar en LXDE, o reinicia el sistema.

> Esto hará que el runner reconozca correctamente los nuevos comandos.

---

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

1. Cambia temporalmente `NoDisplay=true` a `NoDisplay=false`.
2. Ve a `Preferencias del panel` → `Miniaplicaciones del panel` → `Barra de aplicaciones` → `Preferencias`.
3. Busca en la categoría **Accesorios / Utility** el lanzador **Mostrar Escritorio** y añádelo.
4. Luego, puedes volver a dejar `NoDisplay=true` si no quieres que aparezca en el menú.
5. Elimina el botón original de minimizar todas, ya que este nuevo reemplazo es más funcional y reversible.

---

## 📁 Estructura del Repositorio

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
│   ├── window_watcher.sh
│   ├── suspend_if_idle.sh
│   ├── word
│   ├── excel
│   └── point
└── ~/.local/share/applications/
    └── show-desktop-toggle.desktop
```

---

## 🚀 Listo para Usar

1. Reemplaza tu archivo `~/.config/openbox/lxde-rc.xml` con el proporcionado.
2. Copia todos los scripts en `~/.local/bin/` y otórgales permisos de ejecución.
3. Coloca el archivo `.desktop` en `~/.local/share/applications/`.
4. Edita `~/.config/lxsession/LXDE/autostart` y añade las líneas necesarias para `window_watcher.sh` y `xautolock`.
5. Asegúrate de que `~/.local/bin` esté en el `$PATH` (ver sección runner).
6. Ejecuta:

```bash
openbox --reconfigure
```

7. Reinicia tu sistema para asegurar que todo quede aplicado correctamente.

---

## 🚀 Tu escritorio, a otro nivel

Disfruta una experiencia LXDE más fluida, potente y personalizada. ✨

