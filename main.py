
import customtkinter as ctk
from ui.main_window import VortexUI

if __name__ == "__main__":
    # Optional: Set global appearance before loading the app
    ctk.set_appearance_mode("Dark")
    ctk.set_default_color_theme("green")
    
    # Initialize the Application
    app = VortexUI()
    
    # Run the main loop
    app.mainloop()