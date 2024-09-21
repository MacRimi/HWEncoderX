![HWEncoderX Logo](https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/logo.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Stars](https://img.shields.io/docker/stars/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Image Size](https://img.shields.io/docker/image-size/macrimi/hwencoderx/latest?style=for-the-badge&color=94398d&labelColor=555555&logoColor=ffffff&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)



## HWEncoderX: Video Transcoder with GPU Hardware Acceleration (VAAPI and NVENC)

HWEncoderX is a Docker container that allows you to automatically transcode videos to H.265 (HEVC) using your GPU with hardware acceleration, either **VAAPI** (Intel/AMD) or **NVENC** (NVIDIA). It keeps all audio, subtitles, and chapters intact while reducing the size of your videos without quality loss.

### Features:

- **Size reduction:** H.265 (HEVC) reduces file size by up to 70%.
- **Fast transcoding:** Hardware acceleration with VAAPI and NVENC.
- **Ideal for media servers:** Perfect for **Plex**, **Jellyfin**, **Emby**, and more.
- **Simple:** Just mount the input and output folders, and you're set! HWEncoderX does all the work.
- **Automatic quality adjustments:** Detects the original bitrate and adjusts the quality automatically. If no values are specified, the script automatically adjusts CQ or QP to 18 or 23 depending on the input video bitrate: 18 for high bitrate videos and 23 for lower bitrate ones.
- **Customizable options:** Manually define transcoding quality using `CQ` (for NVENC) and `QP` (for VAAPI) and select the **preset** to adjust the speed and quality to your needs. [Learn more about presets here](https://trac.ffmpeg.org/wiki/Encode/H.264#Preset).

### Requirements:

You need a GPU compatible with **VAAPI** (Intel/AMD) or **NVENC** (NVIDIA). Without a compatible GPU, the container **will not work**.

### Usage instructions:

#### - Automatic option:
The container automatically adjusts the output quality based on the input file's bitrate.

##### - VAAPI.

#### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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

#### - NVIDIA.

#### docker run:

```bash
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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

#

#### - Manual option:

This option allows you to manually adjust the transcoding quality using environment variables for settings like CQ (for NVIDIA NVENC) and QP (for VAAPI) and preset.

##### - VAAPI.

#### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e QP=22 \
  -e PRESET=fast \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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
      - QP=22
      - PRESET=fast
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

#### - NVIDIA.

#### docker run:

```bash
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e CQ=18 \
  -e PRESET=slow \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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
      - CQ=18
      - PRESET=slow
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

#

#### Parameters:

| Parameters | Function |
| :----: | --- |
| `--device /dev/dri` | Required to enable hardware acceleration via VAAPI. |
| `--gpus all` | Required to enable hardware acceleration via NVENC on NVIDIA GPUs. |
| `-e PRESET=fast` | Specifies the preset value (`ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower`, and `veryslow`). |
| `-e QP=22` (VAAPI) | Manually define the quality for VAAPI. |
| `-e CQ=22` (NVENC) | Manually define the quality for NVIDIA NVENC. |
| `-v /path/to/input:/input` | Replace `/path/to/input` with the path to your input folder, where the videos to be transcoded are located. |
| `-v /path/to/output:/output` | Replace `/path/to/output` with the path where the transcoded files will be saved. (This can be the same as the input folder) |

**Note:** `/path/to/input` and `/path/to/output` can be the same folder. Transcoded files will be created with the _HEVC suffix.

### Additional Notes:
HWEncoderX works with hardware acceleration **VAAPI** and **NVENC**. Without a compatible **Intel**, **AMD**, or **NVIDIA** GPU, the container will not work. The original files are not deleted after transcoding.

#### Synology/XPenology NAS Compatibility:
It works on any NAS with a functional **Intel** or **NVIDIA** GPU.

#### DVA Models:
On **DVA** Synology NAS that use the **NVIDIA Runtime Library** for **Surveillance Station**, this container cannot be run as it lacks NVIDIA Container Toolkit support.

### License
This project is licensed under the **MIT License**. See the `LICENSE` file for more details.

### Third-party software
This container uses **FFmpeg**, licensed under **LGPL 2.1 or later**. See the [FFmpeg documentation](https://ffmpeg.org/legal.html) for more information.


#

-- Español

## HWEncoderX: Transcodificador de video con Aceleración por Hardware GPU (VAAPI y NVENC)

HWEncoderX es un contenedor Docker que te permite transcodificar videos a H.265 (HEVC) automáticamente usando tu GPU con aceleración por hardware, ya sea **VAAPI** (Intel/AMD) o **NVENC** (NVIDIA). Mantiene todos los audios, subtítulos y capítulos intactos, mientras reduce el tamaño de tus videos sin perder calidad.

### Características:

- **Reducción de tamaño:** H.265 (HEVC) reduce el tamaño del archivo hasta un 70%.
- **Transcodificación rápida:** Aceleración por hardware con VAAPI y NVENC.
- **Ideal para servidores multimedia:** Perfecto para **Plex**, **Jellyfin**, **Emby** y otros.
- **Sencillo:** Solo monta las carpetas de entrada y salida, ¡y listo! HWEncoderX hace todo el trabajo.
- **Ajustes automáticos:** Detecta la tasa de bits original y ajusta la calidad automáticamente. Si no se especifican valores, el script ajusta automáticamente CQ o QP a 18 o 23, según el bitrate del video de entrada: 18 para videos con bitrate alto y 23 para videos con bitrate más bajo.
- **Opciones personalizadas:** Define manualmente la calidad de transcodificación usando `CQ` (para NVENC) y `QP` (para VAAPI) y selecciona el **preset** para adaptar la velocidad y la calidad a tus necesidades. [Aquí puedes aprender más sobre ellos](https://trac.ffmpeg.org/wiki/Encode/H.264#Preset).


### Requisitos:

Necesitas una GPU compatible con **VAAPI** (Intel/AMD) o **NVENC** (NVIDIA). Sin una GPU compatible, el contenedor **no funcionará**.

### Instrucciones de uso:

#### - Opción automática:
El contenedor ajusta automáticamente la calidad de salida basándose en la tasa de bits del archivo de entrada.

##### - VAAPI.

#### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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

#### - NVIDIA.

#### docker run:

```bash
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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

#

#### - Opción manual:

Esta opción permite ajustar manualmente la calidad de transcodificación usando variables de entorno para valores como CQ (para NVIDIA NVENC) y QP (para VAAPI) y preset.

##### - VAAPI.

#### docker run:
```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e QP=22 \
  -e PRESET=fast \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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
      - QP=22
      - PRESET=fast
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

#### - NVIDIA.

#### docker run:

```bash
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e CQ=18 \
  -e PRESET=slow \
  macrimi/hwencoderx:latest
```

#### `docker-compose.yml`:

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
      - CQ=18
      - PRESET=slow
    volumes:
      - /path/to/input:/input
      - /path/to/output:/output
```

#

#### Parámetros:

| Parámetros | Función |
| :----: | --- |
| `--device /dev/dri` | Necesario para habilitar la aceleración por hardware VAAPI. |
| `--gpus all` | Necesario para habilitar la aceleración por hardware NVENC en GPU NVIDIA. |
| `-e PRESET=fast` | Especifica el valor del preset (`ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower` y `veryslow`). |
| `-e QP=22` (VAAPI) | Define manualmente la calidad para VAAPI. |
| `-e CQ=22` (NVENC) | Define manualmente la calidad para NVIDIA NVENC. |
| `-v /path/to/input:/input` | Reemplaza `/path/to/input` con la ruta a tu carpeta de entrada, donde estarán los videos a transcodificar. |
| `-v /path/to/output:/output` | Reemplaza `/path/to/output` con la ruta donde se guardarán los archivos transcodificados. (puede ser la misma carpeta de entrada) |

**Nota:** `/path/to/input` y `/path/to/output` pueden ser la misma carpeta. Los archivos transcodificados se crean con el sufijo _HEVC.

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


