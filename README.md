# NJ Player 3.0

An offline desktop video player for your downloaded videos, with a **"better Lucid Mode"** — real-time, GPU-accelerated video enhancement that goes beyond Opera's one-click sharpener.

- **Local files play fully offline** — no internet needed for downloaded videos (web links need internet, see below)
- **No AI** — pure GPU shader algorithms, fast and artifact-light
- **GPU-accelerated** — enhancement applies in real time as the video plays
- **Plays almost everything** — MP4, MKV, AVI, WebM, MOV and more (built on mpv)
- **Military-grade encryption** — AES-256-GCM with 35-pass secure deletion
- **Thumbnail grid view** — browse your library as a poster wall / live preview
- **Resume & recents** — jump back to where you left off
- **Keyfile + folder-batch encryption** — extra security and whole-library workflows
- **Multi-language UI** — English, हिन्दी, Español
- **Auto performance fallback** — drops heavy shaders when the GPU can't keep up

---

## Quick Start

> **Windows only.** For full prerequisites, first-run setup, build steps, and
> troubleshooting, see **[BUILD-WINDOWS.md](BUILD-WINDOWS.md)**.

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
| `ALT+CTRL+UP/DOWN` | Shift audio-video sync (±0.05s) |
| `CTRL+SHIFT+UP` | Reset audio delay to 0 |
| `CTRL+h` | Cycle hardware decoding |

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
- **Keyfile support** — combine a password with a random keyfile (both required to decrypt)
- **Folder-batch encryption** — encrypt every video/image in a folder in one go
- **Password strength meter** — check passwords from the command line

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

# Encrypt with a keyfile (password + keyfile both needed to decrypt)
python security\gencrypt.py encrypt video.mp4 --password "MySecret123" --keyfile mykey.bin
python security\gencrypt.py decrypt video.mp4.enc --password "MySecret123" --keyfile mykey.bin

# Encrypt a whole folder (videos + images)
python security\gencrypt.py encrypt-folder . --password "MySecret123"

# Check password strength (0-4 score + entropy estimate)
python security\gencrypt.py strength "MySecret123!"
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
├── update-shaders.ps1    <- fetches the latest enhancement shaders
├── log.ps1               <- shared logging helper (writes logs\)
├── mpv.conf              <- core config + enhancement profiles
├── input.conf            <- hotkey bindings
├── scripts/
│   ├── nj-presets.lua    <- preset switching
│   ├── player-overlay.lua <- player overlay
│   ├── audio-enhance.lua <- audio processing
│   ├── auto-enhance.lua  <- auto-detection + performance fallback
│   ├── zoom-control.lua  <- zoom & pan
│   ├── compare-mode.lua  <- split-screen
│   └── performance-monitor.lua <- GPU/CPU stats
├── security/
│   ├── gencrypt.py       <- encryption engine
│   ├── encrypt.ps1       <- encrypt dialog
│   ├── decrypt-play.ps1  <- decrypt & play
│   └── install-security.ps1 <- security setup
├── tests/
│   └── test_gencrypt.py  <- unit tests for the encryption engine
├── shaders/              <- enhancement shaders (created by install.ps1)
├── mpv/                  <- mpv + yt-dlp + ffmpeg (created by install.ps1)
├── nj-config/            <- user settings
├── library/              <- downloaded web videos
├── encrypted/            <- encrypted files
├── thumbnails/           <- cached thumbnails
├── watch_later/          <- resume positions
├── screenshots/          <- saved frames
└── temp/                 <- temporary files (auto-cleaned)
```

> **Build guide:** [BUILD-WINDOWS.md](BUILD-WINDOWS.md) — prerequisites, first-run
> setup, building the portable ZIP, and troubleshooting for Windows.

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

Done in 3.0.2: thumbnail grid view, playlist support, multi-language UI,
AV1/8K hardware-decode settings, external subtitles, resume/recents,
keyfile + folder-batch encryption, auto performance fallback.

Still planned:
- **Custom shader marketplace** — community shaders
- **Real-time thumbnail grid thumbnail cache** — pre-generated previews
- **Transcoding** — re-encode with nyto a target device

---

## License

This project is provided as-is for personal use. No warranty expressed or implied.
