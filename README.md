![HWEncoderX Logo](https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/logo.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Stars](https://img.shields.io/docker/stars/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Image Size](https://img.shields.io/docker/image-size/macrimi/hwencoderx/latest?style=for-the-badge&color=94398d&labelColor=555555&logoColor=ffffff&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)



# HWEncoderX: Video Transcoder with GPU Hardware Acceleration (VAAPI, NVENC, and QSV)

HWEncoderX is a Docker container that automatically transcodes videos to H.265 (HEVC) using your GPU with hardware acceleration, supporting **VAAPI** (Intel/AMD), **NVENC** (NVIDIA), and **Intel Quick Sync (QSV)**. It retains all audio, subtitles, and chapters while reducing the file size without quality loss.

## Features

- **Support for Multiple GPUs**: Compatible with **Intel Quick Sync (QSV)**, **NVIDIA NVENC**, and **VAAPI**. If no compatible GPU is detected, the container stops and sends an error notification.

- **Telegram Notifications**: Sends welcome messages, transcoding details (time, speed, quality), and error notifications.

- **Automatic Quality Adjustment**: Optimized adjustment to **prioritize quality** based on the input video bitrate using the global QUALITY variable.

- **Always Active Docker**: The container remains active, continuously monitoring the input directory for new files.

- **Error Handling and Space Verification**: Checks disk space before transcoding and sends notifications if space is insufficient or errors occur.

- **Transcoding Improvements**: Fixed an issue that prevented transcoding of files without defined subtitle tracks.

- **Size Reduction**: Transcoding to H.265 (HEVC) reduces file size by up to 70%.
- **Ideal for Media Servers**: Compatible with **Plex**, **Jellyfin**, **Emby**, and more.
- **Simple**: Just mount the input and output folders, and HWEncoderX does all the work.
- **Customizable Options**: Manually define quality using the **QUALITY** variable and select the **preset** to adjust speed and quality as needed.

## Requirements

You need a GPU compatible with **VAAPI** (Intel/AMD), **NVENC** (NVIDIA), or **Intel Quick Sync (QSV)**. Without a compatible GPU, the container **will not work**.

## Usage Instructions

### - Automatic Option:
The container automatically adjusts the output quality based on the input file's bitrate.

#### - Intel Quick Sync and VAAPI

##### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'
services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

#### - NVIDIA

##### docker run:
```bash
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'
services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu] 
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

### - Manual Option:
This option allows you to manually adjust the transcoding quality using the global variable QUALITY, which applies to NVENC, VAAPI, and QSV.

#### - VAAPI

##### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e QUALITY=18 \
  -e PRESET=fast \
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'
services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
    environment:
      - QUALITY=medium
      - PRESET=medium
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

#### - NVIDIA

##### docker run:
```bash
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e QUALITY=18 \
  -e PRESET=medium \
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'
services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu] 
    environment:
      - QUALITY=18
      - PRESET=medium
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

## Parameters

| Parameters | Function |
| :----: | --- |
| `--device /dev/dri` | Required to enable hardware acceleration via VAAPI. |
| `--gpus all` | Required to enable hardware acceleration via NVENC on NVIDIA GPUs. |
| `-e PRESET=medium` | Specifies the preset value (`ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower`, and `veryslow`). |
| `-e QUALITY=18` | Manually define the quality level for transcoding, used across NVENC, VAAPI, and QSV. |
| `-v /path/to/input:/input` | Replace `/path/to/input` with the path to your input folder, where the videos to be transcoded are located. |
| `-v /path/to/output:/output` | Replace `/path/to/output` with the path where the transcoded files will be saved. (This can be the same as the input folder) |

**Note:** `/path/to/input` and `/path/to/output` can be the same folder. Transcoded files will be created with the `_HEVC` suffix.

## Additional Notes
HWEncoderX works with hardware acceleration **VAAPI**, **NVENC**, and **QSV**. Without a compatible **Intel**, **AMD**, or **NVIDIA** GPU, the container will not work. The original files are not deleted after transcoding.

### Synology/XPenology NAS Compatibility
It works on any NAS with a functional **Intel** or **NVIDIA** GPU.

### DVA Models
On **DVA** Synology NAS that use the **NVIDIA Runtime Library** for **Surveillance Station**, this container cannot be run as it lacks NVIDIA Container Toolkit support.

### License
This project is licensed under the **MIT License**. See the `LICENSE` file for more details.

### Third-party Software
This container uses **FFmpeg**, licensed under **LGPL 2.1 or later**. See the [FFmpeg documentation](https://ffmpeg.org/legal.html) for more information.


#

-- Español

# HWEncoderX: Transcodificador de Video con Aceleración por Hardware GPU (VAAPI, NVENC y QSV)

HWEncoderX es un contenedor Docker que te permite transcodificar videos a H.265 (HEVC) automáticamente usando tu GPU con aceleración por hardware, soportando **VAAPI** (Intel/AMD), **NVENC** (NVIDIA) y **Intel Quick Sync (QSV)**. Mantiene todos los audios, subtítulos y capítulos intactos, mientras reduce el tamaño de tus videos sin perder calidad.

## Características

- **Soporte para Múltiples GPU**: Compatible con **Intel Quick Sync (QSV)**, **NVIDIA NVENC** y **VAAPI**. Si no se detecta una GPU compatible, el contenedor se detiene y envía una notificación de error.
- **Soporte para Múltiples Formatos de Entrada**: Compatible con archivos `.mkv`, `.mp4`, `.avi`, `.mov`, y `.mpeg`.
- **Notificaciones a Telegram**: Se envían notificaciones de bienvenida, detalles de transcodificación (tiempo, velocidad, calidad) y errores durante el proceso.
- **Ajuste Automático de Calidad**: Ajuste optimizado para **priorizar la calidad** según el bitrate del video de entrada usando la variable global **QUALITY**.
- **Docker Siempre Activo**: El contenedor permanece activo y monitorea constantemente el directorio de entrada para detectar nuevos archivos.
- **Manejo de Errores y Verificación de Espacio**: Verifica el espacio en disco antes de la transcodificación y envía notificaciones si el espacio es insuficiente o si hay errores.
- **Mejoras en la Transcodificación**: Se corrigió un error que impedía transcodificar archivos sin pistas de subtítulos definidas.
- **Reducción de Tamaño**: Transcodificación a H.265 (HEVC) para reducir el tamaño del archivo hasta en un 70%.
- **Ideal para Servidores Multimedia**: Compatible con **Plex**, **Jellyfin**, **Emby** y más.
- **Sencillo**: Solo monta las carpetas de entrada y salida, y HWEncoderX hace todo el trabajo.
- **Opciones Personalizables**: Define manualmente la calidad con la variable **QUALITY** y selecciona el **preset** para ajustar la velocidad y calidad según tus necesidades.

## Configuración de Notificaciones de Telegram

Para recibir notificaciones vía Telegram, necesitas configurar un bot y obtener tu **BOT_TOKEN** y **CHAT_ID**. Sigue estos pasos:

1. Crea un nuevo bot en Telegram con [BotFather](https://t.me/botfather) y sigue las instrucciones hasta obtener tu **BOT_TOKEN**.
2. Obtén tu **CHAT_ID** enviando un mensaje a tu bot y utilizando una llamada a la API como:
   ```bash
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
   ```
   Reemplaza `<YOUR_BOT_TOKEN>` con el token de tu bot para encontrar tu **CHAT_ID** en la respuesta.

## Requisitos

Necesitas una GPU compatible con **VAAPI** (Intel/AMD), **NVENC** (NVIDIA) o **Intel Quick Sync (QSV)**. Sin una GPU compatible, el contenedor **no funcionará**.

## Parámetros

| Parámetros | Requisito | Función |
| :----: | :----: | --- |
| `--device /dev/dri` | Obligatorio si se usa QSV o VAAPI | Necesario para habilitar la aceleración por hardware mediante Intel Quick Sync (QSV) y VAAPI. |
| `--gpus all` | Obligatorio si se usa NVENC | Necesario para habilitar la aceleración por hardware mediante NVENC en GPUs NVIDIA. |
| `-v /ruta/a/entrada:/input` | Obligatorio | Reemplaza `/ruta/a/entrada` con la ruta a tu carpeta de entrada, donde se encuentran los videos a transcodificar. |
| `-v /ruta/a/salida:/output` | Obligatorio | Reemplaza `/ruta/a/salida` con la ruta donde se guardarán los archivos transcodificados. (Esto puede ser la misma carpeta de entrada) |
| `-e PRESET=fast` | Opcional | Especifica el valor del preset (`ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower` y `veryslow`). `medium` es el valor por defecto. |
| `-e QUALITY=17` | Opcional | Define manualmente el nivel de calidad para la transcodificación, usado en NVENC, VAAPI y QSV. Si no se define se ajustara la calidad automatíceme |
| `-e BOT_TOKEN` | Opcional si se desean notificaciones | El token de tu bot de Telegram para enviar notificaciones. |
| `-e CHAT_ID` | Opcional si se desean notificaciones | El ID del chat donde se enviarán las notificaciones de Telegram. |
| `-e NOTIFICATIONS` | Opcional | Configura `all` para recibir todas las notificaciones, si no está definido solo se recibirán notificaciones de errores. |

## Instrucciones de Uso

#### - VAAPI

##### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /ruta/a/entrada:/input \
  -v /ruta/a/salida:/output \
  -e QUALITY=18 \                            # Opcional si quieres personalizar la calidad 
  -e PRESET=medium \                         # Opcional si quieres selecioar otro preset
  -e BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx \  # Opcional, (requiere CHAT_ID)
  -e CHAT_ID=xxxxxxxx \                      # Opcional (requiere BOT_TOKEN)
  -e NOTIFICATIONS=all \                     # Opcional si quieres recibir todas las notificaciones
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'

services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - /ruta/a/entrada:/input
      - /ruta/a/salida:/output
    environment:
      # Variables opcionales para las notificaciones
      # Define estas variables solo si deseas recibir notificaciones (los valores deben ir entre comillas)
      BOT_TOKEN: "xxxxxxxxxxxxxxxxxxxxxxxxxx"    # Opcional si quieres recibir notificaciones
      CHAT_ID: "xxxxxxxx"                        # Opcional si quieres recibir notificaciones
      NOTIFICATIONS: "all"                       # Opcional si quieres recibir todas las notificaciones
```

#### - NVIDIA

##### docker run:
```bash
docker run -d --name hwencoderx --gpus all \
  -v /ruta/a/entrada:/input \
  -v /ruta/a/salida:/output \
  -e BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx \    # Opcional si quieres recibir notificaciones
  -e CHAT_ID=xxxxxxxx \                        # Opcional si quieres recibir notificaciones
  -e NOTIFICATIONS=all \                       # Opcional si quieres recibir todas las notificaciones
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'

services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu] 
    volumes:
      - /ruta/a/entrada:/input
      - /ruta/a/salida:/output
    environment:
      # Variables opcionales para las notificaciones
      # Define estas variables solo si deseas recibir notificaciones (los valores deben ir entre comillas)
      BOT_TOKEN: "xxxxxxxxxxxxxxxxxxxxxxxxxx"    # Opcional si quieres recibir notificaciones
      CHAT_ID: "xxxxxxxx"                        # Opcional si quieres recibir notificaciones
      NOTIFICATIONS: "all"                       # Opcional si quieres recibir todas las notificaciones
```

### - Opción Manual:
Esta opción te permite ajustar manualmente la calidad de transcodificación utilizando la variable global **QUALITY**, que se aplica a NVENC, VAAPI y QSV.

#### - VAAPI

##### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /ruta/a/entrada:/input \
  -v /ruta/a/salida:/output \
  -e QUALITY=18 \
  -e PRESET=fast \
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'
services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
    environment:
      - QUALITY=18
      - PRESET=fast
    volumes:
      - /ruta/a/entrada:/input
      - /ruta/a/salida:/output
```

#### - NVIDIA

##### docker run:
```bash
docker run -d --name hwencoderx --gpus all \
  -v /ruta/a/entrada:/input \
  -v /ruta/a/salida:/output \
  -e QUALITY=18 \
  -e PRESET=medium \
  macrimi/hwencoderx:latest
```

##### `docker-compose.yml`:
```yaml
version: '3.3'
services:
  hwencoderx:
    image: macrimi/hwencoderx:latest
    container_name: hwencoderx
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu] 
    environment:
      - QUALITY=18
      - PRESET=medium
    volumes:
      - /ruta/a/entrada:/input
      - /ruta/a/salida:/output
```

## Parámetros

| Parámetros | Requisito | Función |
| :----: | :----: | --- |
| `--device /dev/dri` | Obligatorio si se usa QSV o VAAPI | Necesario para habilitar la aceleración por hardware mediante Intel Quick Sync (QSV) y VAAPI. |
| `--gpus all` | Obligatorio si se usa NVENC | Necesario para habilitar la aceleración por hardware mediante NVENC en GPUs NVIDIA. |
| `-v /ruta/a/entrada:/input` | Obligatorio | Reemplaza `/ruta/a/entrada` con la ruta a tu carpeta de entrada, donde se encuentran los videos a transcodificar. |
| `-v /ruta/a/salida:/output` | Obligatorio | Reemplaza `/ruta/a/salida` con la ruta donde se guardarán los archivos transcodificados. (Esto puede ser la misma carpeta de entrada) |
| `-e PRESET=fast` | Opcional | Especifica el valor del preset (`ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower` y `veryslow`). `medium` es el valor por defecto. |
| `-e QUALITY=17` | Opcional | Define manualmente el nivel de calidad para la transcodificación, usado en NVENC, VAAPI y QSV. Si no se define se ajustara la calidad automatíceme |
| `-e BOT_TOKEN` | Opcional si se desean notificaciones | El token de tu bot de Telegram para enviar notificaciones. |
| `-e CHAT_ID` | Opcional si se desean notificaciones | El ID del chat donde se enviarán las notificaciones de Telegram. |
| `-e NOTIFICATIONS` | Opcional | Configura `all` para recibir todas las notificaciones, si no está definido solo se recibirán notificaciones de errores. |

**Nota:** `/ruta/a/entrada` y `/ruta/a/salida` pueden ser la misma carpeta. Los archivos transcodificados se crearán con el sufijo `_HEVC`.

### Notas adicionales:
HWEncoderX funciona con aceleración por hardware **VAAPI** y **NVENC**. Sin una GPU compatible **Intel**, **AMD**, o **NVIDIA**, el contenedor no funcionará. Los archivos originales no se borran después de la transcodificación.

#### Compatibilidad con Synology/XPenology NAS:
Funciona en cualquier NAS con una GPU **Intel** o **NVIDIA** funcional.

#### Modelos DVA:
En los NAS **DVA** de Synology que usan la **NVIDIA Runtime Library** para **Surveillance Station**, no es posible ejecutar este contenedor ya que no tienen NVIDIA Container Toolkit.

### Licencia
Este proyecto está bajo la Licencia **MIT**. Consulta el archivo `LICENSE` para más detalles.

### Software de terceros
Este contenedor usa **FFmpeg**, licenciado bajo **LGPL 2.1 o posterior**. Consulta la [documentación de FFmpeg](https://ffmpeg.org/legal.html) para más información.

#

<div style="display: flex; justify-content: center; align-items: center;">
  <a href="https://ko-fi.com/G2G313ECAN" target="_blank" style="display: flex; align-items: center; text-decoration: none;">
    <img src="https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/kofi.png" alt="Support me on Ko-fi" style="width:175px; margin-right:65px;"/>
  </a>
</div>
Si este proyecto te ha sido útil, ¡puedes invitarme a un Ko-fi! ¡Gracias! 😊


