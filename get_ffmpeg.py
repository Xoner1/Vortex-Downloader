import os
import sys
import urllib.request
import zipfile
import tarfile
import shutil

def download_file(url, dest_path):
    print(f"Downloading from {url}...")
    try:
        urllib.request.urlretrieve(url, dest_path)
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
            #
            for file in zip_ref.namelist():
                if file.endswith("bin/ffmpeg.exe"):
                    source = zip_ref.open(file)
                    target = open(os.path.join("assets", "ffmpeg.exe"), "wb")
                    with source, target:
                        shutil.copyfileobj(source, target)
                    break
        os.remove(zip_path)

    # 2. macOS Setup
    elif sys.platform == "darwin":
        print("Detected System: macOS")
        url = "https://evermeet.cx/ffmpeg/ffmpeg-113364-g6b054a6597.zip" 
        zip_path = "ffmpeg_mac.zip"
        download_file(url, zip_path)
        
        print("Extracting...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extract("ffmpeg", "assets")
        
      
        os.chmod(os.path.join("assets", "ffmpeg"), 0o755)
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