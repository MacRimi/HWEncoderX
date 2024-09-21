![HWEncoderX Logo](https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/logo.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Stars](https://img.shields.io/docker/stars/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Image Size](https://img.shields.io/docker/image-size/macrimi/hwencoderx/latest?style=for-the-badge&color=94398d&labelColor=555555&logoColor=ffffff&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)



## HWEncoderX: Video Transcoding with Hardware Acceleration (VAAPI and NVENC)

HWEncoderX is a Docker container that allows you to automatically transcode videos to H.265 (HEVC) using your GPU with hardware acceleration, whether it's **VAAPI** (Intel/AMD) or **NVENC** (NVIDIA). It keeps all audio, subtitles, and chapters intact, while reducing the size of your videos without sacrificing quality.

### Features:

- **Size reduction:** H.265 (HEVC) reduces file size by up to 70%.
- **Fast transcoding:** Hardware acceleration with VAAPI and NVENC.
- **Perfect for media servers:** Ideal for **Plex**, **Jellyfin**, **Emby**, and others.
- **Easy to use:** Just mount the input and output folders, and HWEncoderX does all the work.

### Requirements:

You need a GPU compatible with **VAAPI** (Intel/AMD) or **NVENC** (NVIDIA). Without a compatible GPU, the container **will not work**.

### Usage Instructions:
#

### - VAAPI.

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

#
### - NVIDIA.

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
#### Parameters:

| Parameters | Function |
| :----: | --- |
| `--device /dev/dri` | Required to enable VAAPI hardware acceleration. |
| `--gpus all` | Required to enable NVENC hardware acceleration on NVIDIA GPUs. |
| `-v /path/to/input:/input` | Replace `/path/to/input` with the path to your input folder, where the videos to be transcoded are located. |
| `-v /path/to/output:/output` | Replace `/path/to/output` with the path where the transcoded files will be saved. (Can be the same as the input folder.) |

**Note:** `/path/to/input` and `/path/to/output` can be the same folder. The transcoded files are created with the _HEVC suffix, and if the folders have the same name, they will also be added with the _HEVC suffix to avoid conflicts.

### Additional Notes:
HWEncoderX works with hardware acceleration for **VAAPI** and **NVENC**. Without a compatible **Intel**, **AMD**, or **NVIDIA** GPU, the container will not function. The original files are not deleted after transcoding.

#### Compatibility with Synology/XPenology NAS:
It works on any NAS with a functional **Intel** or **NVIDIA** GPU.

#### DVA Models:
On **DVA NAS models** from Synology that use the **NVIDIA Runtime Library** for **Surveillance Station**, it is not possible to run this container because they do not have NVIDIA Container Toolkit.

### License
This project is licensed under the **MIT License**. See the `LICENSE` file for more details.

### Third-Party Software
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

#
### - NVIDIA.

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


