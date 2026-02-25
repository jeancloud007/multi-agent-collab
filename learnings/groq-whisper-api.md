# Groq Whisper API Research

**Author:** Jean  
**Date:** 2025-02-25  
**Status:** Complete — ready for skill implementation

## TL;DR

Groq offers **free** Whisper transcription with generous limits. No OOM issues because it's API-based (offloads to their infrastructure). This solves Jared's transcription bottleneck.

---

## Models Available

| Model | Speed | Price/Hour | Best For |
|-------|-------|------------|----------|
| `whisper-large-v3` | 217x realtime | $0.111 | High accuracy, multilingual |
| `whisper-large-v3-turbo` | 228x realtime | $0.04 | Best price/performance ✅ |

**Recommendation:** Use `whisper-large-v3-turbo` — faster, cheaper, still multilingual.

---

## Free Tier Limits

| Limit | Value | In Human Terms |
|-------|-------|----------------|
| RPM | 20 | 20 requests/minute |
| RPD | 2,000 | 2,000 requests/day |
| ASH | 7,200 sec | **2 hours audio/hour** |
| ASD | 28,800 sec | **8 hours audio/day** |

**This is very generous.** For occasional video transcription, you'll never hit these limits.

---

## API Endpoints

```
POST https://api.groq.com/openai/v1/audio/transcriptions
POST https://api.groq.com/openai/v1/audio/translations  (→ English)
```

**OpenAI Compatible!** Can use OpenAI SDK with Groq base URL.

---

## Authentication

- **Method:** API Key (Bearer token)
- **Get key:** https://console.groq.com/keys
- **Header:** `Authorization: Bearer $GROQ_API_KEY`

No OAuth, no complex flow. Just get key and go.

---

## Code Example (Python)

```python
from openai import OpenAI
import os

client = OpenAI(
    api_key=os.environ.get("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1",
)

# Transcribe audio file
with open("audio.mp3", "rb") as audio_file:
    transcription = client.audio.transcriptions.create(
        model="whisper-large-v3-turbo",
        file=audio_file,
    )

print(transcription.text)
```

---

## Code Example (curl)

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -F "file=@audio.mp3" \
  -F "model=whisper-large-v3-turbo"
```

---

## Rate Limit Headers

Response includes these headers for tracking:
- `x-ratelimit-remaining-requests` — requests left today
- `x-ratelimit-reset-requests` — time until reset
- `retry-after` — seconds to wait (only on 429)

---

## Gotchas

1. **Minimum billing:** 10 seconds per request (even if audio is shorter)
2. **File size:** Check max file size in docs (typically ~25MB)
3. **Formats:** Supports mp3, mp4, mpeg, mpga, m4a, wav, webm
4. **429 errors:** Back off using `retry-after` header

---

## Workflow for Video Transcription

1. Download video audio with `yt-dlp` (extract audio only)
2. POST audio file to Groq Whisper endpoint
3. Get text response

No local Whisper model needed. No OOM. Cloud handles the heavy lifting.

---

## Skill Implementation Notes

For `skills/video-transcribe/`:

```bash
# Dependencies
pip install openai  # or use curl

# Env var
export GROQ_API_KEY="your-key-here"

# Flow
1. yt-dlp -x --audio-format mp3 <video_url>
2. curl Groq API with audio file
3. Return transcription text
```

---

## Cost Estimate

| Use Case | Audio | Cost (Turbo) |
|----------|-------|--------------|
| 2-min TikTok | 2 min | Free (within limits) |
| 1-hour podcast | 60 min | $0.04 |
| 8 hours/day | 8 hrs | Free (within limits!) |

**Verdict:** For our use case, effectively free forever.

---

## Next Steps

1. Jared: Get Groq API key from console.groq.com
2. Create `skills/video-transcribe/SKILL.md` using this research
3. Test with the TikTok video from earlier
4. Document any additional gotchas

---

*Research completed via browser automation. Ready for implementation.*
