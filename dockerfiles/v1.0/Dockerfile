FROM ubuntu:24.04

# Dependencias necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    vainfo \
    intel-media-va-driver-non-free \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Establezco el directorio de trabajo
WORKDIR /app

# Copio el script en el contenedor
COPY transcodificar.sh /app/transcodificar.sh

# Permisos de ejecución al script
RUN chmod +x /app/transcodificar.sh

# Ejecución por defecto cuando se ejecuta el contenedor
CMD ["/app/transcodificar.sh"]
