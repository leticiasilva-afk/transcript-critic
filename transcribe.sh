#!/usr/bin/env bash

# Transcribes audio to text using whisper.cpp. Accepts either a local audio/video
# file or a URL (YouTube or any other yt-dlp-supported site, including direct
# links to .mp3 files). Local files are converted to MP3 via ffmpeg; URLs are
# downloaded and extracted as MP3 via yt-dlp. In both cases, whisper-cli
# produces .txt and .vtt transcription files.
#
# All progress output goes to stderr. On success, the only thing written to
# stdout is the absolute path of the generated .vtt file, so callers (such as
# the /transcribe skill) never have to guess which file was produced.
#
# Usage: ./transcribe.sh <audio-file-or-url>
#
# Configuration (environment variables, all optional):
#   WHISPER_ROOT      path to the whisper.cpp checkout
#                     (default: ~/github.com/ggerganov/whisper.cpp)
#   WHISPER_CLI       path to the whisper-cli binary
#                     (default: $WHISPER_ROOT/build/bin/whisper-cli)
#   WHISPER_MODEL     path to the GGML model
#                     (default: $WHISPER_ROOT/models/ggml-medium.en.bin)
#   WHISPER_LANGUAGE  spoken language code, or "auto" to detect it
#                     (default: en; English-only ".en" models require "en")

set -euo pipefail

# --- CONFIG ---
WHISPER_ROOT="${WHISPER_ROOT:-${HOME}/github.com/ggerganov/whisper.cpp}"
PGM="${WHISPER_CLI:-${WHISPER_ROOT}/build/bin/whisper-cli}"
MODEL="${WHISPER_MODEL:-${WHISPER_ROOT}/models/ggml-medium.en.bin}"
LANGUAGE="${WHISPER_LANGUAGE:-en}"

# --- FUNCTIONS ---
log() {
    echo "$@" >&2
}

die() {
    log "Error: $*"
    exit 1
}

check_dependencies() {
    [[ -x "${PGM}" ]] || die "whisper-cli not found or not executable: ${PGM} (set WHISPER_ROOT or WHISPER_CLI)"
    [[ -f "${MODEL}" ]] || die "Whisper model not found: ${MODEL} (set WHISPER_ROOT or WHISPER_MODEL)"
    if [[ "${MODEL}" == *.en.bin && "${LANGUAGE}" != "en" ]]; then
        die "Model ${MODEL} is English-only, but WHISPER_LANGUAGE=${LANGUAGE}. Use a multilingual model (e.g. ggml-medium.bin)."
    fi
}

convert_audio_to_mp3() {
    local RAW=$1
    local MP3="${RAW%.*}.mp3"

    if [[ -e "${MP3}" ]]; then
        log "========================================"
        log "Audio file already exists: ${MP3}"
        log "========================================"
        log ""
        echo "${MP3}"
        return
    fi

    ffmpeg -nostdin -i "${RAW}" -codec:a libmp3lame -q:a 0 "${MP3}" >&2
    echo "${MP3}"
}

# Downloads the audio from a URL and prints the exact path of the resulting MP3.
download_and_extract_audio() {
    local URL=$1
    local PATH_FILE
    PATH_FILE=$(mktemp)
    # shellcheck disable=SC2064
    trap "rm -f '${PATH_FILE}'" RETURN

    # yt-dlp writes the final file path (after audio extraction) to PATH_FILE,
    # so we never have to guess which .mp3 in the directory is the new one.
    yt-dlp \
        --extractor-args "youtube:player-client=android" \
        --no-playlist \
        --restrict-filenames \
        -o "%(title).80s.%(ext)s" \
        --extract-audio \
        --audio-format mp3 \
        --audio-quality 0 \
        --print-to-file after_move:filepath "${PATH_FILE}" \
        "$URL" >&2

    local MP3
    MP3=$(tail -n 1 "${PATH_FILE}")
    [[ -n "${MP3}" ]] || die "yt-dlp did not report a downloaded file for: ${URL}"
    echo "${MP3}"
}

transcribe_audio() {
    local MP3=$1
    local BASENAME="${MP3%.mp3}"

    log
    log "================================================="
    log "[$(date +"%Y%m%d.%H%M%S")] Transcribing: ${MP3}"
    log "================================================="
    log

    "${PGM}" \
        --output-txt \
        --output-vtt \
        --output-file "${BASENAME}" \
        --model "${MODEL}" \
        --language "${LANGUAGE}" \
        "${MP3}" >&2

    [[ -s "${BASENAME}.vtt" ]] || die "whisper-cli did not produce ${BASENAME}.vtt"

    # Remove empty lines from .vtt to reduce token usage during analysis
    sed -i.bak '/^$/d' "${BASENAME}.vtt"
    rm -f "${BASENAME}.vtt.bak"

    log "✅ Done: ${BASENAME}.txt and ${BASENAME}.vtt"

    # The only line on stdout: the absolute path of the .vtt file.
    echo "$(cd "$(dirname "${BASENAME}.vtt")" && pwd)/$(basename "${BASENAME}.vtt")"
}

# --- MAIN ---
if [[ $# -lt 1 ]]; then
    log "Usage: $0 <audio-file-or-url>"
    exit 1
fi

INPUT=$1
check_dependencies

if [[ "$INPUT" == http://* || "$INPUT" == https://* ]]; then
    # URL input (including direct .mp3 links): download via yt-dlp
    MP3=$(download_and_extract_audio "$INPUT")

    # A title truncated at 80 characters can end in dots ("Title..mp3");
    # normalise it to a single ".mp3" extension.
    NEW_MP3="$MP3"
    while [[ "$NEW_MP3" == *..mp3 ]]; do
        NEW_MP3="${NEW_MP3%..mp3}.mp3"
    done
    if [[ "$MP3" != "$NEW_MP3" ]]; then
        mv -f "$MP3" "$NEW_MP3"
    fi
    MP3="$NEW_MP3"
else
    # Local file input: convert to MP3 (if needed), then transcribe
    [[ -e "${INPUT}" ]] || die "File not found: ${INPUT}"
    MP3=$(convert_audio_to_mp3 "${INPUT}")
fi

[[ -e "${MP3}" ]] || die "File not found: ${MP3}"

transcribe_audio "$MP3"
