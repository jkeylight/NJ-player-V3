# NJ Player 3.0 — Instructions

## First-Time Setup

1. Open this folder in PowerShell
2. Run the installer:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

This downloads mpv and shaders into the folder. No admin rights needed. One-time only.

For full prerequisites and troubleshooting, see `BUILD-WINDOWS.md`.

---

## Launching

| Method | How |
|--------|-----|
| **GUI** | Double-click `NJ-Player-GUI.bat` |
| **Drag & Drop** | Drag a video onto `NJ-Player.bat` |
| **Desktop Shortcut** | Run `desktop-shortcut.ps1` once, then click "NJ Player" on desktop |
| **Main Menu** | Double-click `START-HERE.bat` for all options |

---

## Playing Videos

- Open the GUI → click **Browse Folder** → double-click a video or select and click **PLAY**
- Drag a video file directly onto `NJ-Player.bat`
- Drop files onto the mpv window that opens

---

## Enhancement Presets

| Key | Preset | Best For |
|-----|--------|----------|
| `CTRL+0` | Off | Clean playback |
| `CTRL+1` | Lucid | General sharpening |
| `CTRL+2` | Cinema | Low-res video restoration |
| `CTRL+3` | Anime | Animation / 2D content |
| `CTRL+4` | HDR | HDR to SDR tone mapping |
| `CTRL+5` | Denoise | Noise removal |
| `CTRL+6` | Motion | Frame interpolation |
| `CTRL+7` | Auto | Smart content detection |
| `CTRL+8` | Compare | Split-screen before/after |
| `CTRL+9` | Restore | Aggressive restoration |
| `F9` | Cycle | Toggle through all presets |

---

## GUI Tabs

### Player Tab
- Browse folders, select videos, pick enhancement preset
- **PICTURE** button opens brightness/contrast/saturation/gamma/hue sliders
- Click **PLAY** or double-click a video

### Playlist Tab
- Add videos to queue, reorder, shuffle, repeat
- Click **PLAY QUEUE** to play all in order

### Audio Tab
- Adjust noise reduction, dialogue boost, bass restore, stereo widen
- Toggle volume normalize and night mode
- Quick profiles: Movie, Music, Dialogue, Night

### Security Tab
- **Encrypt** — AES-256-GCM encryption with password
- **Decrypt & Play** — decrypt and play in one step
- **Secure Delete** — 35-pass Gutmann overwrite

### Presets Tab
- Customize sharpening, denoise, upscale, motion, HDR for each preset
- Save custom configurations

### Settings Tab
- Auto-detect content, hardware decoding, remember position
- Create desktop shortcut, clear history, clean temp

---

## Video Quality Controls

| Key | Action |
|-----|--------|
| `F2` | Open picture settings |
| `ALT+Left/Right` | Quick-adjust brightness |
| `ALT+Up/Down` | Quick-adjust contrast |
| `ALT+0` | Reset to defaults |
| `ALT+B` | Color boost (cinematic look) |

Settings save permanently in `.quality.txt`.

---

## Stream Quality (Web Links)

| Key | Action |
|-----|--------|
| `F3` | Show available resolutions and switch |

---

## Right-Click Menu (VLC-Style)

Right-click the video window for full context menu:
- Play / Pause / Stop
- Jump forward/backward
- Speed control (0.25x – 2x)
- A-B loop
- Audio / Video / Subtitle submenus
- Aspect ratio, Deinterlace
- Snapshot, Media info

---

## Audio Enhancement

| Key | Action |
|-----|--------|
| `CTRL+SHIFT+A` | Toggle audio enhancement |
| `CTRL+SHIFT+D` | Dialogue boost |

Adjust sliders in the **Audio** tab for fine control.

---

## Security / Encryption

### Encrypt a Video
1. Go to **Security** tab
2. Click **...** to select a file
3. Enter password (min 6 chars, confirm it)
4. Check "Secure delete original" if desired
5. Click **ENCRYPT**

### Decrypt and Play
1. Select the `.enc` file
2. Enter password
3. Click **DECRYPT & PLAY**

### Folder Batch Encryption
- Use the **Folder Encrypt** button in the GUI
- Or run: `python security/gencrypt.py encrypt-folder "C:\path\to\folder" --password "yourpass"`

### Keyfile Encryption
- Generate a keyfile: `python security/gencrypt.py genkey --output key.njkey`
- Encrypt with key: `python security/gencrypt.py encrypt video.mp4 --keyfile key.njkey`

### Secure Delete
- Select a file and click **SECURE DELETE** — 35-pass Gutmann overwrite

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `SPACE` | Play / Pause |
| `F` | Fullscreen |
| `ESC` | Exit fullscreen |
| `LEFT/RIGHT` | Seek ±5s |
| `UP/DOWN` | Seek ±30s |
| `M` | Mute |
| `V` | Subtitles |
| `B` | Audio track |
| `A` | Aspect ratio |
| `N` / `P` | Next / Previous |
| `T` | Show time |
| `G` / `H` | Subtitle delay |
| `SHIFT+S` | Snapshot |
| `[` / `]` | Speed down / up |
| `Q` | Quit |

---

## Multi-Language UI

The GUI supports:
- English
- हिन्दी (Hindi)
- Español (Spanish)

Switch language in the GUI settings.

---

## Files Overview

| File | Purpose |
|------|---------|
| `NJ-Player-GUI.bat` | Launch the GUI |
| `NJ-Player.bat` | Drag-and-drop launcher |
| `START-HERE.bat` | Main menu with all options |
| `install.ps1` | One-time installer |
| `NJ-Player-GUI.ps1` | GUI script (light theme, tabs) |
| `scripts/nj-presets.lua` | Enhancement preset engine |
| `scripts/auto-enhance.lua` | Smart content detection |
| `scripts/player-overlay.lua` | On-screen display |
| `scripts/audio-enhance.lua` | Audio processing |
| `scripts/compare-mode.lua` | Split-screen comparison |
| `scripts/zoom-control.lua` | Zoom controls |
| `scripts/performance-monitor.lua` | FPS and GPU stats |
| `mpv.conf` | Player configuration |
| `input.conf` | Keyboard shortcuts |
| `shaders/` | GPU enhancement shaders |
| `security/gencrypt.py` | Encryption engine |
| `security/encrypt.ps1` | Encrypt helper |
| `security/decrypt-play.ps1` | Decrypt and play |
| `nj-config/settings.json` | App settings |
| `update-shaders.ps1` | Shader updater |
| `log.ps1` | Log viewer |

---

## Troubleshooting

- **GUI freezes on launch** — Make sure you ran `install.ps1` first
- **"mpv not found"** — Run `install.ps1` to download mpv
- **No videos showing** — Click Browse Folder and select a folder with video files
- **Enhancement not working** — Check GPU supports OpenGL, press `CTRL+1` to enable Lucid
- **Encryption fails** — Ensure Python is installed (`python --version` in PowerShell)
- **Shaders lagging** — Auto-fallback drops heavy shaders; or switch to a lighter preset
- **Logs** — Run `log.ps1` or check the `temp/` folder for error logs
