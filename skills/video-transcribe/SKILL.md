# Video Transcription Skill

**Name:** video-transcribe  
**Description:** Download and transcribe video/audio from URLs using yt-dlp + Groq Whisper API.

---

## Prerequisites

1. **yt-dlp** — for downloading video/audio
   ```bash
   pip install yt-dlp
   # or
   brew install yt-dlp
   ```

2. **GROQ_API_KEY** — get free key from https://console.groq.com
   ```bash
   export GROQ_API_KEY="your-key-here"
   ```

---

## Supported Platforms

yt-dlp supports 1000+ sites including:
- YouTube
- TikTok
- Instagram
- Twitter/X
- Vimeo
- And many more

---

## Groq Whisper API Details

| Model | Speed | Price/Hour | Free Tier |
|-------|-------|------------|-----------|
| whisper-large-v3-turbo | 228x realtime | $0.04 | 8 hrs/day |
| whisper-large-v3 | 189x realtime | $0.111 | 8 hrs/day |
| distil-whisper-large-v3-en | 250x realtime | $0.02 | 8 hrs/day (English only) |

**Free tier:** ~14,400 requests/day, 8 hours of audio/day. More than enough.

---

## Workflow

### Step 1: Download Audio

```bash
# Extract audio only (saves bandwidth)
yt-dlp -x --audio-format mp3 -o "/tmp/%(id)s.%(ext)s" "URL"

# For TikTok specifically (may need cookies)
yt-dlp -x --audio-format mp3 "https://www.tiktok.com/@user/video/123"
```

### Step 2: Transcribe with Groq

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/tmp/audio.mp3" \
  -F "model=whisper-large-v3-turbo" \
  -F "response_format=text"
```

### Python Version

```python
import os
from groq import Groq

client = Groq(api_key=os.environ["GROQ_API_KEY"])

with open("/tmp/audio.mp3", "rb") as file:
    transcription = client.audio.transcriptions.create(
        file=file,
        model="whisper-large-v3-turbo",
        response_format="text"
    )
    print(transcription)
```

---

## Full Pipeline Script

```bash
#!/bin/bash
# video-transcribe.sh - Download and transcribe any video URL

URL="$1"
OUTPUT_DIR="${2:-/tmp}"

# Download audio
echo "Downloading audio from: $URL"
yt-dlp -x --audio-format mp3 -o "$OUTPUT_DIR/audio.%(ext)s" "$URL" 2>/dev/null

AUDIO_FILE=$(ls -t $OUTPUT_DIR/audio.* 2>/dev/null | head -1)

if [ -z "$AUDIO_FILE" ]; then
    echo "Error: Failed to download audio"
    exit 1
fi

echo "Transcribing: $AUDIO_FILE"

# Transcribe with Groq
curl -s -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@$AUDIO_FILE" \
  -F "model=whisper-large-v3-turbo" \
  -F "response_format=text"

# Cleanup
rm -f "$AUDIO_FILE"
```

Usage:
```bash
./video-transcribe.sh "https://www.tiktok.com/t/ZP8xM6fnw/"
```

---

## Gotchas

1. **File size limit:** Groq accepts up to 25MB. Long videos may need chunking.
2. **TikTok cookies:** Some TikTok videos need login cookies. Use `--cookies-from-browser chrome`.
3. **Rate limits:** 8 hours/day free. Track usage for heavy workloads.
4. **Audio quality:** Higher bitrate = better transcription. Use `-x --audio-quality 0`.

---

## Error Recovery

```bash
# If yt-dlp fails, try with browser cookies
yt-dlp --cookies-from-browser chrome -x --audio-format mp3 "URL"

# If Groq rate limited, fall back to local whisper (slower, more RAM)
whisper audio.mp3 --model base --output_format txt
```

---

## Integration Notes

- **OpenAI compatible:** Same API format as OpenAI Whisper, just different base URL
- **No local model:** All processing happens on Groq's servers = no OOM
- **Fast:** 10-min video transcribes in ~3 seconds

---

## See Also

- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp)
- [Groq Speech-to-Text Docs](https://console.groq.com/docs/speech-text)
- `/shared/learnings/groq-whisper-api.md` for research notes
