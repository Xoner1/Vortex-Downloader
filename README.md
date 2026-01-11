# Vortex Downloader 🌀

![Vortex Logo](assets/icon.png)

**The Ultimate Cross-Platform Media Downloader.** *Fast. Secure. Private.*

---

## 📸 Screenshots

### Main Interface
> *Experience a clean, dark-themed UI designed for efficiency.*
![Main Interface Screenshot](assets/main_ui.png)

### Note for macOS Users
> *The app might show a secondary icon in the dock while processing.*
![macOS Dual Icon Example](assets/mac_dock.png)

---

## 🚀 Why Vortex? (Security & Privacy)

Unlike other downloaders, Vortex respects your data:

* 🔒 **100% Private:** No user data collection. No tracking.
* 🛡️ **No Malware/Adware:** Clean code, open for everyone to inspect.
* 📡 **No External Servers:** Processing happens locally on your machine. We don't send your links to third-party cloud servers.
* ♾️ **Unlimited:** No daily limits. Download 4K videos and High-Quality MP3s freely.
* 🔓 **Open Source:** Transparency is our core value.

---

## 📥 Download

Get the latest version for your operating system from the [Releases Page](LINK_TO_YOUR_RELEASES_PAGE_HERE).

| OS | Status |
| :--- | :--- |
| **Windows** | ✅ Tested (Windows 10/11) |
| **macOS** | ✅ Tested (Intel & Apple Silicon) |
| **Linux** | ✅ Tested (Ubuntu/Debian) |

---

## 🛠️ Installation & Troubleshooting

### 🪟 Windows
1. Download `Vortex-Windows.exe`.
2. Double-click to run.
3. *Note: If Windows SmartScreen appears, click "More Info" > "Run Anyway".*

### 🍎 macOS (Important Read)
Since this app is open-source and not signed by Apple's expensive developer certificate, you need to allow it once.

#### Step 1: Move to Applications
To ensure the app runs correctly, move it to your Applications folder.

**Method A (Manual):**
Drag the `Vortex.app` file into your `Applications` folder.

**Method B (Terminal):**
```bash
mv ~/Downloads/Vortex.app /Applications/


# Vortex Downloader 🌀

![Vortex Logo](assets/icon.png)

**The Ultimate Cross-Platform Media Downloader.** *Fast. Secure. Private.*

---

## 📸 Screenshots

### Main Interface
> *Experience a clean, dark-themed UI designed for efficiency.*
![Main Interface Screenshot](INSERT_MAIN_IMAGE_LINK_HERE)

### Note for macOS Users
> *The app might show a secondary icon in the dock while processing. This is normal behavior for the current version.*
![macOS Dual Icon Example](INSERT_ICON_IMAGE_LINK_HERE)

---

## 🚀 Why Vortex? (Security & Privacy)

Unlike other downloaders, Vortex respects your data:

* 🔒 **100% Private:** No user data collection. No tracking.
* 🛡️ **No Malware/Adware:** Clean code, open for everyone to inspect.
* 📡 **No External Servers:** Processing happens locally on your machine. We don't send your links to third-party cloud servers.
* ♾️ **Unlimited:** No daily limits. Download 4K videos and High-Quality MP3s freely.
* 🔓 **Open Source:** Transparency is our core value.

---

## 📥 Download

Get the latest version for your operating system from the [Releases Page](LINK_TO_YOUR_RELEASES_PAGE_HERE).

| OS | Status |
| :--- | :--- |
| **Windows** | ✅ Tested (Windows 10/11) |
| **macOS** | ✅ Tested (Intel & Apple Silicon) |
| **Linux** | ✅ Tested (Ubuntu/Debian) |

---

## 🛠️ Installation & Troubleshooting

### 🪟 Windows
1. Download `Vortex-Windows.exe`.
2. Double-click to run.
3. *Note: If Windows SmartScreen appears, click "More Info" > "Run Anyway".*

### 🍎 macOS (Important Read)
Since this app is open-source and not signed by Apple's expensive developer certificate, you need to allow it once.

#### Step 1: Move to Applications
To ensure the app runs correctly, move it to your Applications folder.

**Method A (Manual):**
Drag the `Vortex.app` file into your `Applications` folder.

**Method B (Terminal):**
```bash
mv ~/Downloads/Vortex.app /Applications/
Step 2: Open the App (Gatekeeper Fix)
When you open it for the first time, you might see: "Vortex cannot be opened because the developer cannot be verified."

Option A (Easy Way - Settings):

Click Cancel on the error popup.

Go to System Settings > Privacy & Security.

Scroll down to the Security section.

You will see a message about Vortex. Click "Open Anyway".

Confirm by clicking Open.

Option B (Pro Way - Terminal): If you prefer using the command line to fix the "Damaged" or "Unidentified" error instantly:

Bash

sudo xattr -rd com.apple.quarantine /Applications/Vortex.app
(Enter your password when prompted).

🐧 Linux
Download the binary file.

Make it executable:

Bash

chmod +x Vortex-Linux
Run it:

Bash

./Vortex-Linux
💻 For Developers (Build from Source)
If you want to run or modify the code yourself:

Clone the repo:

Bash

git clone [https://github.com/Xoner1/Vortex-Downloader.git](https://github.com/Xoner1/Vortex-Downloader.git)
Install requirements:

Bash

pip install -r requirements.txt
Run the app:

Bash

python main.py
📜 License
This project is licensed under the MIT License - see the LICENSE file for details.
