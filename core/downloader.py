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
                self.status_callback("Verifying Media Data...")

    def download_task(self, url, path, mode, quality, ffmpeg_path):
       
        if mode == 'audio':
            self.download_audio(url, path, ffmpeg_path)
            return

     
        if self.status_callback: self.status_callback("Checking for Direct-Play version...")
        success = self.try_fast_download(url, path, quality, ffmpeg_path)
        
        if not success:
            if self.status_callback: 
                self.status_callback("Optimization required. Converting video...")
            
            self.try_robust_download(url, path, quality, ffmpeg_path)

    def download_audio(self, url, path, ffmpeg_path):
        ydl_opts = {
            'ffmpeg_location': ffmpeg_path,
            'progress_hooks': [self.progress_hook],
            'outtmpl': os.path.join(path, '%(title).50s.%(ext)s'),
            'quiet': True, 'no_warnings': True,
            'format': 'bestaudio/best',
            'postprocessors': [{'key': 'FFmpegExtractAudio','preferredcodec': 'mp3','preferredquality': '192'}],
        }
        try:
            if self.status_callback: self.status_callback("Downloading Audio...")
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            if self.status_callback: self.status_callback("Audio Ready! 🎵")
        except Exception as e:
            if self.status_callback: self.status_callback("Audio Failed.")

    def try_fast_download(self, url, path, quality, ffmpeg_path):
        
        try:
            fmt = f'bestvideo[height<={quality}][vcodec^=avc]+bestaudio[ext=m4a]/best[height<={quality}][vcodec^=avc]/best[ext=mp4]/best'
            
            ydl_opts = {
                'ffmpeg_location': ffmpeg_path,
                'progress_hooks': [self.progress_hook],
                'outtmpl': os.path.join(path, '%(title).50s.%(ext)s'),
                'quiet': True, 'no_warnings': True,
                'format': fmt,
                'merge_output_format': 'mp4',
            }

            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            
            if self.status_callback: self.status_callback("Done! (Direct Play) 🚀")
            return True

        except Exception:
            return False 

    def try_robust_download(self, url, path, quality, ffmpeg_path):
       
        try:
            ydl_opts = {
                'ffmpeg_location': ffmpeg_path,
                'progress_hooks': [self.progress_hook],
                'outtmpl': os.path.join(path, '%(title).50s.%(ext)s'),
                'quiet': True, 'no_warnings': True,
                'format': f'bestvideo[height<={quality}]+bestaudio/best[height<={quality}]/best',
                'merge_output_format': 'mp4',
                
                'postprocessor_args': ['-c:v', 'libx264', '-c:a', 'aac', '-pix_fmt', 'yuv420p'],
            }

            # "Optimization required..." ظاهر
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            
            if self.status_callback: self.status_callback("Done! Universal Format ✅")
            
        except Exception as e:
            print(f"Error: {e}")
            if self.status_callback: self.status_callback("Download Failed.")

    def start(self, url, path, mode, quality, ffmpeg_path):
        t = threading.Thread(target=self.download_task, args=(url, path, mode, quality, ffmpeg_path))
        t.daemon = True
        t.start()