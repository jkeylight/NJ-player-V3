# NJ Player 3.0

An offline desktop video player for your downloaded videos, with a **"better Lucid Mode"** — real-time, GPU-accelerated video enhancement that goes beyond Opera's one-click sharpener.

- **Local files play fully offline** — no internet needed for downloaded videos (web links need internet, see below)
- **No AI** — pure GPU shader algorithms, fast and artifact-light
- **GPU-accelerated** — enhancement applies in real time as the video plays
- **Plays almost everything** — MP4, MKV, AVI, WebM, MOV and more (built on mpv)
- **Military-grade encryption** — AES-256-GCM with 35-pass secure deletion

---

## Quick Start

1. Open this folder in PowerShell and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File install.ps1
   ```

   This downloads a portable mpv build and the enhancement shaders **into this folder** (nothing is installed system-wide, no admin needed). A small window may flash during install.

2. **Play a video** — two ways:
   - **GUI (easiest):** double-click `NJ-Player-GUI.bat` — it lists your videos, you pick an enhancement preset and hit PLAY.
   - **Drag & drop:** drag a video file onto `NJ-Player.bat` (or double-click it, then drop files onto the mpv window).

3. **Enhance** — press `F9` to cycle enhancement presets, or `CTRL+1..9` to jump straight to one. The current mode shows in the corner of the screen.

---

## Enhancement Presets

| Key | Preset | What it does |
|-----|--------|--------------|
| `CTRL+0` | **Off** | Clean, unmodified playback |
| `CTRL+1` | **Lucid** | Smart adaptive sharpening — the Opera Lucid Mode look, without the over-sharpening artifacts |
| `CTRL+2` | **Cinema** | Full pipeline for low-res video: KrigBilateral (better color) → FSRCNNX x2 (upscale) → SSimSuperRes (de-ring) → adaptive sharpen |
| `CTRL+3` | **Anime** | Anime4K — restores line art and removes compression artifacts (also helps on cartoons/2D content) |
| `CTRL+4` | **HDR** | HDR to SDR tone mapping |
| `CTRL+5` | **Denoise** | Skin-preserving noise removal |
| `CTRL+6` | **Motion** | Frame interpolation for smooth motion |
| `CTRL+7` | **Auto** | Smart content detection |
| `CTRL+8` | **Compare** | Split-screen original vs enhanced |
| `CTRL+9` | **Restore** | Full restoration for severely degraded video |

`F9` cycles through all presets.

---

## Right-Click "Open with NJ Player" (Windows)

Run once to add **"Open with NJ Player"** to the right-click menu of every file:

```powershell
powershell -ExecutionPolicy Bypass -File associate.ps1
```

To remove it again: `powershell -ExecutionPolicy Bypass -File associate.ps1 -Remove`

---

## Desktop Icon

Run once to put an **NJ Player** icon on your Desktop:

```powershell
powershell -ExecutionPolicy Bypass -File desktop-shortcut.ps1
```

Remove it with `-Remove`.

---

## Playing Links from the Web (YouTube, Twitch, Live Streams)

NJ Player can also play web links. In the GUI, paste a link into the **Link** bar (bottom) and hit **Play Link** (or press Enter).

This needs internet, of course — downloaded videos still play fully offline.

---

## All Hotkeys

| Key | Action |
|-----|--------|
| `F9` | Cycle enhancement presets |
| `CTRL+0` / `1` / `2` / `3` / ... / `9` | Pick preset: Off / Lucid / Cinema / Anime / ... / Restore |
| `CTRL+d` | Toggle debanding |
| `CTRL+SHIFT+A` | Toggle audio enhancement |
| `CTRL+SHIFT+D` | Toggle dialogue boost |
| `CTRL+SHIFT+N` | Toggle noise reduction |
| `CTRL+SHIFT+V` | Toggle volume normalize |
| `CTRL+SHIFT+B` | Toggle bass restore |
| `CTRL+SHIFT+W` | Toggle stereo widen |
| `CTRL+SHIFT+M` | Toggle night mode |
| `z` | Cycle zoom |
| `ALT+UP/DOWN` | Zoom in/out |
| `CTRL+ARROWS` | Pan |
| `c` | Crop black bars |
| `r` | Rotate 90° |
| `h` | Flip horizontal |
| `s` | Screenshot |
| `TAB` then `2` | Show tech stats |
| `SHIFT+H` | Help overlay |
| `CTRL+SHIFT+P` | Performance monitor |
| `CTRL+E` | Encrypt current video |
| `CTRL+D` | Decrypt & play |
| `CTRL+L` | Lock player |
| `CTRL+BACKSPACE` | Clear resume position |

Plus all standard mpv controls: `space` play/pause, `←`/`→` seek 5s, `↑`/`↓` seek 60s, `[`/`]` speed, `f` fullscreen, `m` mute.

---

## Encryption (Requires Python)

NJ Player includes **GenCrypt** — a military-grade encryption engine for your videos and images.

### Quick Start

1. Install Python 3.8+ from https://python.org/downloads
2. Run: `python security/gencrypt.py encrypt video.mp4 --password "YourPassword"`
3. Play encrypted file: `python security/gencrypt.py decrypt video.mp4.enc --password "YourPassword"`

### Features

- **AES-256-GCM encryption** — authenticated encryption
- **PBKDF2 key derivation** — 100,000 iterations
- **Streaming encryption** — handles large files without loading into RAM
- **35-pass secure deletion** — Gutmann method

### Usage

```powershell
# Encrypt a video
python security\gencrypt.py encrypt video.mp4 --password "MySecret123"

# Decrypt a video
python security\gencrypt.py decrypt video.mp4.enc --password "MySecret123"

# Secure delete a file
python security\gencrypt.py shred secret.mp4

# Encrypt and delete original
python security\gencrypt.py encrypt video.mp4 --password "MySecret123" --delete-original
```

---

## Where Does Everything Live?

```
nj-player/
├── NJ-Player-GUI.bat     <- launcher GUI (double-click me)
├── NJ-Player-GUI.ps1     <- the GUI itself (PowerShell WinForms)
├── NJ-Player.bat         <- drag-and-drop launcher
├── START-HERE.bat        <- main entry point
├── associate.ps1         <- right-click "Open with NJ Player"
├── desktop-shortcut.ps1  <- desktop icon
├── make-icon.ps1         <- draws the NJ Player logo
├── nj-player.ico         <- the custom logo
├── install.ps1           <- one-time setup (downloads mpv + shaders)
├── mpv.conf              <- core config + enhancement profiles
├── input.conf            <- hotkey bindings
├── scripts/
│   ├── nj-presets.lua    <- preset switching
│   ├── player-overlay.lua <- player overlay
│   ├── audio-enhance.lua <- audio processing
│   ├── auto-enhance.lua  <- auto-detection
│   ├── zoom-control.lua  <- zoom & pan
│   ├── compare-mode.lua  <- split-screen
│   └── performance-monitor.lua <- GPU/CPU stats
├── security/
│   ├── gencrypt.py       <- encryption engine
│   ├── encrypt.ps1       <- encrypt dialog
│   ├── decrypt-play.ps1  <- decrypt & play
│   └── install-security.ps1 <- security setup
├── shaders/              <- enhancement shaders (created by install.ps1)
├── mpv/                  <- mpv + yt-dlp + ffmpeg (created by install.ps1)
├── config/               <- user settings
├── library/              <- downloaded web videos
├── encrypted/            <- encrypted files
├── thumbnails/           <- cached thumbnails
├── watch_later/          <- resume positions
├── screenshots/          <- saved frames
└── temp/                 <- temporary files (auto-cleaned)
```

Everything is self-contained in this folder — you can move it anywhere (USB stick works) and it keeps working. To uninstall, run `uninstall.ps1` or delete the folder.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Video stutters on Cinema preset | Your GPU is doing heavy upscaling. Use `CTRL+1` (Lucid) instead, or press `CTRL+h` to toggle hardware decoding |
| YouTube link won't play | Run `install.ps1` again so yt-dlp is present; check the link works in a browser first |
| Shaders not applying | Press `TAB` then `2` — you should see the pass names. If not, run `install.ps1` again |
| mpv.exe won't start ("DLL not found") | Install the Microsoft Visual C++ Redistributable |
| Playback position not remembered | That's `save-position-on-quit` in `mpv.conf` — make sure the config wasn't modified |
| Video stutters with interpolation | Edit `mpv.conf` and set `interpolation=no` |
| Wrong volume (too quiet/loud) | Volume can go to 200% (`volume-max=200` in mpv.conf) |

---

## What's Next (Roadmap)

- **Thumbnail grid view** — browse all videos as a poster wall
- **Playlist support** — queue multiple videos
- **Multi-language UI** — international support
- **Custom shader marketplace** — community shaders
- **AV1 hardware decoding** — next-gen codec support
- **8K support** — future-proof

---

## License

This project is provided as-is for personal use. No warranty expressed or implied.
