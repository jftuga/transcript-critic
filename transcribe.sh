#!/usr/bin/env bash

# Transcribes audio to text using whisper.cpp. Accepts either a local audio file
# or a URL (YouTube or other yt-dlp-supported sites). Local audio files are
# converted to MP3 via ffmpeg; URLs are downloaded and extracted as MP3 via yt-dlp.
# In both cases, whisper-cli produces .txt and .vtt transcription files.
# Usage: ./transcribe.sh <audio-file-or-url>

set -euo pipefail

# --- CONFIG ---
WHISPER_ROOT="${HOME}/github.com/ggerganov/whisper.cpp"
PGM="${WHISPER_ROOT}/build/bin/whisper-cli"
MODEL="${WHISPER_ROOT}/models/ggml-medium.en.bin"

# --- FUNCTIONS ---
convert_audio_to_mp3() {
    local RAW=$1
    local MP3="${RAW%.*}.mp3"

    if [[ -e "${MP3}" ]]; then
        echo "========================================" >&2
        echo "Audio file already exists: ${MP3}" >&2
        echo "========================================" >&2
        echo "" >&2
        echo "${MP3}"
        return
    fi

    ffmpeg -i "${RAW}" -codec:a libmp3lame -q:a 0 "${MP3}" >&2
    echo "${MP3}"
}

download_and_extract_audio() {
    local URL=$1

    yt-dlp \
        --extractor-args "youtube:player-client=android" \
        --no-playlist \
        --restrict-filenames \
        -o "%(title).80s.%(ext)s" \
        --extract-audio \
        --audio-format mp3 \
        --audio-quality 0 \
        "$URL"
}

transcribe_audio() {
    local MP3=$1
    local BASENAME="${MP3%.mp3}"

    echo
    echo "================================================="
    echo "[$(date +"%Y%m%d.%H%M%S")] Transcribing: ${MP3}"
    echo "================================================="
    echo

    "${PGM}" \
        --output-txt \
        --output-vtt \
        --output-file "${BASENAME}" \
        --model "${MODEL}" \
        "${MP3}"

    echo "✅ Done: ${BASENAME}.txt and ${BASENAME}.vtt"
}

# --- MAIN ---
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <audio-file-or-url>"
    exit 1
fi

INPUT=$1

if [[ "$INPUT" == http://* || "$INPUT" == https://* ]]; then
    # URL input: download via yt-dlp, then transcribe
    if [[ "$INPUT" == *.mp3 ]]; then
        MP3="$INPUT"
    else
        download_and_extract_audio "$INPUT"
        # Find the last mp3 created by yt-dlp
        MP3=$(ls -t *.mp3 | head -1)
    fi

    if [[ -z "$MP3" ]]; then
        echo "Error: No MP3 file found."
        exit 1
    fi

    NEW_MP3=$(sed 's/\.\+\.mp3$/.mp3/' <<< "$MP3")

    if [[ "$MP3" != "$NEW_MP3" ]]; then
        mv -f "$MP3" "$NEW_MP3"
    fi

    MP3="$NEW_MP3"

    if [[ ! -e "${MP3}" ]]; then
        echo "File not found: ${MP3}"
        exit 1
    fi
else
    # Local file input: convert to MP3, then transcribe
    if [[ ! -e "${INPUT}" ]]; then
        echo "File not found: ${INPUT}"
        exit 1
    fi

    MP3=$(convert_audio_to_mp3 "${INPUT}")
fi

transcribe_audio "$MP3"
