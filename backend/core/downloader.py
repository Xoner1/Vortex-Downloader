import yt_dlp
import threading
import os
import asyncio

class VortexDownloader:
    def __init__(self, task_id=None, progress_queue=None):
        self.task_id = task_id
        self.progress_queue = progress_queue
        self.loop = asyncio.get_event_loop()

    def _send_progress(self, data):
        if self.progress_queue and self.loop:
            asyncio.run_coroutine_threadsafe(self.progress_queue.put({"type": "progress", "data": data, "task_id": self.task_id}), self.loop)

    def _send_status(self, status):
        if self.progress_queue and self.loop:
            asyncio.run_coroutine_threadsafe(self.progress_queue.put({"type": "status", "data": status, "task_id": self.task_id}), self.loop)

    def progress_hook(self, d):
        if d['status'] == 'downloading':
            p = d.get('_percent_str', '0%').replace('%', '').strip()
            speed = d.get('_speed_str', '0 B/s').strip()
            total = d.get('_total_bytes_str') or d.get('_total_bytes_estimate_str', 'N/A')
            total = total.strip() if total != 'N/A' else total

            self._send_progress({
                "percent": p,
                "speed": speed,
                "total": total
            })

        elif d['status'] == 'finished':
            self._send_status("Verifying Media Data...")

    def download_task(self, url, path, mode, quality, ffmpeg_path):
       
        if mode == 'audio':
            self.download_audio(url, path, ffmpeg_path)
            return

     
        self._send_status("Checking for Direct-Play version...")
        success = self.try_fast_download(url, path, quality, ffmpeg_path)
        
        if not success:
            self._send_status("Optimization required. Converting video...")
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
            self._send_status("Downloading Audio...")
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            self._send_status("Audio Ready! 🎵")
        except Exception as e:
            self._send_status("Audio Failed.")

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
            
            self._send_status("Done! (Direct Play) 🚀")
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

            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            
            self._send_status("Done! Universal Format ✅")
            
        except Exception as e:
            print(f"Error: {e}")
            self._send_status("Download Failed.")

    def start(self, url, path, mode, quality, ffmpeg_path):
        t = threading.Thread(target=self.download_task, args=(url, path, mode, quality, ffmpeg_path))
        t.daemon = True
        t.start()
