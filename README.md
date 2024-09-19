![HWEncoderX Logo](https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/logo.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Stars](https://img.shields.io/docker/stars/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Image Size](https://img.shields.io/docker/image-size/macrimi/hwencoderx/latest?style=for-the-badge&color=94398d&labelColor=555555&logoColor=ffffff&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)



## HWEncoderX: Hardware-Accelerated Video Transcoder (VAAPI and NVENC)

This Docker container provides a powerful yet simple solution for automatic video transcoding to H.265 (HEVC) using GPU hardware acceleration, supporting both **VAAPI** (Intel) and **NVENC** (NVIDIA), while preserving the original quality of all audio tracks, subtitles, and chapters present in the source file.

Using the H.265 (HEVC) codec allows for approximately 70% compression without noticeable quality loss. This Docker container is designed to automate file conversion without requiring complex configurations. Simply mount the input and output folders, and the container will handle the entire process.

### Features:

- **File Size Reduction:** Drastically reduces video file sizes without compromising quality.
- **Hardware Acceleration (VAAPI and NVENC):** GPU-based transcoding is powered by both VAAPI (Intel) and NVENC (NVIDIA), improving conversion speed.
- **Ideal for Media Servers:** Perfect for users managing large video libraries or media servers like Plex, Jellyfin, or Emby.
- **Simplicity:** You only need to configure the input and output paths; the container will automatically manage the conversion process.

### Requirements:

This container **requires** a graphics card compatible with **VAAPI or NVENC** to function. If your system does not have a GPU with VAAPI or NVENC support, the container will not be able to perform the transcoding.


### Usage Instructions:
#

### - VAAPI.

#### Docker run:

```
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```
#### Docker Compose

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

#### Docker run:

```
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest

```

#### Docker Compose

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

#### Parameters:

| Parameter | Function |
| :----: | --- |
| `--device /dev/dri:/dev/dri:` | This is required to enable VAAPI hardware acceleration. |
| `--gpus all:` | Necessary to enable NVENC hardware acceleration on NVIDIA GPUs.. |
| `-v /path/to/input:/input:` | Replace `/path/to/input` with the path to your input folder, where the videos to be transcoded are located. |
| `-v /path/to/output:/output:` | Replace `/path/to/output` with the path where the transcoded files will be saved. (It can be the same as the input folder) |

**Note:** `/path/to/input` and `/path/to/output` can be the same folder. Transcoded files will be created with the _HEVC suffix, and if the folders have the same name, they will also have the _HEVC suffix to avoid conflicts.

### Additional Notes:

This container is specifically designed to take advantage of VAAPI hardware acceleration. If the system running the container does not have a compatible GPU, **the container will not function.** The container does not delete the original files after transcoding.

### License

This project is licensed under the MIT License. For more details, see the `LICENSE` file.

### Third-Party Software

This container uses FFmpeg, which is licensed under the LGPL (Lesser General Public License) version 2.1 or later. For more information about FFmpeg’s license and access to its source code, please refer to the [FFmpeg Legal Documentation](https://ffmpeg.org/legal.html).

#

-- Español
## HWEncoderX: Transcodificador de video con Aceleración por Hardware GPU (VAAPI y NVENC)

Este contenedor Docker ofrece una solución potente y sencilla para la transcodificación automática de archivos de video a H.265 (HEVC) utilizando aceleración por hardware de GPU, tanto **VAAPI** (Intel) como **NVENC** (NVIDIA), manteniendo la calidad original de los audios, subtítulos y capítulos presentes en el archivo original.

El uso del códec H.265 (HEVC) permite una compresión aproximada del 70% sin pérdida apreciable de calidad. Este contenedor Docker está diseñado para automatizar la conversión de tus archivos sin necesidad de configuraciones complejas. Solo monta las carpetas de entrada y salida, y el contenedor se encargará de todo el proceso.

### Características:

- **Reducción de tamaño:** Reduce drásticamente el tamaño de los archivos de video sin sacrificar calidad.
- **Aceleración por hardware (VAAPI y NVENC):** La transcodificación por GPU se realiza gracias al soporte tanto de VAAPI (Intel) como de NVENC (NVIDIA), mejorando la velocidad de conversión.
- **Ideal para servidores multimedia:** Perfecto para quienes gestionan grandes bibliotecas de video o servidores multimedia como Plex, Jellyfin o Emby.
- **Simplicidad:** Solo necesitas configurar las rutas de entrada y salida; el contenedor gestionará la conversión automáticamente.

### Requisitos:

Este contenedor **requiere** una tarjeta gráfica compatible con **VAAPI o NVENC** para funcionar. Si tu sistema no tiene una GPU con soporte para VAAPI o NVENC, el contenedor no podrá realizar la transcodificación.


### Instrucciones de uso:
#

### - VAAPI.

#### Docker run:

```
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```
#### Docker Compose

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

#### Docker run:

```
docker run -d --name hwencoderx --gpus all \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest

```

#### Docker Compose

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
| `--gpus all` | Necesario para habilitar la aceleración por hardware NVENC en GPU NVIDIA.. |
| `-v /path/to/input:/input` | Reemplaza `/path/to/input` con la ruta a tu carpeta de entrada, donde estarán los videos a transcodificar. |
| `-v /path/to/output:/output` | Reemplaza `/path/to/output` con la ruta donde se guardarán los archivos transcodificados. (puede ser la misma carpeta de entrada) |


**Nota:** `/path/to/input` y `/path/to/output` pueden ser la misma carpeta. Los archivos transcodificados se crean con el sufijo _HEVC, y si las carpetas tienen el mismo nombre, también se agregarán con el sufijo _HEVC para evitar conflictos.

### Notas adicionales:
Este contenedor está diseñado específicamente para aprovechar la aceleración por hardware VAAPI. Si el sistema en el que estás corriendo el contenedor no tiene una GPU compatible, **el contenedor no funcionará.**
El contenedor no borra los archivos originales después de la transcodificación.

**Compatibilidad con Synology/XPenology NAS:**
Este contenedor es compatible con cualquier dispositivo Synology/XPenology NAS que tenga una GPU Intel o NVIDIA funcional para aprovechar la aceleración por hardware.

### Licencia

Este proyecto está licenciado bajo la Licencia MIT. Para más detalles, consulta el archivo `LICENSE`.

### Terceros

Este contenedor utiliza FFmpeg, que está licenciado bajo la LGPL (Lesser General Public License) versión 2.1 o posterior. Para obtener más información sobre la licencia de FFmpeg y el acceso a su código fuente, consulta la [documentación de FFmpeg](https://ffmpeg.org/legal.html).


#

<div style="display: flex; justify-content: center; align-items: center;">
  <a href="https://ko-fi.com/G2G313ECAN" target="_blank" style="display: flex; align-items: center; text-decoration: none;">
    <img src="https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/kofi.png" alt="Support me on Ko-fi" style="width:175px; margin-right:65px;"/>
  </a>
</div>
Si este proyecto te ha sido útil, ¡puedes invitarme a un Ko-fi! ¡Gracias! 😊


