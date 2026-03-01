import sys
import os

def get_base_path():
    """ 
    Get the base path of the project.
    Works for both development (script) and production (PyInstaller .app/.exe).
    """
    if getattr(sys, 'frozen', False):
        return sys._MEIPASS
    return os.path.dirname(os.path.abspath(__file__))

def get_ffmpeg_path():
    """ 
    Returns the absolute path to the FFmpeg executable 
    located in the 'assets' folder.
    """
    base_path = get_base_path()
    
    if sys.platform == "win32":
        ffmpeg_binary = "ffmpeg.exe"
    else:
        # For Mac and Linux
        ffmpeg_binary = "ffmpeg"
        
    path = os.path.join(base_path, "assets", ffmpeg_binary)
    return path