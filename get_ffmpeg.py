import os
import sys
import urllib.request
import zipfile
import tarfile
import shutil
import ssl


ssl._create_default_https_context = ssl._create_unverified_context

def download_file(url, dest_path):
    print(f"Downloading from {url}...")
    try:
      
        req = urllib.request.Request(
            url, 
            data=None, 
            headers={
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
            }
        )
        with urllib.request.urlopen(req) as response, open(dest_path, 'wb') as out_file:
            shutil.copyfileobj(response, out_file)
        print("Download complete.")
    except Exception as e:
        print(f"Error downloading: {e}")
        sys.exit(1)

def setup_ffmpeg():
    if not os.path.exists("assets"):
        os.makedirs("assets")

    # 1. Windows Setup
    if sys.platform == "win32":
        print("Detected System: Windows")
        url = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
        zip_path = "ffmpeg.zip"
        download_file(url, zip_path)
        
        print("Extracting...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            for file in zip_ref.namelist():
                if file.endswith("bin/ffmpeg.exe"):
                    source = zip_ref.open(file)
                    target = open(os.path.join("assets", "ffmpeg.exe"), "wb")
                    with source, target:
                        shutil.copyfileobj(source, target)
                    break
        os.remove(zip_path)

    # 2. macOS Setup (Updated Link)
    elif sys.platform == "darwin":
        print("Detected System: macOS")
       
        url = "https://evermeet.cx/ffmpeg/getrelease/zip"
        zip_path = "ffmpeg_mac.zip"
        download_file(url, zip_path)
        
        print("Extracting...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        
            for file in zip_ref.namelist():
                if file.endswith("ffmpeg"): 
                    source = zip_ref.open(file)
                    target = open(os.path.join("assets", "ffmpeg"), "wb")
                    with source, target:
                        shutil.copyfileobj(source, target)
                    break
        
      
        if os.path.exists(os.path.join("assets", "ffmpeg")):
            os.chmod(os.path.join("assets", "ffmpeg"), 0o755)
            print("Permissions set.")
        else:
            print("Error: ffmpeg binary not found in zip.")
            sys.exit(1)
            
        os.remove(zip_path)

    # 3. Linux Setup
    else:
        print("Detected System: Linux")
        url = "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
        tar_path = "ffmpeg_linux.tar.xz"
        download_file(url, tar_path)
        
        print("Extracting...")
        with tarfile.open(tar_path, "r:xz") as tar:
            for member in tar.getmembers():
                if member.name.endswith("/ffmpeg"):
                    member.name = "ffmpeg"
                    tar.extract(member, "assets")
                    break
        os.remove(tar_path)

    print("✅ FFmpeg setup complete in 'assets/' folder.")

if __name__ == "__main__":
    setup_ffmpeg()