import customtkinter as ctk
from tkinter import filedialog, PhotoImage  
import os
import sys  
from core.downloader import VortexDownloader
from environment import get_ffmpeg_path

class VortexUI(ctk.CTk):
    def __init__(self):
        super().__init__()

        # --- Window Configuration ---
        self.title("Vortex Downloader")
        self.geometry("500x650")
        self.resizable(False, False)
        
        
        self.setup_icon()
        # -----------------------------------
        
        # --- Colors & Theme ---
        ctk.set_appearance_mode("Dark")
        self.green_color = "#28a745"
        self.green_hover = "#218838"
        
        # --- Logic Initialization ---
        self.downloader = VortexDownloader(progress_callback=self.update_progress, status_callback=self.update_status)
        self.mode = "video"
        self.save_path = os.path.join(os.path.expanduser("~"), "Downloads") 

        self.setup_ui()

    def setup_ui(self):
        # 1. Header & Theme Toggle
        self.header_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.header_frame.pack(pady=20, padx=20, fill="x")
        
        self.title_label = ctk.CTkLabel(self.header_frame, text="VORTEX", font=("Arial", 30, "bold"))
        self.title_label.pack(side="left")

        self.theme_btn = ctk.CTkButton(self.header_frame, text="🌓", width=40, height=40, 
                                       fg_color="transparent", border_width=2,
                                       command=self.toggle_theme)
        self.theme_btn.pack(side="right")

        # 2. URL Input
        self.url_entry = ctk.CTkEntry(self, placeholder_text="Paste Link Here...", width=420, height=50,
                                      corner_radius=25, border_width=2)
        self.url_entry.pack(pady=10)

        # 3. Mode Selection (Video / Audio)
        self.mode_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.mode_frame.pack(pady=10)

        self.btn_video = ctk.CTkButton(self.mode_frame, text="VIDEO", width=120, height=35,
                                       fg_color=self.green_color,
                                       command=lambda: self.set_mode("video"))
        self.btn_video.grid(row=0, column=0, padx=10)

        self.btn_audio = ctk.CTkButton(self.mode_frame, text="AUDIO (MP3)", width=120, height=35,
                                       fg_color="transparent", border_width=2,
                                       command=lambda: self.set_mode("audio"))
        self.btn_audio.grid(row=0, column=1, padx=10)

        # 4. Quality Selector
        self.quality_menu = ctk.CTkOptionMenu(self, values=["1080", "720", "480", "360"], width=160, height=35)
        self.quality_menu.pack(pady=10)

        # 5. Folder Selector
        self.path_btn = ctk.CTkButton(self, text=f"📂 {os.path.basename(self.save_path)}", 
                                      fg_color="transparent", border_width=1, width=200,
                                      command=self.choose_folder)
        self.path_btn.pack(pady=5)

        # 6. Status Label
        self.status_label = ctk.CTkLabel(self, text="Ready", font=("Arial", 14), text_color="gray")
        self.status_label.pack(pady=(20, 5))

        # 7. Start Button
        self.start_btn = ctk.CTkButton(self, text="START DOWNLOAD", width=300, height=55,
                                       corner_radius=28, font=("Arial", 16, "bold"),
                                       fg_color=self.green_color, hover_color=self.green_hover,
                                       command=self.start_download)
        self.start_btn.pack(pady=10)

        # 8. Info Panel
        self.info_frame = ctk.CTkFrame(self, width=400, height=80, corner_radius=15)
        self.info_frame.pack(pady=20)
        self.info_frame.pack_propagate(False)

        self.lbl_speed = ctk.CTkLabel(self.info_frame, text="0 MB/s", font=("Arial", 12, "bold"))
        self.lbl_speed.place(relx=0.1, rely=0.5, anchor="w")

        self.lbl_percent = ctk.CTkLabel(self.info_frame, text="0%", font=("Arial", 22, "bold"), text_color=self.green_color)
        self.lbl_percent.place(relx=0.5, rely=0.5, anchor="center")

        self.lbl_size = ctk.CTkLabel(self.info_frame, text="0 MB", font=("Arial", 12, "bold"))
        self.lbl_size.place(relx=0.9, rely=0.5, anchor="e")

    # --- Functions ---
    def toggle_theme(self):
        if ctk.get_appearance_mode() == "Dark":
            ctk.set_appearance_mode("Light")
        else:
            ctk.set_appearance_mode("Dark")

    def set_mode(self, mode):
        self.mode = mode
        if mode == "video":
            self.btn_video.configure(fg_color=self.green_color, border_width=0)
            self.btn_audio.configure(fg_color="transparent", border_width=2)
            self.quality_menu.pack(pady=10, before=self.path_btn)
        else:
            self.btn_audio.configure(fg_color=self.green_color, border_width=0)
            self.btn_video.configure(fg_color="transparent", border_width=2)
            self.quality_menu.pack_forget()

    def choose_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.save_path = folder
            self.path_btn.configure(text=f"📂 {os.path.basename(folder)}")

    def update_progress(self, data):
        self.lbl_speed.configure(text=data['speed'])
        self.lbl_size.configure(text=data['total'])
        self.lbl_percent.configure(text=f"{data['percent']}%")

    def update_status(self, msg):
        self.status_label.configure(text=msg)

    def start_download(self):
        url = self.url_entry.get()
        if not url:
            self.status_label.configure(text="Please enter a URL!", text_color="#FF5555")
            return
        
        ffmpeg_bin = get_ffmpeg_path()
        
        if not os.path.exists(ffmpeg_bin) and ffmpeg_bin != "ffmpeg":
            self.status_label.configure(text="FFmpeg missing in assets!", text_color="#FF5555")
            return

        self.status_label.configure(text="Initializing...", text_color="white")
        quality = self.quality_menu.get()
        self.downloader.start(url, self.save_path, self.mode, quality, ffmpeg_bin)
        
    def setup_icon(self):
        
        current_dir = os.path.dirname(os.path.abspath(__file__))
        project_dir = os.path.dirname(current_dir)
        assets_dir = os.path.join(project_dir, "assets")
        
        icon_ico = os.path.join(assets_dir, "icon.ico")
        icon_png = os.path.join(assets_dir, "icon.png")

        try:
            if sys.platform.startswith("win"):
                self.iconbitmap(icon_ico)
            else:
                icon_img = PhotoImage(file=icon_png)
                self.iconphoto(False, icon_img)
        except Exception as e:
            print(f"Warning: Could not load icon. {e}")