![HWEncoderX Logo](https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/logo.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Stars](https://img.shields.io/docker/stars/macrimi/hwencoderx.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)
[![Docker Image Size](https://img.shields.io/docker/image-size/macrimi/hwencoderx/latest?style=for-the-badge&color=94398d&labelColor=555555&logoColor=ffffff&logo=docker)](https://hub.docker.com/r/macrimi/hwencoderx)


# HWEncoderX: Video Transcoder with GPU Hardware Acceleration (Intel QSV, NVENC, VAAPI)

HWEncoderX is a Docker container that allows you to automatically transcode videos to H.265 (HEVC) using your GPU with hardware acceleration, supporting **VAAPI** (Intel/AMD), **NVENC** (NVIDIA), and **Intel Quick Sync (QSV)**. This allows processing only the video track, prioritizing quality while keeping the audio, subtitles, and chapters intact.

## Features

- **Support for Multiple GPUs**: Compatible with **Intel Quick Sync (QSV)**, **NVIDIA NVENC**, and **VAAPI**. If no compatible GPU is detected, the container stops and sends an error notification.
- **Support for Multiple Input Formats**: Compatible with `.mkv`, `.mp4`, `.avi`, `.mov`, and `.mpeg` files.
- **Telegram Notifications**: Sends welcome notifications, transcoding details (time, speed, quality), and errors during the process.
- **Always Active Docker**: The container remains active, constantly monitoring the input directory for new files.
- **Automatic Quality Adjustment**: Optimized adjustment to **prioritize quality** based on the input video bitrate using the global **QUALITY** variable.
- **Error Handling and Space Verification**: Checks disk space before transcoding and sends notifications if space is insufficient or if there are errors.
- **Size Reduction**: Transcodes to H.265 (HEVC) to reduce file size by up to 70%.
- **Ideal for Media Servers**: Compatible with **Plex**, **Jellyfin**, **Emby**, and more.
- **Simple**: Just mount the input and output folders, and HWEncoderX does all the work.
- **Customizable Options**: Manually define the quality using the **QUALITY** variable and select the **preset** to adjust speed and quality as needed.

## Telegram Notification Configuration

To receive Telegram notifications, configure a bot and obtain your **BOT_TOKEN** and **CHAT_ID**. Follow these steps:

1. Create a new bot on Telegram using [BotFather](https://t.me/botfather) and follow the instructions until you get your **BOT_TOKEN**.
2. Obtain your CHAT_ID by sending a message to your bot, then using an API call like:
   ```bash
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
   ```
   Replace `<YOUR_BOT_TOKEN>` with your bot token to find your **CHAT_ID** in the response.

## Requirements

You need a GPU compatible with **VAAPI** (Intel/AMD), **NVENC** (NVIDIA), or **Intel Quick Sync (QSV)**. Without a compatible GPU, the container **will not work**.

### Parameters

| Parameters | Requirement | Function |
| :----: | :----: | --- |
| `--device=/dev/dri` | Required if using QSV or VAAPI | Needed to enable hardware acceleration through Intel Quick Sync (QSV) and VAAPI. |
| `--gpus all` | Required if using NVENC | Needed to enable hardware acceleration through NVENC on NVIDIA GPUs. |
| `-v /path/to/input:/input` | Required | Replace `/path/to/input` with the path to your input folder where the videos to be transcoded are located. |
| `-v /path/to/output:/output` | Required | Replace `/path/to/output` with the path where the transcoded files will be saved. (This can be the same as the input folder) |
| `-e PRESET` | Optional | Specifies the preset value (`ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower`, and `veryslow`). `medium` is the default value. |
| `-e QUALITY` | Optional | Manually define the quality level for transcoding, used in NVENC, VAAPI, and QSV. If not defined, the quality will be automatically adjusted based on the input bitrate to maintain an optimal balance between quality and file size. |
| `-e BOT_TOKEN` | Optional if notifications are desired | The token of your Telegram bot for sending notifications. |
| `-e CHAT_ID` | Optional if notifications are desired | The chat ID where Telegram notifications will be sent. |
| `-e NOTIFICATIONS` | Optional | Set to `all` to receive all notifications; if not defined, only error notifications will be sent. |

**Note:** `/path/to/input` and `/path/to/output` can be the same folder. Transcoded files will be created with the `_HEVC` suffix.

## Usage Instructions

### Intel Quick Sync (QSV), VAAPI Usage

#### Docker Run

```bash
docker run -d --name hwencoderx --device=/dev/dri \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx \
  -e CHAT_ID=xxxxxxxx \
  -e QUALITY=18 \
  -e PRESET=medium \
  -e NOTIFICATIONS=all \
  macrimi/hwencoderx:latest

# Explanation of the parameters used:
# - `-e QUALITY=18`: Optional. Defines the custom quality level (recommended between 16 to 22) for transcoding.
# - `-e PRESET=medium`: Optional. Defines the custom preset for transcoding (optional).
# - `-e BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx`: Optional. Replace with your TOKEN, requires CHAT_ID.
# - `-e CHAT_ID=xxxxxxxx`: Optional. Replace with your CHAT_ID, requires BOT_TOKEN.
# - `-e NOTIFICATIONS=all`: Optional.
```

#### `docker-compose.yml`

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
    environment:
      QUALITY: "18" # Optional
      PRESET: "medium" # Optional
      BOT_TOKEN: "xxxxxxxxxxxxxxxxxxxxxxxxxx" # Optional (replace with your TOKEN, requires CHAT_ID)
      CHAT_ID: "xxxxxxxx" # Optional (replace with your CHAT_ID, requires BOT_TOKEN)
      NOTIFICATIONS: "all" # Optional
```

### NVIDIA Usage

#### Docker Run

```bash
docker run -d --name hwencoderx --gpus all \ 
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -e BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx \
  -e CHAT_ID=xxxxxxxx \
  -e QUALITY=18 \
  -e PRESET=medium \
  -e NOTIFICATIONS=all \
  macrimi/hwencoderx:latest

# Explanation of the parameters used:
# - `-e QUALITY=18`: Optional. Defines the custom quality level (recommended between 16 to 22) for transcoding.
# - `-e PRESET=medium`: Optional. Defines the custom preset for transcoding.
# - `-e BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx`: Optional. Replace with your TOKEN, requires CHAT_ID.
# - `-e CHAT_ID=xxxxxxxx`: Optional. Replace with your CHAT_ID, requires BOT_TOKEN.
# - `-e NOTIFICATIONS=all`: Optional.
```

#### `docker-compose.yml`

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
    environment:
      QUALITY: "18" # Optional
      PRESET: "medium" # Optional
      BOT_TOKEN: "xxxxxxxxxxxxxxxxxxxxxxxxxx" # Optional (replace with your TOKEN, requires CHAT_ID)
      CHAT_ID: "xxxxxxxx" # Optional (replace with your CHAT_ID, requires BOT_TOKEN)
      NOTIFICATIONS: "all" # Optional
```

## Additional Notes

HWEncoderX works with hardware acceleration **VAAPI**, **NVENC**, and **QSV**. Without a compatible **Intel**, **AMD**, or **NVIDIA** GPU, the container will not work. Original files are not deleted after transcoding, allowing you to keep both the original and the transcoded files with the `_HEVC` suffix.

### Synology/XPenology NAS Compatibility
Works on any NAS with a functional **Intel** or **NVIDIA** GPU.

### DVA Models
On **DVA** Synology NAS that use the **NVIDIA Runtime Library** for **Surveillance Station**, it is not possible to run this container as they do not have NVIDIA Container Toolkit.

### License
This project is under the **MIT License**. You are free to use, modify, and distribute the code as long as proper credit is given. See the `LICENSE` file for more details.

### Third-party Software
This container uses **FFmpeg**, licensed under **LGPL 2.1 or later**. See the [FFmpeg documentation](https://ffmpeg.org/legal.html) for more information.

#


## ⭐ Support the Project!
If you find **HWEncoderX** useful, consider giving it a ⭐ on GitHub to help others discover it!

<div style="display: flex; justify-content: center; align-items: center;">
  <a href="https://ko-fi.com/G2G313ECAN" target="_blank" style="display: flex; align-items: center; text-decoration: none;">
    <img src="https://raw.githubusercontent.com/MacRimi/HWEncoderX/main/images/kofi.png" alt="Support me on Ko-fi" style="width:175px; margin-right:65px;"/>
  </a>
</div>

If you would like to support the project, you can buy me a coffee on Ko-fi! Thank you! 😊


