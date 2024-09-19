#!/bin/bash

# Variables
INPUT_DIR="${INPUT_DIR:-/input}/"
OUTPUT_DIR="/output"
HW_DEVICE="/dev/dri/renderD128"  # Ajusta esto si tu dispositivo de VAAPI es diferente
LOG_FILE="$OUTPUT_DIR/transcoding_log.txt"

# Función para transcodificar archivos
transcode_file() {
  local input_file="$1"
  local output_file="$2"

  # Comando FFmpeg para transcodificar usando VAAPI
  ffmpeg -hwaccel vaapi -hwaccel_device "$HW_DEVICE" -hwaccel_output_format vaapi \
    -i "$input_file" -map 0:v:0 -map 0:a -map 0:s -map 0:d? -c:v hevc_vaapi -c:a copy -c:s copy -c:d copy \
    "$output_file"

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

# Función para procesar archivos y conserver estructura de carpetas
process_directory() {
  local current_dir="$1"
  local relative_path="${current_dir#$INPUT_DIR}"

  # Si input y output son el mismo directorio, añadir "_HEVC" solo a la carpeta raíz
  if [ "$INPUT_DIR" == "$OUTPUT_DIR" ]; then
    if [ "$relative_path" == "" ]; then
      relative_path="$(basename "$current_dir")_HEVC"
    fi
  fi

  local target_dir="$OUTPUT_DIR/$relative_path"
  local has_video=false

  # Verificar si hay archivos de video en la carpeta
  for item in "$current_dir"/*; do
    if [ -f "$item" ] && [[ "$item" == *.mkv ]]; then
      has_video=true
      break
    fi
  done

  # Si se encuentran archivos de video, crear la carpeta en output
  if [ "$has_video" = true ]; then
    mkdir -p "$target_dir"

    # Procesar los archivos de video
    for item in "$current_dir"/*; do
      if [ -f "$item" ]; then
        if [[ "$item" == *.mkv ]]; then
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
      fi
    done
  fi

  # Procesar subdirectorios recursivamente
  for item in "$current_dir"/*; do
    if [ -d "$item" ]; then
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
