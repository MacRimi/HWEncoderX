![HWEncoderX Logo](https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/logo.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Stars](https://img.shields.io/docker/stars/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Image Size](https://img.shields.io/docker/image-size/macrimi/hwencoderx/latest?style=for-the-badge&color=94398d&labelColor=555555&logoColor=ffffff&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)


## HWEncoderX: Hardware-Accelerated Transcoder (VAAPI)

**This Docker container offers an efficient and simple solution for automatic video file transcoding from H.264 to H.265 using hardware acceleration (VAAPI).** It is ideal for reducing video file sizes without compromising quality and preserving compatibility with all audio, subtitles, and chapters present in the original file.

The use of H.265 (HEVC) allows for significantly higher compression without noticeable quality loss, resulting in smaller files that are better optimized for storage or streaming. With this Docker container, you can automate the conversion of your files without the need for complex configurations. Just mount the input and output folders, and the container will handle the entire process.

### Benefits of this Docker:
- **File Size Reduction:** Drastically reduces video file sizes without sacrificing quality.
- **Hardware Acceleration (VAAPI):** Transcoding is handled by the GPU through VAAPI support.
- **Ideal for Media Servers:** Perfect for those managing large video libraries or media servers such as Plex, Jellyfin, or Emby.
- **Simplicity:** You only need to set the input and output paths; the container will automatically manage the conversion process.

### Requirements:
This container **requires** a VAAPI-compatible graphics card to function. If your system does not have a GPU with VAAPI support, the container will not be able to perform the transcoding.

### Usage Instructions:

#### docker run:

```bash
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```

#### Using Docker Compose

If you prefer to use Docker Compose, here’s an example `docker-compose.yml` file:

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

#### Explanation of Parameters:

- `--device /dev/dri:/dev/dri:` This is required to enable VAAPI hardware acceleration.
- `-v /path/to/input:/input:` Replace `/path/to/input` with the path to your input folder, where the videos to be transcoded are located.
- `-v /path/to/output:/output:` Replace `/path/to/output` with the path where the transcoded files will be saved.

**Note:** `/path/to/input` and `/path/to/output` can be the same folder. Transcoded files will be created with the _HEVC suffix, and if the folders have the same name, they will also have the _HEVC suffix to avoid conflicts.

### Additional Notes:

This container is specifically designed to take advantage of VAAPI hardware acceleration. If the system running the container does not have a compatible GPU, **the container will not function.** The container does not delete the original files after transcoding.


#

-- Español
## HWEncoderX: Transcodificador con Aceleración por Hardware (VAAPI)

**Este contenedor Docker ofrece una solución eficiente y sencilla para la transcodificación automática de archivos de video en formato H.264 a H.265 utilizando aceleración por hardware (VAAPI).** Ideal para reducir el tamaño de los videos sin comprometer la calidad y preservando la compatibilidad de todos los audios, subtítulos y capítulos presentes en el archivo original.

El uso de H.265 (HEVC) permite una compresión significativamente mayor sin pérdida apreciable de calidad, lo que resulta en archivos más pequeños y mejor optimizados para el almacenamiento o la transmisión. Con este contenedor Docker, puedes automatizar la conversión de tus archivos sin necesidad de configuraciones complejas. Solo monta las carpetas de entrada y salida, y el contenedor se encargará de todo el proceso.

### Ventajas de este Docker:
- **Reducción de tamaño:** Reduce drásticamente el tamaño de los archivos de video sin sacrificar calidad.
- **Aceleración por hardware (VAAPI):** La transcodificación por GPU se realiza gracias al soporte de VAAPI.
- **Ideal para servidores multimedia:** Es perfecto para aquellos que gestionan grandes bibliotecas de video o servidores multimedia como Plex, Jellyfin o Emby.
- **Simplicidad:** Solo necesitas configurar las rutas de entrada y salida; el contenedor gestionará la conversión automáticamente.

### Requisitos:
Este contenedor **requiere** una tarjeta gráfica compatible con VAAPI para funcionar. Si tu sistema no tiene una GPU con soporte para VAAPI, el contenedor no podrá realizar la transcodificación.

### Instrucciones de uso:

#### docker run:

```
docker run -d --name hwencoderx --device /dev/dri:/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  macrimi/hwencoderx:latest
```


#### Uso con Docker Compose

Si prefieres usar Docker Compose, aquí tienes un archivo `docker-compose.yml` de ejemplo:

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

#### Parámetros:

| Parametro | Funcion |
| :----: | --- |
| `--device /dev/dri` | Necesario para habilitar la aceleración por hardware VAAPI. |
| `-v /path/to/input:/input` | Reemplaza `/path/to/input` con la ruta a tu carpeta de entrada, donde estarán los videos a transcodificar. |
| `-v /path/to/output:/output` | Reemplaza `/path/to/output` con la ruta donde se guardarán los archivos transcodificados. (puede ser la misma carpeta de entrada) |


**Nota:** `/path/to/input` y `/path/to/output` pueden ser la misma carpeta. Los archivos transcodificados se crean con el sufijo _HEVC, y si las carpetas tienen el mismo nombre, también se agregarán con el sufijo _HEVC para evitar conflictos.

### Notas adicionales:
Este contenedor está diseñado específicamente para aprovechar la aceleración por hardware VAAPI. Si el sistema en el que estás corriendo el contenedor no tiene una GPU compatible, **el contenedor no funcionará.**
El contenedor no borra los archivos originales después de la transcodificación.
#

<div style="display: flex; justify-content: center; align-items: center;">
  <a href="https://ko-fi.com/G2G313ECAN" target="_blank" style="display: flex; align-items: center; text-decoration: none;">
    <img src="https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/kofi.png" alt="Support me on Ko-fi" style="width:175px; margin-right:65px;"/>
  </a>
</div>
Si este proyecto te ha sido útil, ¡puedes invitarme a un Ko-fi! ¡Gracias! 😊


