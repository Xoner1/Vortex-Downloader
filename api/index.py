import os
import uuid
import sys
import yt_dlp
import time
import random
from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Vortex API is working!", "status": "online"}


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ExtractRequest(BaseModel):
    url: str

# Smart Caching for /api/extract
extract_cache = {}
CACHE_TTL = 3600  # 1 hour

def clean_cache():
    current_time = time.time()
    keys_to_delete = [k for k, v in extract_cache.items() if current_time - v['timestamp'] > CACHE_TTL]
    for k in keys_to_delete:
        del extract_cache[k]

@app.post("/api/extract")
async def extract_metadata(request: ExtractRequest):
    clean_cache()
    if request.url in extract_cache:
        return extract_cache[request.url]['data']

    user_agents = [
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
        'Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    ]

    # Robutstness for Vercel (Read-only FS)
    os.environ['HOME'] = '/tmp'
    
    ydl_opts = {
        'quiet': True,
        'no_warnings': True,
        'format': 'bestvideo[height<=2160]+bestaudio/best', # up to 4K
        'sponsorblock_mark': 'all',
        'extract_flat': 'in_playlist',
        'cachedir': False,
        'nocheckcertificate': True,
        'geo_bypass': True,
        'noprogress': True,
        'no_color': True,
        'extractor_args': {
            'youtube': {
                'player_client': ['android', 'ios'],
                'skip': ['webpage']
            }
        },
        'http_headers': {
            'User-Agent': random.choice(user_agents),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Sec-Fetch-Mode': 'navigate',
        }
    }

    # Cookie Strategy for Vercel: Copy to /tmp if exists
    source_cookie = os.path.join(os.path.dirname(__file__), 'cookies.txt')
    target_cookie = '/tmp/cookies.txt'
    
    if os.path.exists(source_cookie):
        try:
            import shutil
            shutil.copy2(source_cookie, target_cookie)
            ydl_opts['cookiefile'] = target_cookie
        except Exception as e:
            print(f"Warning: Could not copy cookies: {e}")

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(request.url, download=False)

            # Extract essential data to save bandwidth/memory
            formats = info.get('formats', [])
            audio_url = None
            video_url = None

            for f in formats:
                if f.get('vcodec') == 'none' and f.get('acodec') != 'none':
                    audio_url = f.get('url')
                if f.get('vcodec') != 'none' and f.get('height') == 1080:
                    video_url = f.get('url')

            if not video_url:
                video_url = info.get('url') # fallback

            result = {
                "title": info.get('title'),
                "artist": info.get('channel', info.get('uploader')),
                "thumbnail": info.get('thumbnail'),
                "duration": info.get('duration'),
                "audio_url": audio_url,
                "video_url": video_url,
                "chapters": info.get('chapters', []) # SponsorBlock chapters
            }

            extract_cache[request.url] = {
                'data': result,
                'timestamp': time.time()
            }
            return result
    except Exception as e:
        return {"error": str(e)}
