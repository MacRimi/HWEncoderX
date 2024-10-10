# Imagen Ubuntu
FROM ubuntu:24.04

ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias de VAAPI, NVIDIA, QuickSync, ffmpeg, y curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    libx264-dev \
    libx265-dev \
    ffmpeg \
    vainfo \
    intel-media-va-driver-non-free \
    i965-va-driver \
    libva-drm2 \
    libva-x11-2 \
    libmfx1 \
    ca-certificates \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Establecer directorio de trabajo
WORKDIR /app

# Copiar el script de transcodificación
COPY transcodificar.sh /app/transcodificar.sh
RUN chmod +x /app/transcodificar.sh

# Comando por defecto al iniciar el contenedor
CMD ["/app/transcodificar.sh"]
