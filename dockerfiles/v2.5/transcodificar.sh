#!/bin/bash

# Variables
INPUT_DIR="${INPUT_DIR:-/input}"
OUTPUT_DIR="/output"
HW_DEVICE_VAAPI="/dev/dri/renderD128"
LOG_FILE="$OUTPUT_DIR/transcoding_log.txt"
USE_NVIDIA=false

# Valores por defecto para preset, QP (para VAAPI) y CQ (para NVENC)
PRESET="${PRESET:-medium}"  # Valor predeterminado si el usuario no lo define
QP="${QP:-default_value}"  # Usado para VAAPI en lugar de CRF
CQ="${CQ:-default_value}"    # Usado para NVENC

# Detectar si hay una GPU NVIDIA disponible
if nvidia-smi > /dev/null 2>&1; then
  USE_NVIDIA=true
  echo "GPU NVIDIA detectada, se usará NVIDIA NVENC para la transcodificación." >> "$LOG_FILE"
else
  echo "No se detectó una GPU NVIDIA. Se usará VAAPI para la transcodificación." >> "$LOG_FILE"
fi

# Obtener calidad del archivo original
get_original_quality() {
  local input_file="$1"
  # Extraer la tasa de bits del archivo
  bitrate=$(ffmpeg -i "$input_file" 2>&1 | grep "bitrate" | awk '{print $6}')
  codec=$(ffmpeg -i "$input_file" 2>&1 | grep Video | grep -oP '(?<=Video: )[^,]+')

  echo "Tasa de bits original: $bitrate" >> "$LOG_FILE"
  echo "Códec original: $codec" >> "$LOG_FILE"

  # Ajustar valores de QP y CQ en función de la tasa de bits original
  if [[ "$QP" == "default_value" ]] && [[ "$USE_NVIDIA" = false ]]; then
    if [[ "$bitrate" -gt 5000 ]]; then
      QP=18  # Usar QP bajo para mantener la calidad en archivos con mayor tasa de bits
    else
      QP=23  # Usar QP más alto para archivos con menor tasa de bits
    fi
    echo "QP ajustado automáticamente a $QP en función de la tasa de bits original." >> "$LOG_FILE"
  fi

  if [[ "$CQ" == "default_value" ]] && [[ "$USE_NVIDIA" = true ]]; then
    if [[ "$bitrate" -gt 5000 ]]; then
      CQ=18
    else
      CQ=23
    fi
    echo "CQ ajustado automáticamente a $CQ en función de la tasa de bits original." >> "$LOG_FILE"
  fi
}

# Función para transcodificar archivos
transcode_file() {
  local input_file="$1"
  local output_file="$2"

  # Crear el directorio de salida si no existe
  mkdir -p "$(dirname "$output_file")"

  # Obtener calidad del archivo original para ajustar QP o CQ
  get_original_quality "$input_file"

  # Incluir en el log el tipo de transcodificación que se va a utilizar
  if [ "$USE_NVIDIA" = true ]; then
    echo "Iniciando transcodificación con NVIDIA NVENC para: $input_file" >> "$LOG_FILE"
    # Comando FFmpeg para transcodificar usando NVIDIA NVENC
    ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i "$input_file" -map 0:v:0 -map 0:a -map 0:s -map 0:d? \
      -c:v hevc_nvenc -preset "$PRESET" -cq "$CQ" -c:a copy -c:s copy -c:d copy "$output_file"
  else
    echo "Iniciando transcodificación con VAAPI para: $input_file" >> "$LOG_FILE"
    # Comando FFmpeg para transcodificar usando VAAPI (usando QP en lugar de CRF)
    ffmpeg -hwaccel vaapi -hwaccel_device "$HW_DEVICE_VAAPI" -hwaccel_output_format vaapi -i "$input_file" \
      -map 0:v:0 -map 0:a -map 0:s -map 0:d? -c:v hevc_vaapi -preset "$PRESET" -qp "$QP" \
      -c:a copy -c:s copy -c:d copy "$output_file"
  fi

  # Verificar la transcodificación
  if [ $? -eq 0 ]; then
    echo "Transcodificación completada para: $input_file" >> "$LOG_FILE"
  else
    echo "Error al transcodificar: $input_file" >> "$LOG_FILE"
  fi
}

# Función para comprobar si el archivo ya está en H.265 (HEVC)
is_hevc() {
  local file="$1"
  codec=$(ffmpeg -i "$file" 2>&1 | grep Video | grep -oP '(?<=Video: )[^,]+')

  codec=$(echo "$codec" | tr '[:upper:]' '[:lower:]')

  if [[ "$codec" == *"hevc"* ]]; then
    return 0  # Es HEVC
  else
    return 1  # No es HEVC
  fi
}

# Función para procesar archivos y conservar la estructura de carpetas
process_directory() {
  local current_dir="$1"
  local relative_path="${current_dir#$INPUT_DIR}"

  # Si input y output son el mismo directorio, añadir "_HEVC" solo a la carpeta raíz
  if [ "$INPUT_DIR" == "$OUTPUT_DIR" ]; then
    if [ "$relative_path" == "" ]; then
      relative_path="$(basename "$current_dir")_HEVC"
    fi
  fi

  # Si input y output son directorios diferentes, mantener los nombres de las carpetas
  local target_dir="$OUTPUT_DIR/$relative_path"
  local has_video=false

  # Procesar los archivos de video en la carpeta actual
  for item in "$current_dir"/*; do
    if [ -f "$item" ] && [[ "$item" == *.mkv || "$item" == *.mp4 || "$item" == *.avi || "$item" == *.mov || "$item" == *.mpeg ]]; then
      has_video=true
      # Solo agregar "_HEVC" al nombre del archivo transcodificado, no a la carpeta
      local output_file="$target_dir/$(basename "$item" .mkv)_HEVC.mkv"
      if [ ! -f "$output_file" ]; then
        if is_hevc "$item"; then
          echo "Archivo $item ya está en HEVC. No se transcodificará." >> "$LOG_FILE"
        else
          echo "Transcodificando archivo: $item" >> "$LOG_FILE"
          transcode_file "$item" "$output_file"
        fi
      else
        echo "Archivo $output_file ya existe. No se transcodificará." >> "$LOG_FILE"
      fi
    fi
  done

  # Procesar subdirectorios recursivamente
  for item in "$current_dir"/*; do
    if [ -d "$item" ]; then
      echo "Procesando subdirectorio: $item" >> "$LOG_FILE"
      process_directory "$item"
    fi
  done
}

# Crear o reiniciar el archivo de log
echo "Iniciando transcodificación - $(date)" > "$LOG_FILE"

# Iniciar el proceso desde el directorio de entrada
process_directory "$INPUT_DIR"

# Finalizar y escribir log
echo "No quedan más archivos por procesar. Apagando contenedor - $(date)" >> "$LOG_FILE"
