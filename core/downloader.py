import yt_dlp
import threading
import os

class VortexDownloader:
    def __init__(self, progress_callback=None, status_callback=None):
        self.progress_callback = progress_callback
        self.status_callback = status_callback

    def progress_hook(self, d):
        if d['status'] == 'downloading':
            if self.progress_callback:
                p = d.get('_percent_str', '0%').replace('%','')
                speed = d.get('_speed_str', '0 B/s')
                total = d.get('_total_bytes_str') or d.get('_total_bytes_estimate_str', 'N/A')
                
                self.progress_callback({
                    "percent": p,
                    "speed": speed,
                    "total": total
                })

        elif d['status'] == 'finished':
            if self.status_callback:
                self.status_callback("Verifying & Converting...")

    def download_task(self, url, path, mode, quality, ffmpeg_path):
       
        # yt-dlp prefers the directory containing the executable
        if os.path.isfile(ffmpeg_path):
            ffmpeg_dir = os.path.dirname(ffmpeg_path)
        else:
            ffmpeg_dir = ffmpeg_path

        
        print(f"DEBUG: Using FFmpeg directory: {ffmpeg_dir}")

        ydl_opts = {
            'ffmpeg_location': ffmpeg_dir,  # Pass the FOLDER, not the file
            'progress_hooks': [self.progress_hook],
            'outtmpl': os.path.join(path, '%(title).50s.%(ext)s'),
            'quiet': True,
            'no_warnings': True,
            'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        }

        if mode == 'audio':
            ydl_opts.update({
                'format': 'bestaudio/best',
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }],
                'keepvideo': False,
            })
        else:
            # Video Mode: Merge video+audio into MP4
            ydl_opts.update({
                'format': f'bestvideo[height<={quality}][ext=mp4]+bestaudio[ext=m4a]/best[height<={quality}][ext=mp4]/best',
                'merge_output_format': 'mp4',
                'postprocessor_args': [
                    '-c:v', 'libx264',
                    '-c:a', 'aac',
                    '-pix_fmt', 'yuv420p'
                ],
            })

        try:
            if self.status_callback:
                self.status_callback("Connecting...")
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            
            if self.status_callback:
                self.status_callback("Download & Merge Complete!")
                
        except Exception as e:
            print(f"Core Error: {e}")
            if self.status_callback:
                self.status_callback("Failed! Check Terminal.")

    def start(self, url, path, mode, quality, ffmpeg_path):
        t = threading.Thread(target=self.download_task, args=(url, path, mode, quality, ffmpeg_path))
        t.daemon = True
        t.start()