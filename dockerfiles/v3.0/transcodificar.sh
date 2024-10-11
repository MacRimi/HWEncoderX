#!/bin/bash

# Variables
INPUT_DIR="${INPUT_DIR:-/input}"
OUTPUT_DIR="/output"
HW_DEVICE_VAAPI="/dev/dri/renderD128"
LOG_FILE="$OUTPUT_DIR/transcoding_log.txt"
USE_NVIDIA=false
USE_QSV=false
USE_VAAPI=false
FAILED_FILES_LOG="/app/failed_files.log"

# Telegram settings
BOT_TOKEN="${BOT_TOKEN:-}"                # Token del bot,
CHAT_ID="${CHAT_ID:-}"                    # Chat ID
NOTIFICATIONS="${NOTIFICATIONS:-errors}"  # Tipo de notificaciones: 'all' o 'errors'
WELCOME_SENT_FILE="/app/.welcome_sent"

# Valores por defecto 
PRESET="${PRESET:-medium}"
QUALITY="${QUALITY:-default_value}"

# Configuración de la zona horaria
TZ="${TZ:-Europe/Madrid}"
export TZ=$TZ

# -----------------------------------------------------------------

# Función para enviar notificación a Telegram
send_telegram_notification() {
  local message="$1"
  if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message" > /dev/null
  fi
}

# Función para enviar una imagen a Telegram
send_telegram_photo() {
  local photo_url="$1"
  if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" -d chat_id="$CHAT_ID" -d photo="$photo_url" > /dev/null
  fi
}

# Mensaje de bienvenida
if [[ ! -f "$WELCOME_SENT_FILE" ]]; then
  send_telegram_notification "¡Bienvenido/a al bot HWEncoderX! Este bot te ayudará a monitorear la transcodificación de archivos de video. Puedes usar la siguiente imagen como foto de perfil para el bot si lo deseas."
  send_telegram_photo "https://github.com/MacRimi/HWEncoderX/blob/main/images/logo.png"
  touch "$WELCOME_SENT_FILE"
fi

# -----------------------------------------------------------------

# Detectar si hay una GPU NVIDIA disponible
detect_hardware() {
  USE_NVIDIA=false
  USE_QSV=false
  USE_VAAPI=false

  hwaccels=$(ffmpeg -hwaccels 2>&1)

  if nvidia-smi > /dev/null 2>&1; then
    USE_NVIDIA=true
    echo ">> HWEncoderX 3.0 — NVIDIA NVENC - $(date '+%Y-%m-%d %H:%M:%S') <<" >> "$LOG_FILE"
    send_telegram_notification "HWEncoderX 3.0 — Tegnologia NVIDIA NVENC"
  elif echo "$hwaccels" | grep -q "qsv"; then
    USE_QSV=true
    echo ">> HWEncoderX 3.0 — Intel QuickSync - $(date '+%Y-%m-%d %H:%M:%S') <<" >> "$LOG_FILE"
    send_telegram_notification "HWEncoderX 3.0 — Tegnologia Intel QuickSync"
  elif echo "$hwaccels" | grep -q "vaapi"; then
    USE_VAAPI=true
    echo ">> HWEncoderX 3.0 — VAAPI - $(date '+%Y-%m-%d %H:%M:%S') <<" >> "$LOG_FILE"
    send_telegram_notification "HWEncoderX 3.0 — Tegnologia VAAPI"
  else
    echo ">> HWEncoderX 3.0 — No se encontró hardware de aceleración. Deteniendo contenedor - $(date '+%Y-%m-%d %H:%M:%S') <<" >> "$LOG_FILE"
    send_telegram_notification "HWEncoderX 3.0 — No se encontró hardware de aceleración. Deteniendo contenedor."
    exit 1  # Detener el Docker
  fi
  echo " " >> "$LOG_FILE"
}

# Inicializar la detección del hardware
detect_hardware

# -----------------------------------------------------------------

# Inicializar la lista de archivos fallidos si no existe
initialize_failed_files_log() {
  if [ ! -f "$FAILED_FILES_LOG" ]; then
    touch "$FAILED_FILES_LOG"
  fi
}

initialize_failed_files_log

# -----------------------------------------------------------------

# Verificar si un archivo ha fallado previamente
is_file_failed() {
  local file="$1"
  if grep -Fxq "$file" "$FAILED_FILES_LOG"; then
    return 0  # El archivo está en la lista de fallidos
  fi
  return 1  # El archivo no está en la lista de fallidos
}

# -----------------------------------------------------------------

# Registrar un archivo fallido
register_failed_file() {
  local file="$1"
  echo "$file" >> "$FAILED_FILES_LOG"
}

# -----------------------------------------------------------------

# Comprobación de estado de archivo
is_file_ready() {
  local file="$1"
  local initial_size=$(stat --format="%s" "$file")
  sleep 10
  local new_size=$(stat --format="%s" "$file")

  # Revisar si el archivo no ha cambiado en tamaño y no está siendo utilizado
  if [ "$initial_size" -eq "$new_size" ] && ! lsof "$file" > /dev/null 2>&1; then
    return 0  # El archivo está listo
  fi
  return 1  # El archivo no está listo
}

# -----------------------------------------------------------------

# Obtener calidad del archivo original
get_original_quality() {
  local input_file="$1"

  QUALITY="default_value"

  bitrate_kbps=$(ffmpeg -i "$input_file" 2>&1 | grep "bitrate" | awk '{print $6}')

  # Comprobar si el valor del bitrate es un número válido y mayor que cero
  if ! [[ "$bitrate_kbps" =~ ^[0-9]+$ ]] || [ "$bitrate_kbps" -eq 0 ]; then
    QUALITY=18
    echo "Error al obtener la tasa de bits para $input_file. Usando valor de calidad predeterminado QUALITY=$QUALITY" >> "$LOG_FILE"
    return
  fi
  # Convertir el bitrate a Mbps
  bitrate=$((bitrate_kbps / 1000))

  if [[ "$QUALITY" == "default_value" ]]; then
    if (( bitrate > 40 )); then
       QUALITY=15
    elif (( bitrate > 35 )); then
       QUALITY=16
    elif (( bitrate > 30 )); then
       QUALITY=17
    elif (( bitrate > 25 )); then
      QUALITY=18
    elif (( bitrate > 20 )); then
      QUALITY=19
    elif (( bitrate > 15 )); then
      QUALITY=20
    elif (( bitrate > 10 )); then
      QUALITY=21
    elif (( bitrate > 5 )); then
      QUALITY=22
    else
      QUALITY=23
    fi
  fi
}

# -----------------------------------------------------------------

# Función para transcodificar archivos
transcode_file() {
  local input_file="$1"
  local output_file="$2"

  # Crear el directorio de salida si no existe
  mkdir -p "$(dirname "$output_file")"

  # Obtener calidad del archivo original
  get_original_quality "$input_file"
  
  # Proceso de transcodificación
  local start_time=$(date +%s)
  local ffmpeg_output
  
  if [ "$USE_NVIDIA" = true ]; then
    echo "Procesando: $input_file | Calidad original:$bitrate Mbps QUALITY=$QUALITY Preset $PRESET" >> "$LOG_FILE"
    # Comando FFmpeg para transcodificar usando NVIDIA NVENC
    ffmpeg_output=$(ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -i "$input_file" -map 0:v:0 -map 0:a -map 0:s? -map 0:d? \
      -c:v hevc_nvenc -preset "$PRESET" -cq "$QUALITY" -c:a copy -c:s copy -c:d copy "$output_file" 2>&1)

  elif [ "$USE_QSV" = true ]; then
    echo "Procesando: $input_file | Calidad original:$bitrate Mbps QUALITY=$QUALITY Preset $PRESET" >> "$LOG_FILE"
    # Comando FFmpeg para transcodificar usando QuickSync
    ffmpeg_output=$(ffmpeg -y -hwaccel qsv -qsv_device "$HW_DEVICE_VAAPI" -i "$input_file" -map 0:v:0 -map 0:a -map 0:s? -map 0:d? \
      -c:v hevc_qsv -preset "$PRESET" -q:v "$QUALITY" -c:a copy -c:s copy -c:d copy "$output_file" 2>&1)
      
  elif [ "$USE_VAAPI" = true ]; then
    echo "Procesando: $input_file | Calidad original:$bitrate Mbps QUALITY=$QUALITY Preset $PRESET" >> "$LOG_FILE"
    # Comando FFmpeg para transcodificar usando VAAPI (usando QP en lugar de CRF)
    ffmpeg_output=$(ffmpeg -y -hwaccel vaapi -hwaccel_device "$HW_DEVICE_VAAPI" -hwaccel_output_format vaapi -i "$input_file" \
      -map 0:v:0 -map 0:a -map 0:s? -map 0:d? -c:v hevc_vaapi -preset "$PRESET" -qp "$QUALITY" \
      -c:a copy -c:s copy -c:d copy "$output_file" 2>&1)
  fi

  # Verificar la transcodificación
  if [ $? -eq 0 ]; then
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    speed=$(grep -o "speed=[0-9.]\+x" <<< "$ffmpeg_output" | tail -n 1 | cut -d'=' -f2)

    # Comprobar si la velocidad se obtuvo correctamente
    if [ -z "$speed" ]; then
      speed="N/A"
    fi

    # Obtener bitrate final usando ffmpeg
    final_bitrate_kbps=$(ffmpeg -i "$output_file" 2>&1 | grep "bitrate" | awk '{print $6}')
    final_bitrate=$((final_bitrate_kbps / 1000))

    # Calcular la reducción de tamaño
    original_size=$(stat --format="%s" "$input_file")
    final_size=$(stat --format="%s" "$output_file")

    if (( original_size > 0 )); then
      compression_percentage=$(awk "BEGIN {printf \"%.2f\", (1 - ($final_size / $original_size)) * 100}")
    else
      compression_percentage="N/A"
    fi

    echo "Transcodificacion completada: $output_file | Duracion: $((total_time / 60)):$(($total_time % 60)) min. | Velocidad: ${speed} | Calidad final: ${final_bitrate} Mbps | Reduccion del: ${compression_percentage}%" >> "$LOG_FILE"
    echo "-------------------------------" >> "$LOG_FILE"
    if [[ "$NOTIFICATIONS" == "all" ]]; then
      send_telegram_notification "Transcodificación completada: $(basename "$output_file") | Duración: $((total_time / 60)):$(($total_time % 60)) min. | Velocidad: ${speed} | Calidad final: ${final_bitrate} Mbps | Reducción del: ${compression_percentage}%"
    fi
  else
    echo "Error al transcodificar: $input_file" >> "$LOG_FILE"
    echo "Detalles del error: $ffmpeg_output" >> "$LOG_FILE"
    echo "-------------------------------" >> "$LOG_FILE"
    send_telegram_notification "Error al transcodificar: $(basename "$input_file"). Mas detalles en el log."
    # Registrar el archivo fallido
    register_failed_file "$input_file"
  fi
}

# -----------------------------------------------------------------

# Verificar el espacio disponible en el directorio de salida
check_available_space() {
  local required_space=$1
  local available_space=$(df --output=avail "$OUTPUT_DIR" | tail -n 1)
  available_space=$((available_space * 1024))  # Convertir a bytes

  if (( available_space >= required_space )); then
    return 0  # Hay suficiente espacio disponible
  else
    return 1  # No hay suficiente espacio disponible
  fi
}

# -----------------------------------------------------------------

# Función para comprobar si el archivo ya está en H.265 (HEVC)
is_hevc() {
  local file="$1"
  codec=$(ffmpeg -i "$file" 2>&1 | grep Video | grep -oP '(?<=Video: )[^,]+' 2>/dev/null)

  codec=$(echo "$codec" | tr '[:upper:]' '[:lower:]')

  if [[ "$codec" == *"hevc"* ]]; then
    return 0  # Es HEVC
  else
    return 1  # No es HEVC
  fi
}

# -----------------------------------------------------------------

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
  local target_dir="${OUTPUT_DIR%/}/${relative_path#/}"

  local space_checked=false       # Para rastrear si el espacio fue insuficiente en algún punto

  # Procesar los archivos de video en la carpeta actual
  for item in "$current_dir"/*; do
    if [ -f "$item" ] && [[ "$item" == *.mkv || "$item" == *.mp4 || "$item" == *.avi || "$item" == *.mov || "$item" == *.mpeg ]]; then
      # Solo procesar archivos que no tengan el sufijo "_HEVC" y que no estén ya en HEVC
      if [[ "$item" != *"_HEVC"* ]] && ! is_file_failed "$item" && ! is_hevc "$item"; then
        # Solo agregar "_HEVC" al nombre del archivo transcodificado, no a la carpeta
        local output_file="${target_dir%/}/$(basename "$item" .${item##*.})_HEVC.mkv"

        # Si el archivo de salida ya existe, omitir el procesamiento sin imprimir nada
        if [ ! -f "$output_file" ]; then
          local input_size=$(stat --format="%s" "$item")

          # Comprobar si hay suficiente espacio antes de procesar el archivo
          if ! check_available_space "$input_size"; then
            echo "Error: No hay suficiente espacio disponible en el directorio de salida $OUTPUT_DIR para segir transcodificando los archivos pendientes. Deteniendo el procesamiento temporalmente. $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
            echo "-------------------------------" >> "$LOG_FILE"
            send_telegram_notification "Error: No hay suficiente espacio disponible en el directorio de salida: $OUTPUT_DIR para segir transcodificando los archivos pendientes. El proceso se detendrá hasta que haya espacio disponible. $(date '+%Y-%m-%d %H:%M:%S')"

            # Esperar hasta que haya suficiente espacio disponible antes de continuar
            while ! check_available_space "$input_size"; do
              sleep 60  # Esperar 60 segundos antes de volver a comprobar
            done

            echo "Espacio suficiente disponible. Reanudando el procesamiento de archivos." >> "$LOG_FILE"
            echo "-------------------------------" >> "$LOG_FILE"
            send_telegram_notification "Espacio suficiente disponible en $OUTPUT_DIR. Reanudando el procesamiento de archivos."
          fi

          # Intentar procesar el archivo
          if is_file_ready "$item"; then
            transcode_file "$item" "$output_file"
          fi
        fi
      fi
    fi
  done

  # Procesar subdirectorios recursivamente
  for item in "$current_dir"/*; do
    if [ -d "$item" ]; then
      process_directory "$item"
    fi
  done
}

# -----------------------------------------------------------------

# Inicio
echo "Buscando archivos... - $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo " " >> "$LOG_FILE"

while true; do
  process_directory "$INPUT_DIR"
  sleep 60  # Esperar 60 segundos antes de volver a comprobar
done

