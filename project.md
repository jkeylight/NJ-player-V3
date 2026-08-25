
# NJ PLAYER 3.0 — PROJECT DOCUMENTATION

## Offline Video Enhancement & Encryption Suite

---

## PROJECT OVERVIEW

NJ Player 3.0 is a fully offline desktop application that combines professional-grade video enhancement with military-grade encryption. Built on the mpv media player foundation, it adds GPU-accelerated shader pipelines for real-time video restoration, a complete audio enhancement suite, and seamless AES-256-GCM encryption with 35-pass secure deletion.

### Core Value Proposition
> **"Watch any video — enhanced to its full potential, protected by encryption, with zero internet dependency."**

### Key Principles
1. **Enhancement should be invisible** — if you notice it, it's too much
2. **Preserve the source** — never destroy original quality
3. **Security without compromise** — encryption that doesn't hinder usability
4. **Performance first** — smooth playback above all
5. **User control** — every enhancement can be adjusted or disabled

---

## SYSTEM ARCHITECTURE
┌─────────────────────────────────────────────────────────────────┐
│ NJ PLAYER 3.0 LAYERS │
├─────────────────────────────────────────────────────────────────┤
│ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ PRESENTATION LAYER (UI/UX) │ │
│ │ ┌───────────┐ ┌───────────┐ ┌───────────────────┐ │ │
│ │ │ Launcher │ │ Player │ │ Settings Panel │ │ │
│ │ │ GUI │ │ Overlay │ │ │ │ │
│ │ └───────────┘ └───────────┘ └───────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ↓ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ APPLICATION LAYER │ │
│ │ ┌───────────┐ ┌───────────┐ ┌───────────────────┐ │ │
│ │ │ Playback │ │ Enhance │ │ Security │ │ │
│ │ │ Manager │ │ Manager │ │ Manager │ │ │
│ │ └───────────┘ └───────────┘ └───────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ↓ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ENGINE LAYER │ │
│ │ ┌───────────┐ ┌───────────┐ ┌───────────────────┐ │ │
│ │ │ mpv │ │ Shader │ │ AES-256-GCM │ │ │
│ │ │ Engine │ │ Pipeline │ │ Encryption │ │ │
│ │ └───────────┘ └───────────┘ └───────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
│ │
└─────────────────────────────────────────────────────────────────┘

text

---

## FEATURE MATRIX

### Video Enhancement Presets

| # | Preset | Key | Shader Pipeline | Use Case |
|---|--------|-----|-----------------|----------|
| 0 | **Off** | `CTRL+0` | None | Clean playback |
| 1 | **Lucid** | `CTRL+1` | AdaptiveSharpen | Light enhancement |
| 2 | **Cinema** | `CTRL+2` | KrigBilateral → FSRCNNX x2 → SSimSuperRes → AdaptiveSharpen | Full pipeline for low-res |
| 3 | **Anime** | `CTRL+3` | Anime4K Restore → Upscale → AA → Deblur | 2D/Cartoon content |
| 4 | **HDR** | `CTRL+4` | HDR Tone Mapping (ACES) | HDR to SDR conversion |
| 5 | **Denoise** | `CTRL+5` | Bilateral Filter (Skin-Preserving) | Noisy footage |
| 6 | **Motion** | `CTRL+6` | Frame Interpolation (Adaptive) | Sports/Action |
| 7 | **Auto** | `CTRL+7` | Auto-Detection → Best Preset | Default for all |
| 8 | **Compare** | `CTRL+8` | Split-Screen | A/B testing |
| 9 | **Restore** | `CTRL+9` | Deband → Denoise → Deblock → Upscale → Sharpen | Severely degraded |

### Audio Enhancement

| Feature | Default | Range | Description |
|---------|---------|-------|-------------|
| Noise Reduction | 50% | 0-100% | Removes hiss and background noise |
| Dialogue Boost | 20% | 0-100% | Enhances speech clarity |
| Bass Restore | 30% | 0-100% | Adds warmth to thin audio |
| Volume Normalize | On | On/Off | Evens out volume levels |
| Stereo Widen | 0% | 0-100% | Spatial expansion |
| Night Mode | Off | On/Off | Compresses dynamic range |

### Security Features

| Feature | Description |
|---------|-------------|
| Encryption | AES-256-GCM (authenticated) |
| Key Derivation | PBKDF2 with 100,000 iterations |
| Secure Delete | 35-Pass Gutmann (configurable 1/3/7/35) |
| RAM Clearing | Automatic on exit |
| Auto-Lock | Configurable (1/5/15 min / Never) |
| Password Strength | Real-time indicator |
| Caps Lock Warning | Visual alert |
| Attempt Limiting | 5 attempts, then cool-down |

---

## FILE STRUCTURE
nj-player-3.0/
├── START-HERE.bat ← Main entry point
├── NJ-Player.bat ← Drag-and-drop launcher
├── NJ-Player-GUI.bat ← GUI launcher
├── NJ-Player-GUI.ps1 ← GUI (PowerShell)
├── build.ps1 ← Build system
├── uninstall.ps1 ← Clean removal
├── install.ps1 ← One-time setup
├── associate.ps1 ← Right-click integration
├── desktop-shortcut.ps1 ← Desktop icon
├── clear-history.ps1 ← Wipe history
├── make-icon.ps1 ← Icon generator
├── nj-player.ico ← App icon
├── mpv.conf ← Core config
├── input.conf ← Hotkeys
├── README.md ← User documentation
├── PROJECT.md ← This file
├── VERSION.txt ← Version info
├── CHECKSUM.txt ← File integrity
│
├── config/
│ ├── settings.json ← User preferences
│ ├── settings-loader.lua ← Settings manager
│ └── profiles/
│ ├── default.json
│ └── custom.json
│
├── scripts/
│ ├── nj-presets.lua ← Enhancement presets
│ ├── player-overlay.lua ← Minimal overlay
│ ├── audio-enhance.lua ← Audio processing
│ ├── auto-enhance.lua ← Auto-detection
│ ├── zoom-control.lua ← Zoom & pan
│ ├── performance-monitor.lua ← GPU/CPU stats
│ └── compare-mode.lua ← Split-screen
│
├── security/
│ ├── gencrypt.py ← Encryption engine
│ ├── encrypt.ps1 ← Encrypt dialog
│ ├── decrypt-play.ps1 ← Decrypt & play
│ └── install-security.ps1 ← Security setup
│
├── shaders/
│ ├── adaptive-sharpen.glsl ← Lucid preset
│ ├── krigbilateral.glsl ← Chroma upscaling
│ ├── fsrcnnx_x2_8-0-4-1.glsl ← 2x upscaling
│ ├── ssimsuperres.glsl ← De-ringing
│ ├── anime4k_restore.glsl ← Anime restoration
│ ├── anime4k_upscale.glsl ← Anime upscaling
│ ├── anime4k_aa.glsl ← Anime anti-aliasing
│ ├── hdr-tonemap.glsl ← HDR to SDR
│ ├── denoise-skin.glsl ← Skin-preserving denoise
│ ├── deband.glsl ← Color banding removal
│ ├── deblock.glsl ← Blocking artifact removal
│ ├── motion-interpolate.glsl ← Frame interpolation
│ └── compare-mode.glsl ← Split-screen
│
├── mpv/
│ ├── mpv.exe ← Media player
│ ├── yt-dlp.exe ← Web link support
│ └── ffmpeg.exe ← Video processing
│
├── library/ ← Downloaded videos
├── encrypted/ ← Encrypted files
├── thumbnails/ ← Cached thumbnails
├── watch_later/ ← Resume positions
├── screenshots/ ← Saved frames
└── temp/ ← Temporary files (auto-cleaned)

text

---

## HOTKEY REFERENCE

### Enhancement

| Key | Action |
|-----|--------|
| `CTRL+0` | Off |
| `CTRL+1` | Lucid |
| `CTRL+2` | Cinema |
| `CTRL+3` | Anime |
| `CTRL+4` | HDR |
| `CTRL+5` | Denoise |
| `CTRL+6` | Motion |
| `CTRL+7` | Auto |
| `CTRL+8` | Compare Mode |
| `CTRL+9` | Restore |
| `F9` | Cycle all presets |

### Audio

| Key | Action |
|-----|--------|
| `CTRL+SHIFT+A` | Toggle Audio Enhancement |
| `CTRL+SHIFT+D` | Toggle Dialogue Boost |
| `CTRL+SHIFT+N` | Toggle Noise Reduction |
| `CTRL+SHIFT+V` | Toggle Volume Normalize |
| `CTRL+SHIFT+B` | Toggle Bass Restore |
| `CTRL+SHIFT+W` | Toggle Stereo Widen |
| `CTRL+SHIFT+M` | Toggle Night Mode |

### Video

| Key | Action |
|-----|--------|
| `Z` | Cycle Zoom (1.0x → 4.0x) |
| `ALT+UP` | Zoom In |
| `ALT+DOWN` | Zoom Out |
| `ALT+0` | Reset Zoom |
| `CTRL+LEFT/RIGHT` | Pan Horizontal |
| `CTRL+UP/DOWN` | Pan Vertical |
| `C` | Crop Black Bars |
| `R` | Rotate 90° |
| `H` | Flip Horizontal |
| `,` | Frame Back |
| `.` | Frame Forward |
| `S` | Screenshot |

### Security

| Key | Action |
|-----|--------|
| `CTRL+E` | Encrypt Current Video |
| `CTRL+D` | Decrypt & Play |
| `CTRL+SHIFT+DEL` | Secure Delete (35-Pass) |
| `CTRL+L` | Lock Player |

### Navigation

| Key | Action |
|-----|--------|
| `Space` | Play/Pause |
| `←` / `→` | Seek 5s |
| `↑` / `↓` | Seek 60s |
| `[` / `]` | Speed Down/Up |
| `F` | Fullscreen |
| `M` | Mute |
| `TAB` + `2` | Tech Stats |
| `SHIFT+H` | Help Overlay |
| `CTRL+SHIFT+P` | Performance Monitor |

---

## SECURITY SPECIFICATION

### Encryption Flow
User selects video
↓
Enters password
↓
PBKDF2-SHA256 (100,000 iterations) → 256-bit key
↓
Generate random 256-bit salt + 96-bit IV
↓
Stream video in 1MB chunks
↓
AES-256-GCM encrypt each chunk
↓
Write .enc file with 128-byte header
↓
Optional: 35-pass secure delete original

text

### Encrypted File Format
Offset Size Description
────── ────── ─────────────────────────────
0 4 Magic bytes ("GENC")
4 2 Version (1)
6 32 Salt (random)
38 12 IV (random)
50 64 Original filename (padded)
114 1 File type (0=video, 1=image)
115 8 Original size (bytes)
123 5 Reserved (zeros)
128 ... Encrypted chunks (1MB each)
... 16 GCM authentication tag

text

### Secure Deletion (35-Pass Gutmann)

| Pass Range | Pattern |
|------------|---------|
| 1-4 | Fixed patterns (0x55, 0xAA, 0x924924, 0x492492) |
| 5-21 | Bit patterns (0x00 through 0xFF) |
| 22-27 | Reversed + special patterns |
| 28-31 | Cryptographically secure random |
| 32-34 | Final special patterns |
| 35 | Zeros (final pass) |

---

## PERFORMANCE REQUIREMENTS

### Minimum Specifications

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | Intel i3 / AMD Ryzen 3 | Intel i5 / AMD Ryzen 5 |
| RAM | 4 GB | 8 GB |
| GPU | Intel HD 4000 | NVIDIA GTX 1050+ |
| Storage | 500 MB free | 1 GB free |
| Display | 1366×768 | 1920×1080 |

### GPU Load Targets

| Preset | Target Load |
|--------|-------------|
| Off | <5% |
| Lucid | <15% |
| Cinema | <40% |
| Anime | <30% |
| HDR | <10% |
| Denoise | <25% |
| Motion | <35% |

---

## BUILD INSTRUCTIONS

### Prerequisites
- Windows 10/11 (x64)
- PowerShell 5.1+
- Python 3.8+ (for encryption)
- Internet (one-time download only)

### Build Steps

```powershell
# 1. Clone/download the project
# 2. Run one-time setup
.\install.ps1

# 3. Run security setup
.\install-security.ps1

# 4. Build distributable
.\build.ps1

# 5. Test the build
.\START-HERE.bat
Distribution
powershell
# Create portable ZIP
.\build.ps1 -Target portable

# Clean build
.\build.ps1 -Clean

# Build without re-downloading
.\build.ps1 -SkipDownload
TESTING CHECKLIST
Critical Tests
□ Enhancement presets all work
□ Skin preservation verified (no plastic look)
□ Encryption round-trip succeeds
□ Wrong password rejected
□ Secure deletion completes
□ Compare mode works
□ Audio enhancement audible
□ Auto-detection accurate
□ Settings persist
□ GPU load within targets
Edge Cases
□ 4GB+ file encryption
□ Unicode filenames
□ Interrupted operations
□ Missing dependencies
□ Corrupted encrypted files
□ Multiple monitors
□ Different GPU vendors
KNOWN LIMITATIONS
Cannot create detail that doesn't exist — Enhancement improves what's there, doesn't invent

Below 240p is unwatchable — Too little data to restore meaningfully

Motion interpolation may cause soap-opera effect — Use sparingly

35-pass deletion is slow on large files — 4GB takes ~30-60 minutes on HDD

Temp files exist briefly during decryption — Shredded after playback

Python required for encryption — Not needed for playback only

ROADMAP
Version 3.1 (Planned)
□ Thumbnail grid view
□ Playlist support
□ Cloud backup (optional, encrypted)
□ Multi-language UI
□ Custom shader marketplace
Version 3.2 (Planned)
□ AV1 hardware decoding
□ 8K support
□ HDR passthrough
□ Spatial audio
□ Voice control
Version 4.0 (Vision)
□ AI-assisted enhancement (optional)
□ Real-time translation subtitles
□ Content-aware auto-editing
□ Cross-platform (macOS, Linux)
□ Mobile companion app
TROUBLESHOOTING
Common Issues
Problem	Solution
"DLL not found"	Install VC++ Redistributable
Shaders not applying	Re-run install.ps1
GPU not supported	Fall back to CPU rendering
Password incorrect	Check Caps Lock, try again
File corrupted	Restore from backup
Out of memory	Use temp file mode
Video stutters	Use CTRL+1 (Lucid) instead of Cinema
Plastic skin	Reduce denoise strength
Getting Help
Check README.md for user documentation

Check PROJECT.md (this file) for technical details

Check CHECKSUM.txt for file integrity

Look for error messages in console output

Check temp/ folder for leftover files

CONTRIBUTING
Adding New Shaders
Download .glsl file to shaders/

Add profile to mpv.conf

Register in nj-presets.lua

Add hotkey to input.conf

Document in README.md

Adding New Audio Filters
Add filter to audio-enhance.lua

Register toggle function

Add key binding

Update settings.json

Document in README.md

Adding Security Features
Add to security/gencrypt.py

Update encrypt.ps1 / decrypt-play.ps1

Register right-click in associate.ps1

Document in PROJECT.md

LICENSE
This project is provided as-is for personal use. No warranty expressed or implied.

CONTACT
For bugs, feature requests, or contributions:

Open an issue in the project repository

Check existing documentation first

Include system info with bug reports

VERSION HISTORY
Version	Date	Changes
1.0	-	Initial mpv setup
2.0	-	Added enhancement shaders
3.0	-	Complete rewrite: encryption, audio, auto-detection, compare mode, GUI, settings, build system
END OF PROJECT DOCUMENTATION

text

---

Save this as `PROJECT.md` in your project root. It covers:

- **Complete architecture** — all 3 layers
- **Full feature matrix** — every preset and filter
- **File structure** — every file documented
- **Hotkey reference** — all keyboard shortcuts
- **Security spec** — encryption format, secure deletion
- **Performance targets** — GPU load expectations
- **Build instructions** — how to compile and distribute
- **Testing checklist** — what to verify
- **Known limitations** — honest constraints
- **Roadmap** — future plans
- **Troubleshooting** — common fixes
- **Contributing** — how to extend