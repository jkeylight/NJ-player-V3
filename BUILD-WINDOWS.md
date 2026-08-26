# Building & Running NJ Player on Windows

NJ Player 3.0 is **Windows-only** (PowerShell WinForms GUI + the mpv media player).
This guide walks through prerequisites, first-time setup, building a distributable,
and testing. It assumes you have already pulled repo (or merged PR #1).

---

## 1. Prerequisites

| Requirement | Why | Notes |
|-------------|-----|-------|
| **Windows 10 / 11 (64-bit)** | Required platform | macOS/Linux are not supported |
| **PowerShell 5.1+** | All scripts (`install.ps1`, `build.ps1`) | Built into Windows 10/11 — nothing to install |
| **Microsoft Visual C++ Redistributable (x64)** | mpv is a native Windows app | Without it mpv throws "DLL not found". Install, then **reboot** |
| **7-Zip** (recommended) | mpv recent builds are `.7z` archives | `Expand-Archive` only handles `.zip`. Without 7-Zip, mpv extraction is skipped |
| **Python 3.8+** (optional) | Encryption (`security\gencrypt.py`) | Check **"Add to PATH"** during install, or encryption fails. Not needed for plain playback |

> **Tip:** If you get `DLL not found` when mpv launches, the VC++ x64 redistributable is
> the usual cause — install it and reboot before troubleshooting anything else.

---

## 2. One-time PowerShell setup

Run this once, from **PowerShell (Admin)**:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

The `.bat` launchers bypass the policy on their own, but this keeps `install.ps1` /
`build.ps1` from being blocked when you run them from the PowerShell console.

---

## 3. First-time setup (downloads mpv, yt-dlp, ffmpeg + shaders)

In the project folder (Shift + Right-click → **Open PowerShell window here**):

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Everything downloads **into this folder** (nothing system-wide, no admin needed).
A window may flash during install.

To force a re-download of everything:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -Force
```

---

## 4. Build a distributable ZIP

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

| Switch | Effect |
|--------|--------|
| (none) | Full build, downloads deps + shaders |
| `-Clean` | Wipes `build/` and `dist/` first — use if you've built before to avoid stale files |
| `-SkipDownload` | Reuses existing `shaders/` and `mpv/` instead of re-downloading |

Output: **`dist\NJ-Player-3.0.2-portable.zip`**

> The build script now **bundles** whatever shaders/mpv files already exist in the repo,
> so the ZIP stays complete even if a download fails.

To refresh the enhancement shaders (e.g. after an upstream update):

```powershell
powershell -ExecutionPolicy Bypass -File update-shaders.ps1
```

### Optional: run the unit tests

The encryption engine ships with tests. With Python + `cryptography` installed:

```powershell
python -m pytest tests\test_gencrypt.py -v
# or without pytest:
python tests\test_gencrypt.py
```

---

## 5. Test the build

1. Extract the ZIP to any folder (use **7-Zip**).
2. Double-click `START-HERE.bat` (menu) or `NJ-Player-GUI.bat` (launcher).
3. Play a video, then:
   - Press `CTRL+7` (Auto) or `F9` (cycle presets).
   - Press **`TAB` then `2`** to open tech stats — you should see the shader pass names if enhancement is active.

**Sanity checks on the ZIP contents:**
- `nj-config\settings.json` and `nj-config\settings-loader.lua` present
- `shaders\` contains the files referenced by `mpv.conf`
- `mpv\mpv.exe` present

---

## 6. Running the app directly (no build needed)

For everyday use you don't have to build — just run from the folder:

- Double-click **`NJ-Player-GUI.bat`** → full launcher GUI
- Drag a video onto **`NJ-Player.bat`** → plays with your config
- Double-click **`START-HERE.bat`** → menu (GUI / folder / encrypt / decrypt / settings / check)

---

## 7. Troubleshooting

| Problem | Fix |
|---------|-----|
| `DLL not found` on mpv launch | Install VC++ x64 redistributable, reboot |
| Cinema/Restore preset stutters | Use `CTRL+1` (Lucid) — lighter GPU load |
| Everything stutters | Confirm `hwdec=auto-safe` in `mpv.conf` |
| Shaders not applying | Check `shaders\` has the files, re-run `install.ps1` |
| YouTube link won't play | Re-run `install.ps1` so yt-dlp is present |
| Encryption fails | Install Python with **"Add to PATH"**, then `pip install cryptography` |
| `.7z` extraction skipped | Install 7-Zip, re-run `install.ps1` |

---

## 8. Portability

Everything is self-contained — move the whole folder to a **USB stick** and it keeps
working (this is the core design goal). To uninstall, run `uninstall.ps1` or delete
the folder.

> **Encryption warning:** AES-256-GCM has no backdoor. A wrong or lost password means
> the file is **unrecoverable**. Back up the `security\gencrypt.py` piece if you use it.
