#!/bin/bash
# video-transcribe.sh — Download and transcribe video/audio from URLs
# Uses yt-dlp + Groq Whisper API
# By Jean (2026-02-25)

set -e

# Load API key from environment or .env
if [ -z "$GROQ_API_KEY" ]; then
    if [ -f ~/.clawdbot/.env ]; then
        export $(grep GROQ_API_KEY ~/.clawdbot/.env | xargs)
    fi
fi

if [ -z "$GROQ_API_KEY" ]; then
    echo "Error: GROQ_API_KEY not set"
    exit 1
fi

URL="${1:-}"
MODEL="${2:-whisper-large-v3-turbo}"
OUTPUT_DIR="${3:-/tmp}"

if [ -z "$URL" ]; then
    echo "Usage: $0 <url> [model] [output_dir]"
    echo ""
    echo "Models: whisper-large-v3-turbo (default), whisper-large-v3, distil-whisper-large-v3-en"
    exit 1
fi

# Generate unique filename
AUDIO_ID=$(echo "$URL" | md5sum | cut -c1-8)
AUDIO_FILE="$OUTPUT_DIR/audio_$AUDIO_ID.mp3"

echo "📥 Downloading audio from: $URL"
yt-dlp -x --audio-format mp3 --audio-quality 0 \
    -o "$AUDIO_FILE" "$URL" 2>/dev/null || {
    echo "⚠️  Standard download failed, trying with cookies..."
    yt-dlp -x --audio-format mp3 --audio-quality 0 \
        --cookies-from-browser chrome \
        -o "$AUDIO_FILE" "$URL" 2>/dev/null
}

if [ ! -f "$AUDIO_FILE" ]; then
    echo "❌ Failed to download audio"
    exit 1
fi

# Check file size (Groq limit: 25MB)
FILE_SIZE=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || stat -c%s "$AUDIO_FILE")
if [ "$FILE_SIZE" -gt 26214400 ]; then
    echo "⚠️  File too large (${FILE_SIZE} bytes > 25MB). Consider chunking."
    # Could add chunking logic here
fi

echo "🎙️ Transcribing with Groq ($MODEL)..."

RESULT=$(curl -s -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@$AUDIO_FILE" \
    -F "model=$MODEL" \
    -F "response_format=text")

echo ""
echo "📝 Transcript:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$RESULT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup
rm -f "$AUDIO_FILE"

echo "✅ Done!"
