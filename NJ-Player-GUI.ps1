# ============================================
# NJ PLAYER 3.0 - FULL FEATURED GUI
# All features from the spec
# ============================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Paths ---
$RootDir = $PSScriptRoot
$MpvExe = Join-Path $RootDir "mpv\mpv.exe"
$FfmpegExe = Join-Path $RootDir "mpv\ffmpeg.exe"
$ScreenshotsDir = Join-Path $RootDir "screenshots"
$EncryptedDir = Join-Path $RootDir "encrypted"
$LibraryDir = Join-Path $RootDir "library"
$TempDir = Join-Path $RootDir "temp"
$GencryptPy = Join-Path $RootDir "security\gencrypt.py"

# Video extensions
$videoExts = @('.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.wmv', '.m4v', '.ts', '.mts', '.m2ts')

# Ensure directories exist
foreach ($d in @($ScreenshotsDir, $EncryptedDir, $LibraryDir, $TempDir)) {
    if (-not (Test-Path $d)) { New-Item -Path $d -ItemType Directory -Force | Out-Null }
}

# ============================================
# MAIN FORM
# ============================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "NJ Player 3.0 - Video Enhancement & Encryption"
$form.Size = New-Object System.Drawing.Size(860, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 245)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# ============================================
# HEADER
# ============================================
$header = New-Object System.Windows.Forms.Panel
$header.Dock = "Top"
$header.Height = 55
$header.BackColor = [System.Drawing.Color]::FromArgb(0, 102, 178)
$form.Controls.Add($header)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "NJ PLAYER 3.0"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Location = New-Object System.Drawing.Point(15, 8)
$titleLabel.Size = New-Object System.Drawing.Size(300, 40)
$header.Controls.Add($titleLabel)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Offline Video Enhancement & Encryption"
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
$subtitleLabel.Location = New-Object System.Drawing.Point(250, 18)
$subtitleLabel.Size = New-Object System.Drawing.Size(350, 25)
$header.Controls.Add($subtitleLabel)

# ============================================
# TAB CONTROL (all features)
# ============================================
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(10, 65)
$tabs.Size = New-Object System.Drawing.Size(830, 500)
$tabs.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($tabs)

# ============================================
# TAB 1: PLAYER
# ============================================
$tabPlayer = New-Object System.Windows.Forms.TabPage
$tabPlayer.Text = "  Player  "
$tabPlayer.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($tabPlayer)

# Preset selection
$playerPresetLabel = New-Object System.Windows.Forms.Label
$playerPresetLabel.Text = "Enhancement:"
$playerPresetLabel.Location = New-Object System.Drawing.Point(15, 15)
$playerPresetLabel.Size = New-Object System.Drawing.Size(100, 25)
$tabPlayer.Controls.Add($playerPresetLabel)

$presets = @("Off", "Lucid", "Cinema", "Anime", "HDR", "Denoise", "Motion", "Auto", "Compare", "Restore")
$presetDropdown = New-Object System.Windows.Forms.ComboBox
$presetDropdown.Location = New-Object System.Drawing.Point(120, 12)
$presetDropdown.Size = New-Object System.Drawing.Size(150, 28)
$presetDropdown.DropDownStyle = "DropDownList"
$presetDropdown.Font = New-Object System.Drawing.Font("Segoe UI", 11)
foreach ($p in $presets) { $presetDropdown.Items.Add($p) | Out-Null }
$presetDropdown.SelectedIndex = 1
$tabPlayer.Controls.Add($presetDropdown)

# Quick preset buttons
$quickPresets = @("CTRL+0:Off", "CTRL+1:Lucid", "CTRL+2:Cinema", "CTRL+3:Anime", "CTRL+4:HDR")
$xPos = 290
foreach ($qp in $quickPresets) {
    $parts = $qp -split ":"
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $parts[1]
    $btn.Location = New-Object System.Drawing.Point($xPos, 12)
    $btn.Size = New-Object System.Drawing.Size(70, 28)
    $btn.FlatStyle = "Flat"
    $btn.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 240)
    $btn.Tag = $parts[0]
    $btn.Add_Click({ $presetDropdown.SelectedItem = $this.Text })
    $tabPlayer.Controls.Add($btn)
    $xPos += 78
}

# Video list
$listLabel = New-Object System.Windows.Forms.Label
$listLabel.Text = "Videos (double-click to play):"
$listLabel.Location = New-Object System.Drawing.Point(15, 50)
$listLabel.Size = New-Object System.Drawing.Size(400, 20)
$tabPlayer.Controls.Add($listLabel)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(15, 72)
$listBox.Size = New-Object System.Drawing.Size(550, 280)
$listBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$tabPlayer.Controls.Add($listBox)

# File info panel (right side)
$infoPanel = New-Object System.Windows.Forms.GroupBox
$infoPanel.Text = "File Info"
$infoPanel.Location = New-Object System.Drawing.Point(580, 72)
$infoPanel.Size = New-Object System.Drawing.Size(225, 280)
$tabPlayer.Controls.Add($infoPanel)

$infoName = New-Object System.Windows.Forms.Label
$infoName.Text = "No file selected"
$infoName.Location = New-Object System.Drawing.Point(10, 25)
$infoName.Size = New-Object System.Drawing.Size(205, 40)
$infoName.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$infoPanel.Controls.Add($infoName)

$infoSize = New-Object System.Windows.Forms.Label
$infoSize.Text = "Size: --"
$infoSize.Location = New-Object System.Drawing.Point(10, 70)
$infoSize.Size = New-Object System.Drawing.Size(205, 20)
$infoPanel.Controls.Add($infoSize)

$infoRes = New-Object System.Windows.Forms.Label
$infoRes.Text = "Resolution: --"
$infoRes.Location = New-Object System.Drawing.Point(10, 95)
$infoRes.Size = New-Object System.Drawing.Size(205, 20)
$infoPanel.Controls.Add($infoRes)

$infoDur = New-Object System.Windows.Forms.Label
$infoDur.Text = "Duration: --"
$infoDur.Location = New-Object System.Drawing.Point(10, 120)
$infoDur.Size = New-Object System.Drawing.Size(205, 20)
$infoPanel.Controls.Add($infoDur)

$infoCodec = New-Object System.Windows.Forms.Label
$infoCodec.Text = "Codec: --"
$infoCodec.Location = New-Object System.Drawing.Point(10, 145)
$infoCodec.Size = New-Object System.Drawing.Size(205, 20)
$infoPanel.Controls.Add($infoCodec)

$infoPreset = New-Object System.Windows.Forms.Label
$infoPreset.Text = "Preset: Lucid"
$infoPreset.Location = New-Object System.Drawing.Point(10, 175)
$infoPreset.Size = New-Object System.Drawing.Size(205, 20)
$infoPreset.ForeColor = [System.Drawing.Color]::DarkBlue
$infoPanel.Controls.Add($infoPreset)

# Action buttons
$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "Browse Folder"
$browseBtn.Location = New-Object System.Drawing.Point(15, 365)
$browseBtn.Size = New-Object System.Drawing.Size(130, 35)
$tabPlayer.Controls.Add($browseBtn)

$playBtn = New-Object System.Windows.Forms.Button
$playBtn.Text = "PLAY"
$playBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$playBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$playBtn.ForeColor = [System.Drawing.Color]::White
$playBtn.Location = New-Object System.Drawing.Point(155, 365)
$playBtn.Size = New-Object System.Drawing.Size(120, 35)
$tabPlayer.Controls.Add($playBtn)

$screenshotBtn = New-Object System.Windows.Forms.Button
$screenshotBtn.Text = "Screenshot"
$screenshotBtn.Location = New-Object System.Drawing.Point(285, 365)
$screenshotBtn.Size = New-Object System.Drawing.Size(100, 35)
$tabPlayer.Controls.Add($screenshotBtn)

$compareBtn = New-Object System.Windows.Forms.Button
$compareBtn.Text = "Compare Mode"
$compareBtn.Location = New-Object System.Drawing.Point(395, 365)
$compareBtn.Size = New-Object System.Drawing.Size(120, 35)
$tabPlayer.Controls.Add($compareBtn)

$perfBtn = New-Object System.Windows.Forms.Button
$perfBtn.Text = "Perf Monitor"
$perfBtn.Location = New-Object System.Drawing.Point(525, 365)
$perfBtn.Size = New-Object System.Drawing.Size(120, 35)
$tabPlayer.Controls.Add($perfBtn)

# Status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready - Select a video and click PLAY"
$statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
$statusLabel.Location = New-Object System.Drawing.Point(15, 410)
$statusLabel.Size = New-Object System.Drawing.Size(600, 25)
$tabPlayer.Controls.Add($statusLabel)

# ============================================
# TAB 2: PLAYLIST
# ============================================
$tabPlaylist = New-Object System.Windows.Forms.TabPage
$tabPlaylist.Text = "  Playlist  "
$tabPlaylist.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($tabPlaylist)

$playlistTitle = New-Object System.Windows.Forms.Label
$playlistTitle.Text = "Playlist & Queue"
$playlistTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$playlistTitle.Location = New-Object System.Drawing.Point(15, 10)
$playlistTitle.Size = New-Object System.Drawing.Size(400, 30)
$tabPlaylist.Controls.Add($playlistTitle)

$playlistSubtitle = New-Object System.Windows.Forms.Label
$playlistSubtitle.Text = "Add videos to queue, then play them in order"
$playlistSubtitle.ForeColor = [System.Drawing.Color]::Gray
$playlistSubtitle.Location = New-Object System.Drawing.Point(15, 40)
$playlistSubtitle.Size = New-Object System.Drawing.Size(500, 20)
$tabPlaylist.Controls.Add($playlistSubtitle)

# Playlist list box
$playlistLabel = New-Object System.Windows.Forms.Label
$playlistLabel.Text = "Queue (double-click to play):"
$playlistLabel.Location = New-Object System.Drawing.Point(15, 65)
$playlistLabel.Size = New-Object System.Drawing.Size(400, 20)
$tabPlaylist.Controls.Add($playlistLabel)

$playlistBox = New-Object System.Windows.Forms.ListBox
$playlistBox.Location = New-Object System.Drawing.Point(15, 88)
$playlistBox.Size = New-Object System.Drawing.Size(550, 280)
$playlistBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$tabPlaylist.Controls.Add($playlistBox)

# Playlist info panel (right side)
$playlistInfoGroup = New-Object System.Windows.Forms.GroupBox
$playlistInfoGroup.Text = "Playlist Info"
$playlistInfoGroup.Location = New-Object System.Drawing.Point(580, 88)
$playlistInfoGroup.Size = New-Object System.Drawing.Size(225, 150)
$tabPlaylist.Controls.Add($playlistInfoGroup)

$playlistCount = New-Object System.Windows.Forms.Label
$playlistCount.Text = "Videos: 0"
$playlistCount.Location = New-Object System.Drawing.Point(10, 25)
$playlistCount.Size = New-Object System.Drawing.Size(205, 20)
$playlistCount.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$playlistInfoGroup.Controls.Add($playlistCount)

$playlistDuration = New-Object System.Windows.Forms.Label
$playlistDuration.Text = "Total: 0:00"
$playlistDuration.Location = New-Object System.Drawing.Point(10, 50)
$playlistDuration.Size = New-Object System.Drawing.Size(205, 20)
$playlistInfoGroup.Controls.Add($playlistDuration)

$playlistSize = New-Object System.Windows.Forms.Label
$playlistSize.Text = "Size: 0 MB"
$playlistSize.Location = New-Object System.Drawing.Point(10, 75)
$playlistSize.Size = New-Object System.Drawing.Size(205, 20)
$playlistInfoGroup.Controls.Add($playlistSize)

$playlistCurrent = New-Object System.Windows.Forms.Label
$playlistCurrent.Text = "Now Playing: None"
$playlistCurrent.Location = New-Object System.Drawing.Point(10, 105)
$playlistCurrent.Size = New-Object System.Drawing.Size(205, 20)
$playlistCurrent.ForeColor = [System.Drawing.Color]::DarkBlue
$playlistInfoGroup.Controls.Add($playlistCurrent)

# Playlist controls
$addToPlaylistBtn = New-Object System.Windows.Forms.Button
$addToPlaylistBtn.Text = "Add to Queue"
$addToPlaylistBtn.Location = New-Object System.Drawing.Point(15, 380)
$addToPlaylistBtn.Size = New-Object System.Drawing.Size(120, 35)
$tabPlaylist.Controls.Add($addToPlaylistBtn)

$removeFromPlaylistBtn = New-Object System.Windows.Forms.Button
$removeFromPlaylistBtn.Text = "Remove"
$removeFromPlaylistBtn.Location = New-Object System.Drawing.Point(145, 380)
$removeFromPlaylistBtn.Size = New-Object System.Drawing.Size(90, 35)
$tabPlaylist.Controls.Add($removeFromPlaylistBtn)

$clearPlaylistBtn = New-Object System.Windows.Forms.Button
$clearPlaylistBtn.Text = "Clear All"
$clearPlaylistBtn.Location = New-Object System.Drawing.Point(245, 380)
$clearPlaylistBtn.Size = New-Object System.Drawing.Size(90, 35)
$tabPlaylist.Controls.Add($clearPlaylistBtn)

$moveUpBtn = New-Object System.Windows.Forms.Button
$moveUpBtn.Text = "Move Up"
$moveUpBtn.Location = New-Object System.Drawing.Point(345, 380)
$moveUpBtn.Size = New-Object System.Drawing.Size(90, 35)
$tabPlaylist.Controls.Add($moveUpBtn)

$moveDownBtn = New-Object System.Windows.Forms.Button
$moveDownBtn.Text = "Move Down"
$moveDownBtn.Location = New-Object System.Drawing.Point(445, 380)
$moveDownBtn.Size = New-Object System.Drawing.Size(100, 35)
$tabPlaylist.Controls.Add($moveDownBtn)

# Play queue controls
$playQueueBtn = New-Object System.Windows.Forms.Button
$playQueueBtn.Text = "PLAY QUEUE"
$playQueueBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$playQueueBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 80)
$playQueueBtn.ForeColor = [System.Drawing.Color]::White
$playQueueBtn.Location = New-Object System.Drawing.Point(580, 250)
$playQueueBtn.Size = New-Object System.Drawing.Size(225, 40)
$tabPlaylist.Controls.Add($playQueueBtn)

$shuffleBtn = New-Object System.Windows.Forms.Button
$shuffleBtn.Text = "Shuffle"
$shuffleBtn.Location = New-Object System.Drawing.Point(580, 300)
$shuffleBtn.Size = New-Object System.Drawing.Size(105, 30)
$tabPlaylist.Controls.Add($shuffleBtn)

$repeatBtn = New-Object System.Windows.Forms.Button
$repeatBtn.Text = "Repeat: OFF"
$repeatBtn.Location = New-Object System.Drawing.Point(695, 300)
$repeatBtn.Size = New-Object System.Drawing.Size(110, 30)
$tabPlaylist.Controls.Add($repeatBtn)

# Status
$playlistStatus = New-Object System.Windows.Forms.Label
$playlistStatus.Text = "Ready"
$playlistStatus.ForeColor = [System.Drawing.Color]::DarkGreen
$playlistStatus.Location = New-Object System.Drawing.Point(15, 425)
$playlistStatus.Size = New-Object System.Drawing.Size(600, 25)
$tabPlaylist.Controls.Add($playlistStatus)

# ============================================
# TAB 3: AUDIO
# ============================================
$tabAudio = New-Object System.Windows.Forms.TabPage
$tabAudio.Text = "  Audio  "
$tabAudio.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($tabAudio)

$audioTitle = New-Object System.Windows.Forms.Label
$audioTitle.Text = "Audio Enhancement Controls"
$audioTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$audioTitle.Location = New-Object System.Drawing.Point(15, 10)
$audioTitle.Size = New-Object System.Drawing.Size(400, 30)
$tabAudio.Controls.Add($audioTitle)

$audioSubtitle = New-Object System.Windows.Forms.Label
$audioSubtitle.Text = "Adjust these sliders, then play a video to hear the changes"
$audioSubtitle.ForeColor = [System.Drawing.Color]::Gray
$audioSubtitle.Location = New-Object System.Drawing.Point(15, 40)
$audioSubtitle.Size = New-Object System.Drawing.Size(500, 20)
$tabAudio.Controls.Add($audioSubtitle)

# Audio controls - sliders with labels
$audioControls = @(
    @{ Name = "Noise Reduction"; Key = "noise"; Default = 50; Min = 0; Max = 100; Desc = "Removes hiss and background noise" },
    @{ Name = "Dialogue Boost"; Key = "dialogue"; Default = 20; Min = 0; Max = 100; Desc = "Enhances speech clarity" },
    @{ Name = "Bass Restore"; Key = "bass"; Default = 30; Min = 0; Max = 100; Desc = "Adds warmth to thin audio" },
    @{ Name = "Stereo Widen"; Key = "stereo"; Default = 0; Min = 0; Max = 100; Desc = "Spatial expansion effect" },
    @{ Name = "Volume Normalize"; Key = "normalize"; Default = 1; Min = 0; Max = 1; Desc = "On/Off - Evens out volume levels" },
    @{ Name = "Night Mode"; Key = "night"; Default = 0; Min = 0; Max = 1; Desc = "On/Off - Compresses dynamic range" },
    @{ Name = "Dialogue Clarity"; Key = "clarity"; Default = 30; Min = 0; Max = 100; Desc = "Voice frequency emphasis" }
)

$script:audioSliders = @{}
$script:audioToggles = @{}
$yPos = 70

foreach ($ac in $audioControls) {
    # Label
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "$($ac.Name):"
    $lbl.Location = New-Object System.Drawing.Point(15, ($yPos + 3))
    $lbl.Size = New-Object System.Drawing.Size(150, 22)
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $tabAudio.Controls.Add($lbl)

    if ($ac.Max -eq 1) {
        # Toggle checkbox for on/off controls
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Checked = ($ac.Default -eq 1)
        $chk.Location = New-Object System.Drawing.Point(175, ($yPos + 2))
        $chk.Size = New-Object System.Drawing.Size(80, 22)
        $chk.Text = if ($chk.Checked) { "ON" } else { "OFF" }
        $chk.Add_CheckedChanged({
            $this.Text = if ($this.Checked) { "ON" } else { "OFF" }
        })
        $tabAudio.Controls.Add($chk)
        $script:audioToggles[$ac.Key] = $chk
        $yPos += 35
    } else {
        # Slider
        $slider = New-Object System.Windows.Forms.TrackBar
        $slider.Minimum = $ac.Min
        $slider.Maximum = $ac.Max
        $slider.Value = $ac.Default
        $slider.TickFrequency = 10
        $slider.Location = New-Object System.Drawing.Point(175, ($yPos - 5))
        $slider.Size = New-Object System.Drawing.Size(350, 45)
        $tabAudio.Controls.Add($slider)

        # Value label
        $valLbl = New-Object System.Windows.Forms.Label
        $valLbl.Text = "$($ac.Default)%"
        $valLbl.Location = New-Object System.Drawing.Point(535, ($yPos + 3))
        $valLbl.Size = New-Object System.Drawing.Size(50, 22)
        $tabAudio.Controls.Add($valLbl)

        $slider.Add_ValueChanged({ $valLbl.Text = "$($this.Value)%" })

        # Description
        $descLbl = New-Object System.Windows.Forms.Label
        $descLbl.Text = $ac.Desc
        $descLbl.ForeColor = [System.Drawing.Color]::Gray
        $descLbl.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $descLbl.Location = New-Object System.Drawing.Point(175, ($yPos + 28))
        $descLbl.Size = New-Object System.Drawing.Size(400, 18)
        $tabAudio.Controls.Add($descLbl)

        $script:audioSliders[$ac.Key] = $slider
        $yPos += 55
    }
}

# Audio profile buttons
$audioProfilesLabel = New-Object System.Windows.Forms.Label
$audioProfilesLabel.Text = "Quick Profiles:"
$audioProfilesLabel.Location = New-Object System.Drawing.Point(15, 410)
$audioProfilesLabel.Size = New-Object System.Drawing.Size(120, 25)
$audioProfilesLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabAudio.Controls.Add($audioProfilesLabel)

$audioProfiles = @("Movie", "Music", "Dialogue", "Night", "Custom")
$xPos = 145
foreach ($ap in $audioProfiles) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $ap
    $btn.Location = New-Object System.Drawing.Point($xPos, 408)
    $btn.Size = New-Object System.Drawing.Size(80, 28)
    $btn.FlatStyle = "Flat"
    $tabAudio.Controls.Add($btn)
    $xPos += 88
}

# ============================================
# TAB 3: SECURITY
# ============================================
$tabSecurity = New-Object System.Windows.Forms.TabPage
$tabSecurity.Text = "  Security  "
$tabSecurity.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($tabSecurity)

$secTitle = New-Object System.Windows.Forms.Label
$secTitle.Text = "Encryption & Secure Deletion"
$secTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$secTitle.Location = New-Object System.Drawing.Point(15, 10)
$secTitle.Size = New-Object System.Drawing.Size(400, 30)
$tabSecurity.Controls.Add($secTitle)

$secSubtitle = New-Object System.Windows.Forms.Label
$secSubtitle.Text = "AES-256-GCM encryption with PBKDF2 key derivation"
$secSubtitle.ForeColor = [System.Drawing.Color]::Gray
$secSubtitle.Location = New-Object System.Drawing.Point(15, 40)
$secSubtitle.Size = New-Object System.Drawing.Size(500, 20)
$tabSecurity.Controls.Add($secSubtitle)

# Encryption section
$encGroup = New-Object System.Windows.Forms.GroupBox
$encGroup.Text = "Encrypt Video"
$encGroup.Location = New-Object System.Drawing.Point(15, 70)
$encGroup.Size = New-Object System.Drawing.Size(390, 200)
$tabSecurity.Controls.Add($encGroup)

$encFileLabel = New-Object System.Windows.Forms.Label
$encFileLabel.Text = "File:"
$encFileLabel.Location = New-Object System.Drawing.Point(10, 30)
$encFileLabel.Size = New-Object System.Drawing.Size(50, 22)
$encGroup.Controls.Add($encFileLabel)

$encFileBox = New-Object System.Windows.Forms.TextBox
$encFileBox.Location = New-Object System.Drawing.Point(65, 27)
$encFileBox.Size = New-Object System.Drawing.Size(220, 25)
$encFileBox.ReadOnly = $true
$encGroup.Controls.Add($encFileBox)

$encBrowseBtn = New-Object System.Windows.Forms.Button
$encBrowseBtn.Text = "..."
$encBrowseBtn.Location = New-Object System.Drawing.Point(290, 26)
$encBrowseBtn.Size = New-Object System.Drawing.Size(30, 25)
$encGroup.Controls.Add($encBrowseBtn)

$encPassLabel = New-Object System.Windows.Forms.Label
$encPassLabel.Text = "Password:"
$encPassLabel.Location = New-Object System.Drawing.Point(10, 65)
$encPassLabel.Size = New-Object System.Drawing.Size(75, 22)
$encGroup.Controls.Add($encPassLabel)

$encPassBox = New-Object System.Windows.Forms.TextBox
$encPassBox.Location = New-Object System.Drawing.Point(90, 62)
$encPassBox.Size = New-Object System.Drawing.Size(230, 25)
$encPassBox.UseSystemPasswordChar = $true
$encGroup.Controls.Add($encPassBox)

# Password strength meter
$passStrength = New-Object System.Windows.Forms.Label
$passStrength.Text = "Enter a password"
$passStrength.ForeColor = [System.Drawing.Color]::Gray
$passStrength.Location = New-Object System.Drawing.Point(90, 92)
$passStrength.Size = New-Object System.Drawing.Size(230, 20)
$encGroup.Controls.Add($passStrength)

$encPassBox.Add_TextChanged({
    $len = $encPassBox.Text.Length
    if ($len -eq 0) { $passStrength.Text = "Enter a password"; $passStrength.ForeColor = [System.Drawing.Color]::Gray }
    elseif ($len -lt 6) { $passStrength.Text = "WEAK - Use 8+ characters"; $passStrength.ForeColor = [System.Drawing.Color]::Red }
    elseif ($len -lt 10) { $passStrength.Text = "FAIR - Add symbols for strength"; $passStrength.ForeColor = [System.Drawing.Color]::Orange }
    else { $passStrength.Text = "STRONG password"; $passStrength.ForeColor = [System.Drawing.Color]::DarkGreen }
})

$encPassConfirmLabel = New-Object System.Windows.Forms.Label
$encPassConfirmLabel.Text = "Confirm:"
$encPassConfirmLabel.Location = New-Object System.Drawing.Point(10, 100)
$encPassConfirmLabel.Size = New-Object System.Drawing.Size(75, 22)
$encGroup.Controls.Add($encPassConfirmLabel)

$encPassConfirm = New-Object System.Windows.Forms.TextBox
$encPassConfirm.Location = New-Object System.Drawing.Point(90, 97)
$encPassConfirm.Size = New-Object System.Drawing.Size(230, 25)
$encPassConfirm.UseSystemPasswordChar = $true
$encGroup.Controls.Add($encPassConfirm)

$encDeleteOrig = New-Object System.Windows.Forms.CheckBox
$encDeleteOrig.Text = "Secure delete original after encryption"
$encDeleteOrig.Location = New-Object System.Drawing.Point(10, 135)
$encDeleteOrig.Size = New-Object System.Drawing.Size(280, 22)
$encGroup.Controls.Add($encDeleteOrig)

$encDeletePasses = New-Object System.Windows.Forms.ComboBox
$encDeletePasses.Location = New-Object System.Drawing.Point(300, 133)
$encDeletePasses.Size = New-Object System.Drawing.Size(75, 25)
$encDeletePasses.DropDownStyle = "DropDownList"
foreach ($n in @("1 pass", "3 pass", "7 pass", "35 pass")) { $encDeletePasses.Items.Add($n) | Out-Null }
$encDeletePasses.SelectedIndex = 3
$encGroup.Controls.Add($encDeletePasses)

$encryptBtn = New-Object System.Windows.Forms.Button
$encryptBtn.Text = "ENCRYPT"
$encryptBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$encryptBtn.BackColor = [System.Drawing.Color]::FromArgb(200, 50, 50)
$encryptBtn.ForeColor = [System.Drawing.Color]::White
$encryptBtn.Location = New-Object System.Drawing.Point(10, 162)
$encryptBtn.Size = New-Object System.Drawing.Size(170, 32)
$encGroup.Controls.Add($encryptBtn)

$encStatus = New-Object System.Windows.Forms.Label
$encStatus.Text = ""
$encStatus.Location = New-Object System.Drawing.Point(190, 168)
$encStatus.Size = New-Object System.Drawing.Size(190, 22)
$encGroup.Controls.Add($encStatus)

# Decryption section
$decGroup = New-Object System.Windows.Forms.GroupBox
$decGroup.Text = "Decrypt & Play"
$decGroup.Location = New-Object System.Drawing.Point(420, 70)
$decGroup.Size = New-Object System.Drawing.Size(390, 200)
$tabSecurity.Controls.Add($decGroup)

$decFileLabel = New-Object System.Windows.Forms.Label
$decFileLabel.Text = "Encrypted file:"
$decFileLabel.Location = New-Object System.Drawing.Point(10, 30)
$decFileLabel.Size = New-Object System.Drawing.Size(100, 22)
$decGroup.Controls.Add($decFileLabel)

$decFileBox = New-Object System.Windows.Forms.TextBox
$decFileBox.Location = New-Object System.Drawing.Point(115, 27)
$decFileBox.Size = New-Object System.Drawing.Size(185, 25)
$decFileBox.ReadOnly = $true
$decGroup.Controls.Add($decFileBox)

$decBrowseBtn = New-Object System.Windows.Forms.Button
$decBrowseBtn.Text = "..."
$decBrowseBtn.Location = New-Object System.Drawing.Point(305, 26)
$decBrowseBtn.Size = New-Object System.Drawing.Size(30, 25)
$decGroup.Controls.Add($decBrowseBtn)

$decPassLabel = New-Object System.Windows.Forms.Label
$decPassLabel.Text = "Password:"
$decPassLabel.Location = New-Object System.Drawing.Point(10, 70)
$decPassLabel.Size = New-Object System.Drawing.Size(100, 22)
$decGroup.Controls.Add($decPassLabel)

$decPassBox = New-Object System.Windows.Forms.TextBox
$decPassBox.Location = New-Object System.Drawing.Point(115, 67)
$decPassBox.Size = New-Object System.Drawing.Size(220, 25)
$decPassBox.UseSystemPasswordChar = $true
$decGroup.Controls.Add($decPassBox)

$decPlayBtn = New-Object System.Windows.Forms.Button
$decPlayBtn.Text = "DECRYPT & PLAY"
$decPlayBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$decPlayBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 80)
$decPlayBtn.ForeColor = [System.Drawing.Color]::White
$decPlayBtn.Location = New-Object System.Drawing.Point(10, 110)
$decPlayBtn.Size = New-Object System.Drawing.Size(180, 32)
$decGroup.Controls.Add($decPlayBtn)

$decStatus = New-Object System.Windows.Forms.Label
$decStatus.Text = ""
$decStatus.Location = New-Object System.Drawing.Point(10, 150)
$decStatus.Size = New-Object System.Drawing.Size(370, 22)
$decGroup.Controls.Add($decStatus)

# Secure delete section
$delGroup = New-Object System.Windows.Forms.GroupBox
$delGroup.Text = "Secure Delete (35-Pass Gutmann)"
$delGroup.Location = New-Object System.Drawing.Point(15, 280)
$delGroup.Size = New-Object System.Drawing.Size(795, 80)
$tabSecurity.Controls.Add($delGroup)

$delFileLabel = New-Object System.Windows.Forms.Label
$delFileLabel.Text = "File to securely delete:"
$delFileLabel.Location = New-Object System.Drawing.Point(10, 30)
$delFileLabel.Size = New-Object System.Drawing.Size(140, 22)
$delGroup.Controls.Add($delFileLabel)

$delFileBox = New-Object System.Windows.Forms.TextBox
$delFileBox.Location = New-Object System.Drawing.Point(155, 27)
$delFileBox.Size = New-Object System.Drawing.Size(350, 25)
$delFileBox.ReadOnly = $true
$delGroup.Controls.Add($delFileBox)

$delBrowseBtn = New-Object System.Windows.Forms.Button
$delBrowseBtn.Text = "..."
$delBrowseBtn.Location = New-Object System.Drawing.Point(510, 26)
$delBrowseBtn.Size = New-Object System.Drawing.Size(30, 25)
$delGroup.Controls.Add($delBrowseBtn)

$delBtn = New-Object System.Windows.Forms.Button
$delBtn.Text = "SECURE DELETE"
$delBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$delBtn.BackColor = [System.Drawing.Color]::FromArgb(180, 30, 30)
$delBtn.ForeColor = [System.Drawing.Color]::White
$delBtn.Location = New-Object System.Drawing.Point(555, 25)
$delBtn.Size = New-Object System.Drawing.Size(150, 30)
$delGroup.Controls.Add($delBtn)

# ============================================
# TAB 4: PRESETS
# ============================================
$tabPresets = New-Object System.Windows.Forms.TabPage
$tabPresets.Text = "  Presets  "
$tabPresets.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($tabPresets)

$presetsTitle = New-Object System.Windows.Forms.Label
$presetsTitle.Text = "Customize Enhancement Presets"
$presetsTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$presetsTitle.Location = New-Object System.Drawing.Point(15, 10)
$presetsTitle.Size = New-Object System.Drawing.Size(400, 30)
$tabPresets.Controls.Add($presetsTitle)

$presetsSubtitle = New-Object System.Windows.Forms.Label
$presetsSubtitle.Text = "Adjust parameters below, then save to apply changes"
$presetsSubtitle.ForeColor = [System.Drawing.Color]::Gray
$presetsSubtitle.Location = New-Object System.Drawing.Point(15, 40)
$presetsSubtitle.Size = New-Object System.Drawing.Size(500, 20)
$tabPresets.Controls.Add($presetsSubtitle)

# Preset selector
$presetSelLabel = New-Object System.Windows.Forms.Label
$presetSelLabel.Text = "Preset to customize:"
$presetSelLabel.Location = New-Object System.Drawing.Point(15, 70)
$presetSelLabel.Size = New-Object System.Drawing.Size(130, 25)
$tabPresets.Controls.Add($presetSelLabel)

$editablePresets = @("Lucid", "Cinema", "Anime", "HDR", "Denoise", "Motion", "Restore")
$presetSelDropdown = New-Object System.Windows.Forms.ComboBox
$presetSelDropdown.Location = New-Object System.Drawing.Point(150, 67)
$presetSelDropdown.Size = New-Object System.Drawing.Size(150, 28)
$presetSelDropdown.DropDownStyle = "DropDownList"
$presetSelDropdown.Font = New-Object System.Drawing.Font("Segoe UI", 11)
foreach ($p in $editablePresets) { $presetSelDropdown.Items.Add($p) | Out-Null }
$presetSelDropdown.SelectedIndex = 0
$tabPresets.Controls.Add($presetSelDropdown)

# Parameters panel
$paramPanel = New-Object System.Windows.Forms.Panel
$paramPanel.Location = New-Object System.Drawing.Point(15, 100)
$paramPanel.Size = New-Object System.Drawing.Size(800, 310)
$paramPanel.BorderStyle = "FixedSingle"
$tabPresets.Controls.Add($paramPanel)

# Sharpening
$sharpenLabel = New-Object System.Windows.Forms.Label
$sharpenLabel.Text = "Sharpening Strength:"
$sharpenLabel.Location = New-Object System.Drawing.Point(10, 15)
$sharpenLabel.Size = New-Object System.Drawing.Size(160, 22)
$sharpenLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$paramPanel.Controls.Add($sharpenLabel)

$sharpenSlider = New-Object System.Windows.Forms.TrackBar
$sharpenSlider.Minimum = 0
$sharpenSlider.Maximum = 200
$sharpenSlider.Value = 100
$sharpenSlider.TickFrequency = 20
$sharpenSlider.Location = New-Object System.Drawing.Point(180, 5)
$sharpenSlider.Size = New-Object System.Drawing.Size(400, 45)
$paramPanel.Controls.Add($sharpenSlider)

$sharpenVal = New-Object System.Windows.Forms.Label
$sharpenVal.Text = "100%"
$sharpenVal.Location = New-Object System.Drawing.Point(590, 15)
$sharpenVal.Size = New-Object System.Drawing.Size(60, 22)
$paramPanel.Controls.Add($sharpenVal)
$sharpenSlider.Add_ValueChanged({ $sharpenVal.Text = "$($sharpenSlider.Value)%" })

$sharpenDesc = New-Object System.Windows.Forms.Label
$sharpenDesc.Text = "Higher = sharper image. Lucid: 100, Cinema: 80, Anime: 60"
$sharpenDesc.ForeColor = [System.Drawing.Color]::Gray
$sharpenDesc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$sharpenDesc.Location = New-Object System.Drawing.Point(180, 42)
$sharpenDesc.Size = New-Object System.Drawing.Size(400, 18)
$paramPanel.Controls.Add($sharpenDesc)

# Denoise strength
$denoiseLabel = New-Object System.Windows.Forms.Label
$denoiseLabel.Text = "Denoise Strength:"
$denoiseLabel.Location = New-Object System.Drawing.Point(10, 70)
$denoiseLabel.Size = New-Object System.Drawing.Size(160, 22)
$denoiseLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$paramPanel.Controls.Add($denoiseLabel)

$denoiseSlider = New-Object System.Windows.Forms.TrackBar
$denoiseSlider.Minimum = 0
$denoiseSlider.Maximum = 200
$denoiseSlider.Value = 50
$denoiseSlider.TickFrequency = 20
$denoiseSlider.Location = New-Object System.Drawing.Point(180, 60)
$denoiseSlider.Size = New-Object System.Drawing.Size(400, 45)
$paramPanel.Controls.Add($denoiseSlider)

$denoiseVal = New-Object System.Windows.Forms.Label
$denoiseVal.Text = "50%"
$denoiseVal.Location = New-Object System.Drawing.Point(590, 70)
$denoiseVal.Size = New-Object System.Drawing.Size(60, 22)
$paramPanel.Controls.Add($denoiseVal)
$denoiseSlider.Add_ValueChanged({ $denoiseVal.Text = "$($denoiseSlider.Value)%" })

$denoiseDesc = New-Object System.Windows.Forms.Label
$denoiseDesc.Text = "Higher = smoother (less noise). Denoise: 80, Cinema: 40, Lucid: 20"
$denoiseDesc.ForeColor = [System.Drawing.Color]::Gray
$denoiseDesc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$denoiseDesc.Location = New-Object System.Drawing.Point(180, 97)
$denoiseDesc.Size = New-Object System.Drawing.Size(400, 18)
$paramPanel.Controls.Add($denoiseDesc)

# Upscale factor
$upscaleLabel = New-Object System.Windows.Forms.Label
$upscaleLabel.Text = "Upscale Quality:"
$upscaleLabel.Location = New-Object System.Drawing.Point(10, 125)
$upscaleLabel.Size = New-Object System.Drawing.Size(160, 22)
$upscaleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$paramPanel.Controls.Add($upscaleLabel)

$upscaleSlider = New-Object System.Windows.Forms.TrackBar
$upscaleSlider.Minimum = 0
$upscaleSlider.Maximum = 100
$upscaleSlider.Value = 50
$upscaleSlider.TickFrequency = 10
$upscaleSlider.Location = New-Object System.Drawing.Point(180, 115)
$upscaleSlider.Size = New-Object System.Drawing.Size(400, 45)
$paramPanel.Controls.Add($upscaleSlider)

$upscaleVal = New-Object System.Windows.Forms.Label
$upscaleVal.Text = "50%"
$upscaleVal.Location = New-Object System.Drawing.Point(590, 125)
$upscaleVal.Size = New-Object System.Drawing.Size(60, 22)
$paramPanel.Controls.Add($upscaleVal)
$upscaleSlider.Add_ValueChanged({ $upscaleVal.Text = "$($upscaleSlider.Value)%" })

$upscaleDesc = New-Object System.Windows.Forms.Label
$upscaleDesc.Text = "FSRCNNX/Ravu upscale quality. Cinema: 80, Restore: 90, Anime: 70"
$upscaleDesc.ForeColor = [System.Drawing.Color]::Gray
$upscaleDesc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$upscaleDesc.Location = New-Object System.Drawing.Point(180, 152)
$upscaleDesc.Size = New-Object System.Drawing.Size(400, 18)
$paramPanel.Controls.Add($upscaleDesc)

# Motion smoothness
$motionLabel = New-Object System.Windows.Forms.Label
$motionLabel.Text = "Motion Smoothness:"
$motionLabel.Location = New-Object System.Drawing.Point(10, 180)
$motionLabel.Size = New-Object System.Drawing.Size(160, 22)
$motionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$paramPanel.Controls.Add($motionLabel)

$motionSlider = New-Object System.Windows.Forms.TrackBar
$motionSlider.Minimum = 0
$motionSlider.Maximum = 100
$motionSlider.Value = 0
$motionSlider.TickFrequency = 10
$motionSlider.Location = New-Object System.Drawing.Point(180, 170)
$motionSlider.Size = New-Object System.Drawing.Size(400, 45)
$paramPanel.Controls.Add($motionSlider)

$motionVal = New-Object System.Windows.Forms.Label
$motionVal.Text = "0%"
$motionVal.Location = New-Object System.Drawing.Point(590, 180)
$motionVal.Size = New-Object System.Drawing.Size(60, 22)
$paramPanel.Controls.Add($motionVal)
$motionSlider.Add_ValueChanged({ $motionVal.Text = "$($motionSlider.Value)%" })

$motionDesc = New-Object System.Windows.Forms.Label
$motionDesc.Text = "Frame interpolation. Motion: 80, Cinema: 40, others: 0"
$motionDesc.ForeColor = [System.Drawing.Color]::Gray
$motionDesc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$motionDesc.Location = New-Object System.Drawing.Point(180, 207)
$motionDesc.Size = New-Object System.Drawing.Size(400, 18)
$paramPanel.Controls.Add($motionDesc)

# HDR peak brightness
$hdrLabel = New-Object System.Windows.Forms.Label
$hdrLabel.Text = "HDR Peak (nits):"
$hdrLabel.Location = New-Object System.Drawing.Point(10, 235)
$hdrLabel.Size = New-Object System.Drawing.Size(160, 22)
$hdrLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$paramPanel.Controls.Add($hdrLabel)

$hdrSlider = New-Object System.Windows.Forms.TrackBar
$hdrSlider.Minimum = 100
$hdrSlider.Maximum = 4000
$hdrSlider.Value = 1000
$hdrSlider.TickFrequency = 200
$hdrSlider.Location = New-Object System.Drawing.Point(180, 225)
$hdrSlider.Size = New-Object System.Drawing.Size(400, 45)
$paramPanel.Controls.Add($hdrSlider)

$hdrVal = New-Object System.Windows.Forms.Label
$hdrVal.Text = "1000 nits"
$hdrVal.Location = New-Object System.Drawing.Point(590, 235)
$hdrVal.Size = New-Object System.Drawing.Size(80, 22)
$paramPanel.Controls.Add($hdrVal)
$hdrSlider.Add_ValueChanged({ $hdrVal.Text = "$($hdrSlider.Value) nits" })

$hdrDesc = New-Object System.Windows.Forms.Label
$hdrDesc.Text = "Target peak brightness for HDR tone mapping. Default: 1000"
$hdrDesc.ForeColor = [System.Drawing.Color]::Gray
$hdrDesc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$hdrDesc.Location = New-Object System.Drawing.Point(180, 262)
$hdrDesc.Size = New-Object System.Drawing.Size(400, 18)
$paramPanel.Controls.Add($hdrDesc)

# Save / Reset buttons
$savePresetsBtn = New-Object System.Windows.Forms.Button
$savePresetsBtn.Text = "SAVE PRESET"
$savePresetsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$savePresetsBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 80)
$savePresetsBtn.ForeColor = [System.Drawing.Color]::White
$savePresetsBtn.Location = New-Object System.Drawing.Point(15, 420)
$savePresetsBtn.Size = New-Object System.Drawing.Size(160, 35)
$tabPresets.Controls.Add($savePresetsBtn)

$resetPresetsBtn = New-Object System.Windows.Forms.Button
$resetPresetsBtn.Text = "RESET TO DEFAULT"
$resetPresetsBtn.Location = New-Object System.Drawing.Point(185, 420)
$resetPresetsBtn.Size = New-Object System.Drawing.Size(160, 35)
$tabPresets.Controls.Add($resetPresetsBtn)

$presetStatusLabel = New-Object System.Windows.Forms.Label
$presetStatusLabel.Text = ""
$presetStatusLabel.Location = New-Object System.Drawing.Point(355, 428)
$presetStatusLabel.Size = New-Object System.Drawing.Size(400, 22)
$tabPresets.Controls.Add($presetStatusLabel)

# Preset default values
$script:presetDefaults = @{
    "Lucid"  = @{Sharpen=100; Denoise=20; Upscale=0; Motion=0; HDR=1000}
    "Cinema" = @{Sharpen=80; Denoise=40; Upscale=80; Motion=40; HDR=1000}
    "Anime"  = @{Sharpen=60; Denoise=30; Upscale=70; Motion=0; HDR=1000}
    "HDR"    = @{Sharpen=50; Denoise=0; Upscale=0; Motion=0; HDR=1000}
    "Denoise"= @{Sharpen=70; Denoise=80; Upscale=0; Motion=0; HDR=1000}
    "Motion" = @{Sharpen=50; Denoise=0; Upscale=0; Motion=80; HDR=1000}
    "Restore"=@{Sharpen=90; Denoise=60; Upscale=90; Motion=0; HDR=1000}
}

# Load preset values
function Load-PresetValues {
    param([string]$PresetName)
    $defaults = $script:presetDefaults[$PresetName]
    if ($defaults) {
        $sharpenSlider.Value = $defaults.Sharpen
        $denoiseSlider.Value = $defaults.Denoise
        $upscaleSlider.Value = $defaults.Upscale
        $motionSlider.Value = $defaults.Motion
        $hdrSlider.Value = $defaults.HDR
    }
}

# Load preset on selection change
$presetSelDropdown.Add_SelectedIndexChanged({
    Load-PresetValues -PresetName $presetSelDropdown.SelectedItem
})

# Save preset to JSON
$savePresetsBtn.Add_Click({
    $presetName = $presetSelDropdown.SelectedItem.ToString().ToLower()
    $configDir = Join-Path $RootDir "nj-config"
    if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }
    
    $configFile = Join-Path $configDir "preset-custom.json"
    
    # Load existing or create new
    $configs = @{}
    if (Test-Path $configFile) {
        try { $configs = Get-Content $configFile -Raw | ConvertFrom-Json -AsHashtable } catch { $configs = @{} }
    }
    
    $configs[$presetName] = @{
        sharpen = $sharpenSlider.Value
        denoise = $denoiseSlider.Value
        upscale = $upscaleSlider.Value
        motion = $motionSlider.Value
        hdr = $hdrSlider.Value
    }
    
    $configs | ConvertTo-Json -Depth 3 | Set-Content $configFile -Encoding UTF8
    $presetStatusLabel.Text = "Saved: $presetName preset"
    $presetStatusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
})

# Reset to defaults
$resetPresetsBtn.Add_Click({
    Load-PresetValues -PresetName $presetSelDropdown.SelectedItem
    $presetStatusLabel.Text = "Reset to defaults"
    $presetStatusLabel.ForeColor = [System.Drawing.Color]::Orange
})

# Load custom presets on startup
$presetConfigFile = Join-Path $RootDir "nj-config\preset-custom.json"
if (Test-Path $presetConfigFile) {
    try {
        $customPresets = Get-Content $presetConfigFile -Raw | ConvertFrom-Json -AsHashtable
        foreach ($key in $customPresets.Keys) {
            if ($script:presetDefaults.ContainsKey($key)) {
                $script:presetDefaults[$key] = $customPresets[$key]
            }
        }
    } catch { }
}

Load-PresetValues -PresetName $editablePresets[0]

# ============================================
# TAB 5: SETTINGS
# ============================================
$tabSettings = New-Object System.Windows.Forms.TabPage
$tabSettings.Text = "  Settings  "
$tabSettings.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($tabSettings)

$settingsTitle = New-Object System.Windows.Forms.Label
$settingsTitle.Text = "Settings & Configuration"
$settingsTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$settingsTitle.Location = New-Object System.Drawing.Point(15, 10)
$settingsTitle.Size = New-Object System.Drawing.Size(400, 30)
$tabSettings.Controls.Add($settingsTitle)

# Playback settings
$playbackGroup = New-Object System.Windows.Forms.GroupBox
$playbackGroup.Text = "Playback"
$playbackGroup.Location = New-Object System.Drawing.Point(15, 50)
$playbackGroup.Size = New-Object System.Drawing.Size(390, 160)
$tabSettings.Controls.Add($playbackGroup)

$autoDetectChk = New-Object System.Windows.Forms.CheckBox
$autoDetectChk.Text = "Auto-detect content type and apply best preset"
$autoDetectChk.Checked = $true
$autoDetectChk.Location = New-Object System.Drawing.Point(10, 28)
$autoDetectChk.Size = New-Object System.Drawing.Size(350, 22)
$playbackGroup.Controls.Add($autoDetectChk)

$hwDecChk = New-Object System.Windows.Forms.CheckBox
$hwDecChk.Text = "Hardware decoding (if available)"
$hwDecChk.Checked = $true
$hwDecChk.Location = New-Object System.Drawing.Point(10, 58)
$hwDecChk.Size = New-Object System.Drawing.Size(350, 22)
$playbackGroup.Controls.Add($hwDecChk)

$savePosChk = New-Object System.Windows.Forms.CheckBox
$savePosChk.Text = "Remember playback position"
$savePosChk.Checked = $true
$savePosChk.Location = New-Object System.Drawing.Point(10, 88)
$savePosChk.Size = New-Object System.Drawing.Size(350, 22)
$playbackGroup.Controls.Add($savePosChk)

$osdLevelLabel = New-Object System.Windows.Forms.Label
$osdLevelLabel.Text = "OSD level:"
$osdLevelLabel.Location = New-Object System.Drawing.Point(10, 120)
$osdLevelLabel.Size = New-Object System.Drawing.Size(80, 22)
$playbackGroup.Controls.Add($osdLevelLabel)

$osdLevel = New-Object System.Windows.Forms.ComboBox
$osdLevel.Location = New-Object System.Drawing.Point(95, 117)
$osdLevel.Size = New-Object System.Drawing.Size(80, 25)
$osdLevel.DropDownStyle = "DropDownList"
foreach ($n in @("0", "1", "2", "3")) { $osdLevel.Items.Add($n) | Out-Null }
$osdLevel.SelectedIndex = 2
$playbackGroup.Controls.Add($osdLevel)

# Paths settings
$pathsGroup = New-Object System.Windows.Forms.GroupBox
$pathsGroup.Text = "Directories"
$pathsGroup.Location = New-Object System.Drawing.Point(420, 50)
$pathsGroup.Size = New-Object System.Drawing.Size(395, 160)
$tabSettings.Controls.Add($pathsGroup)

$paths = @(
    @{ Label = "Screenshots:"; Path = $ScreenshotsDir },
    @{ Label = "Library:"; Path = $LibraryDir },
    @{ Label = "Encrypted:"; Path = $EncryptedDir },
    @{ Label = "Temp:"; Path = $TempDir }
)
$py = 25
foreach ($p in $paths) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $p.Label
    $lbl.Location = New-Object System.Drawing.Point(10, $py)
    $lbl.Size = New-Object System.Drawing.Size(90, 22)
    $pathsGroup.Controls.Add($lbl)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Text = $p.Path
    $txt.Location = New-Object System.Drawing.Point(105, ($py - 3))
    $txt.Size = New-Object System.Drawing.Size(275, 25)
    $txt.ReadOnly = $true
    $pathsGroup.Controls.Add($txt)
    $py += 30
}

# Actions
$actionsGroup = New-Object System.Windows.Forms.GroupBox
$actionsGroup.Text = "Actions"
$actionsGroup.Location = New-Object System.Drawing.Point(15, 220)
$actionsGroup.Size = New-Object System.Drawing.Size(795, 100)
$tabSettings.Controls.Add($actionsGroup)

$assocBtn = New-Object System.Windows.Forms.Button
$assocBtn.Text = "Add Right-Click Menu"
$assocBtn.Location = New-Object System.Drawing.Point(10, 30)
$assocBtn.Size = New-Object System.Drawing.Size(170, 30)
$actionsGroup.Controls.Add($assocBtn)

$shortcutBtn = New-Object System.Windows.Forms.Button
$shortcutBtn.Text = "Create Desktop Shortcut"
$shortcutBtn.Location = New-Object System.Drawing.Point(190, 30)
$shortcutBtn.Size = New-Object System.Drawing.Size(170, 30)
$actionsGroup.Controls.Add($shortcutBtn)

$clearHistBtn = New-Object System.Windows.Forms.Button
$clearHistBtn.Text = "Clear History"
$clearHistBtn.Location = New-Object System.Drawing.Point(370, 30)
$clearHistBtn.Size = New-Object System.Drawing.Size(130, 30)
$actionsGroup.Controls.Add($clearHistBtn)

$clearTempBtn = New-Object System.Windows.Forms.Button
$clearTempBtn.Text = "Clean Temp Files"
$clearTempBtn.Location = New-Object System.Drawing.Point(510, 30)
$clearTempBtn.Size = New-Object System.Drawing.Size(140, 30)
$actionsGroup.Controls.Add($clearTempBtn)

$aboutBtn = New-Object System.Windows.Forms.Button
$aboutBtn.Text = "About"
$aboutBtn.Location = New-Object System.Drawing.Point(660, 30)
$aboutBtn.Size = New-Object System.Drawing.Size(120, 30)
$actionsGroup.Controls.Add($aboutBtn)

$actionStatus = New-Object System.Windows.Forms.Label
$actionStatus.Text = ""
$actionStatus.Location = New-Object System.Drawing.Point(10, 70)
$actionStatus.Size = New-Object System.Drawing.Size(770, 22)
$actionStatus.ForeColor = [System.Drawing.Color]::DarkGreen
$actionsGroup.Controls.Add($actionStatus)

# About info
$aboutGroup = New-Object System.Windows.Forms.GroupBox
$aboutGroup.Text = "About NJ Player 3.0"
$aboutGroup.Location = New-Object System.Drawing.Point(15, 330)
$aboutGroup.Size = New-Object System.Drawing.Size(795, 110)
$tabSettings.Controls.Add($aboutGroup)

$aboutText = New-Object System.Windows.Forms.Label
$aboutText.Text = "NJ Player 3.0 - Offline Video Enhancement & Encryption Suite`n`nFeatures: 10 enhancement presets, GPU shader pipeline, AES-256-GCM encryption,`n35-pass secure deletion, audio enhancement, auto-detection, compare mode.`n`nBuilt on mpv player. No internet required after initial setup."
$aboutText.Location = New-Object System.Drawing.Point(10, 20)
$aboutText.Size = New-Object System.Drawing.Size(775, 85)
$aboutGroup.Controls.Add($aboutText)

# ============================================
# SCRIPT-SCOPED VARIABLES
# ============================================
$script:videoFiles = @()
$script:currentFolder = ""
$script:playlist = @()  # Array of file paths
$script:playlistIndex = -1  # Current playing index
$script:repeatMode = $false  # Repeat playlist
$script:shuffleMode = $false  # Shuffle playlist

# ============================================
# FUNCTIONS
# ============================================

# --- Playlist Functions ---

function Update-PlaylistInfo {
    $count = $script:playlist.Count
    $playlistCount.Text = "Videos: $count"
    
    # Calculate total size
    $totalSize = 0
    foreach ($path in $script:playlist) {
        if (Test-Path $path) {
            $totalSize += (Get-Item $path).Length
        }
    }
    $sizeMB = [math]::Round($totalSize / 1MB, 1)
    $playlistSize.Text = "Size: $sizeMB MB"
    
    # Update current playing
    if ($script:playlistIndex -ge 0 -and $script:playlistIndex -lt $count) {
        $currentFile = [System.IO.Path]::GetFileName($script:playlist[$script:playlistIndex])
        $playlistCurrent.Text = "Now Playing: $currentFile"
    } else {
        $playlistCurrent.Text = "Now Playing: None"
    }
}

function Refresh-PlaylistDisplay {
    $playlistBox.Items.Clear()
    for ($i = 0; $i -lt $script:playlist.Count; $i++) {
        $file = $script:playlist[$i]
        $name = [System.IO.Path]::GetFileName($file)
        $marker = if ($i -eq $script:playlistIndex) { ">> " } else { "   " }
        $playlistBox.Items.Add("$marker$($i+1). $name") | Out-Null
    }
    Update-PlaylistInfo
}

function Add-ToPlaylist {
    param([string[]]$FilePaths)
    foreach ($fp in $FilePaths) {
        if (Test-Path $fp) {
            $script:playlist += $fp
        }
    }
    Refresh-PlaylistDisplay
    $playlistStatus.Text = "Added $($FilePaths.Count) file(s) to queue"
}

function Remove-FromPlaylist {
    if ($playlistBox.SelectedIndex -ge 0) {
        $idx = $playlistBox.SelectedIndex
        $removed = $script:playlist[$idx]
        $script:playlist = @($script:playlist | Where-Object { $_ -ne $removed })
        if ($script:playlistIndex -ge $idx) {
            $script:playlistIndex--
        }
        Refresh-PlaylistDisplay
        $playlistStatus.Text = "Removed: $([System.IO.Path]::GetFileName($removed))"
    }
}

function Move-PlaylistItem {
    param([int]$Direction)  # -1 = up, 1 = down
    $idx = $playlistBox.SelectedIndex
    if ($idx -lt 0) { return }
    $newIdx = $idx + $Direction
    if ($newIdx -lt 0 -or $newIdx -ge $script:playlist.Count) { return }
    
    # Swap
    $temp = $script:playlist[$idx]
    $script:playlist[$idx] = $script:playlist[$newIdx]
    $script:playlist[$newIdx] = $temp
    
    # Update current index if needed
    if ($script:playlistIndex -eq $idx) {
        $script:playlistIndex = $newIdx
    } elseif ($script:playlistIndex -eq $newIdx) {
        $script:playlistIndex = $idx
    }
    
    Refresh-PlaylistDisplay
    $playlistBox.SelectedIndex = $newIdx
}

function Play-PlaylistItem {
    param([int]$Index)
    if ($Index -lt 0 -or $Index -ge $script:playlist.Count) { return }
    $script:playlistIndex = $Index
    $file = $script:playlist[$Index]
    Refresh-PlaylistDisplay
    Play-Video -FilePath $file
}

function Play-NextInPlaylist {
    if ($script:playlist.Count -eq 0) { return }
    
    $nextIdx = $script:playlistIndex + 1
    
    if ($nextIdx -ge $script:playlist.Count) {
        if ($script:repeatMode) {
            $nextIdx = 0
        } else {
            $playlistStatus.Text = "Playlist finished"
            $playlistStatus.ForeColor = [System.Drawing.Color]::Gray
            return
        }
    }
    
    Play-PlaylistItem -Index $nextIdx
}

function Clear-Playlist {
    $script:playlist = @()
    $script:playlistIndex = -1
    Refresh-PlaylistDisplay
    $playlistStatus.Text = "Playlist cleared"
}

function Shuffle-Playlist {
    if ($script:playlist.Count -le 1) { return }
    $script:playlist = $script:playlist | Sort-Object { Get-Random }
    $script:playlistIndex = -1
    Refresh-PlaylistDisplay
    $playlistStatus.Text = "Playlist shuffled"
}

function Add-FolderToPlaylist {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select folder to add all videos to queue"
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $files = Get-ChildItem -Path $dialog.SelectedPath -File -ErrorAction SilentlyContinue |
            Where-Object { $videoExts -contains $_.Extension.ToLower() }
        if ($files.Count -gt 0) {
            $paths = $files | ForEach-Object { $_.FullName }
            Add-ToPlaylist -FilePaths $paths
        } else {
            $playlistStatus.Text = "No videos found in selected folder"
        }
    }
}

function Add-FileToPlaylist {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Video files|*.mp4;*.mkv;*.avi;*.mov;*.webm;*.flv;*.wmv;*.m4v;*.ts;*.mts;*.m2ts|All files|*.*"
    $dialog.Title = "Select videos to add to queue"
    $dialog.Multiselect = $true
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Add-ToPlaylist -FilePaths $dialog.FileNames
    }
}

# --- Player Functions ---

function Load-Videos {
    param([string]$Folder)
    $listBox.Items.Clear()
    $script:videoFiles = @()

    if (-not (Test-Path $Folder)) {
        $statusLabel.Text = "Folder not found: $Folder"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
        return
    }

    $files = Get-ChildItem -Path $Folder -File -ErrorAction SilentlyContinue |
        Where-Object { $videoExts -contains $_.Extension.ToLower() } |
        Sort-Object Name

    if ($files.Count -eq 0) {
        $statusLabel.Text = "No videos found in $(Split-Path $Folder -Leaf)"
        $statusLabel.ForeColor = [System.Drawing.Color]::OrangeRed
        return
    }

    $script:videoFiles = @($files)
    foreach ($f in $files) {
        $sizeMB = [math]::Round($f.Length / 1MB, 1)
        $listBox.Items.Add("$($f.Name)  [$sizeMB MB]") | Out-Null
    }

    $statusLabel.Text = "$($listBox.Items.Count) videos found in $(Split-Path $Folder -Leaf)"
    $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
    $script:currentFolder = $Folder
}

function Update-FileInfo {
    param([System.IO.FileInfo]$File)
    if (-not $File) {
        $infoName.Text = "No file selected"
        $infoSize.Text = "Size: --"
        $infoRes.Text = "Resolution: --"
        $infoDur.Text = "Duration: --"
        $infoCodec.Text = "Codec: --"
        return
    }
    $sizeMB = [math]::Round($File.Length / 1MB, 1)
    $infoName.Text = $File.Name
    $infoSize.Text = "Size: $sizeMB MB"
    $infoRes.Text = "Resolution: (click PLAY to detect)"
    $infoDur.Text = "Duration: (click PLAY to detect)"
    $infoCodec.Text = "Extension: $($File.Extension)"
}

function Play-Video {
    param([string]$FilePath)

    if (-not (Test-Path $MpvExe)) {
        [System.Windows.Forms.MessageBox]::Show(
            "mpv.exe not found!`n`nRun install.bat first to download mpv.",
            "NJ Player", "OK", "Warning")
        return
    }

    $preset = $presetDropdown.SelectedItem.ToString().ToLower()
    $statusLabel.Text = "Playing: $(Split-Path $FilePath -Leaf) [Preset: $preset]"
    $playlistStatus.Text = "Playing: $(Split-Path $FilePath -Leaf)"
    $playlistStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $form.Refresh()

    # Build mpv args. --config-dir loads the bundled mpv.conf (enhancement
    # profiles, input.conf hotkeys, shader paths), matching NJ-Player.bat.
    $mpvArgs = @(
        "--config-dir=`"$RootDir`"",
        "--profile=nj-$preset",
        "`"$FilePath`""
    )

    # Play and wait for it to finish
    $proc = Start-Process -FilePath $MpvExe -ArgumentList $mpvArgs -Wait -PassThru

    $statusLabel.Text = "Ready"
    $playlistStatus.Text = "Ready"
    $playlistStatus.ForeColor = [System.Drawing.Color]::DarkGreen

    # Auto-advance playlist if playing from queue
    if ($script:playlist.Count -gt 0 -and $script:playlistIndex -ge 0) {
        Play-NextInPlaylist
    }
}

function Run-Encrypt {
    $file = $encFileBox.Text
    $pass = $encPassBox.Text
    $confirm = $encPassConfirm.Text

    if (-not $file -or -not (Test-Path $file)) {
        $encStatus.Text = "Select a file first"
        $encStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }
    if (-not $pass) {
        $encStatus.Text = "Enter a password"
        $encStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }
    if ($pass -ne $confirm) {
        $encStatus.Text = "Passwords do not match"
        $encStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }
    if ($pass.Length -lt 6) {
        $encStatus.Text = "Password too short (min 6 chars)"
        $encStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }

    $encStatus.Text = "Encrypting..."
    $encStatus.ForeColor = [System.Drawing.Color]::Orange
    $form.Refresh()

    try {
        $pyProc = Start-Process -FilePath "python" -ArgumentList "`"$GencryptPy`" encrypt `"$file`" --password `"$pass`"" -Wait -PassThru -NoNewWindow
        if ($pyProc.ExitCode -eq 0) {
            $encStatus.Text = "Encrypted successfully!"
            $encStatus.ForeColor = [System.Drawing.Color]::DarkGreen
        } else {
            $encStatus.Text = "Encryption failed (exit code $($pyProc.ExitCode))"
            $encStatus.ForeColor = [System.Drawing.Color]::Red
        }
    } catch {
        $encStatus.Text = "Error: $($_.Exception.Message)"
        $encStatus.ForeColor = [System.Drawing.Color]::Red
    }
}

function Run-Decrypt {
    $file = $decFileBox.Text
    $pass = $decPassBox.Text

    if (-not $file -or -not (Test-Path $file)) {
        $decStatus.Text = "Select an encrypted file first"
        $decStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }
    if (-not $pass) {
        $decStatus.Text = "Enter the decryption password"
        $decStatus.ForeColor = [System.Drawing.Color]::Red
        return
    }

    $decStatus.Text = "Decrypting..."
    $decStatus.ForeColor = [System.Drawing.Color]::Orange
    $form.Refresh()

    try {
        $pyProc = Start-Process -FilePath "python" -ArgumentList "`"$GencryptPy`" decrypt `"$file`" --password `"$pass`"" -Wait -PassThru -NoNewWindow
        if ($pyProc.ExitCode -eq 0) {
            $decStatus.Text = "Decrypted! Playing..."
            $decStatus.ForeColor = [System.Drawing.Color]::DarkGreen
            # Play the decrypted file
            $decryptedFile = $file -replace '\.enc$', ''
            if (Test-Path $decryptedFile) {
                Play-Video -FilePath $decryptedFile
            }
        } else {
            $decStatus.Text = "Decryption failed - wrong password?"
            $decStatus.ForeColor = [System.Drawing.Color]::Red
        }
    } catch {
        $decStatus.Text = "Error: $($_.Exception.Message)"
        $decStatus.ForeColor = [System.Drawing.Color]::Red
    }
}

# ============================================
# EVENT HANDLERS
# ============================================

# --- Playlist Event Handlers ---

# Add to queue button
$addToPlaylistBtn.Add_Click({
    Add-FileToPlaylist
})

# Remove from queue
$removeFromPlaylistBtn.Add_Click({
    Remove-FromPlaylist
})

# Clear queue
$clearPlaylistBtn.Add_Click({
    Clear-Playlist
})

# Move up
$moveUpBtn.Add_Click({
    Move-PlaylistItem -Direction -1
})

# Move down
$moveDownBtn.Add_Click({
    Move-PlaylistItem -Direction 1
})

# Double-click to play from queue
$playlistBox.Add_DoubleClick({
    if ($playlistBox.SelectedIndex -ge 0) {
        Play-PlaylistItem -Index $playlistBox.SelectedIndex
    }
})

# Play queue button
$playQueueBtn.Add_Click({
    if ($script:playlist.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Queue is empty. Add videos first.", "NJ Player", "OK", "Information")
        return
    }
    Play-PlaylistItem -Index 0
})

# Shuffle button
$shuffleBtn.Add_Click({
    Shuffle-Playlist
})

# Repeat toggle
$repeatBtn.Add_Click({
    $script:repeatMode = -not $script:repeatMode
    if ($script:repeatMode) {
        $repeatBtn.Text = "Repeat: ON"
        $repeatBtn.BackColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
    } else {
        $repeatBtn.Text = "Repeat: OFF"
        $repeatBtn.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    }
})

# --- Player Event Handlers ---

# List selection - update file info
$listBox.Add_SelectedIndexChanged({
    if ($listBox.SelectedIndex -ge 0 -and $script:videoFiles.Count -gt 0) {
        Update-FileInfo -File $script:videoFiles[$listBox.SelectedIndex]
    }
})

# Double-click to play
$listBox.Add_DoubleClick({
    if ($listBox.SelectedIndex -ge 0 -and $script:videoFiles.Count -gt 0) {
        Play-Video -FilePath $script:videoFiles[$listBox.SelectedIndex].FullName
    }
})

# Play button
$playBtn.Add_Click({
    if ($listBox.SelectedIndex -ge 0 -and $script:videoFiles.Count -gt 0) {
        Play-Video -FilePath $script:videoFiles[$listBox.SelectedIndex].FullName
    } else {
        [System.Windows.Forms.MessageBox]::Show("Select a video from the list first.", "NJ Player", "OK", "Information")
    }
})

# Browse
$browseBtn.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select a folder containing video files"
    $dialog.ShowNewFolderButton = $false
    if ($script:currentFolder -and (Test-Path $script:currentFolder)) {
        $dialog.SelectedPath = $script:currentFolder
    }
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        Load-Videos -Folder $dialog.SelectedPath
    }
})

# Screenshot
$screenshotBtn.Add_Click({
    $statusLabel.Text = "Press S during playback to take a screenshot"
    $statusLabel.ForeColor = [System.Drawing.Color]::DarkBlue
})

# Compare mode
$compareBtn.Add_Click({
    $presetDropdown.SelectedItem = "Compare"
    $statusLabel.Text = "Compare mode selected - play a video to see split-screen"
    $statusLabel.ForeColor = [System.Drawing.Color]::DarkBlue
})

# Performance monitor
$perfBtn.Add_Click({
    $statusLabel.Text = "Press CTRL+SHIFT+P during playback to toggle performance monitor"
    $statusLabel.ForeColor = [System.Drawing.Color]::DarkBlue
})

# Preset change updates info
$presetDropdown.Add_SelectedIndexChanged({
    $infoPreset.Text = "Preset: $($presetDropdown.SelectedItem)"
})

# Encryption browse
$encBrowseBtn.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Video files|*.mp4;*.mkv;*.avi;*.mov;*.webm;*.flv;*.wmv;*.m4v;*.ts|All files|*.*"
    $dialog.Title = "Select video to encrypt"
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $encFileBox.Text = $dialog.FileName
    }
})

# Encrypt button
$encryptBtn.Add_Click({ Run-Encrypt })

# Decryption browse
$decBrowseBtn.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Encrypted files|*.enc|All files|*.*"
    $dialog.Title = "Select encrypted file"
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $decFileBox.Text = $dialog.FileName
    }
})

# Decrypt button
$decPlayBtn.Add_Click({ Run-Decrypt })

# Secure delete browse
$delBrowseBtn.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "All files|*.*"
    $dialog.Title = "Select file to securely delete"
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $delFileBox.Text = $dialog.FileName
    }
})

# Secure delete
$delBtn.Add_Click({
    $file = $delFileBox.Text
    if (-not $file -or -not (Test-Path $file)) {
        [System.Windows.Forms.MessageBox]::Show("Select a file to delete.", "NJ Player")
        return
    }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "SECURELY DELETE this file?`n`n$file`n`nThis will overwrite the file 35 times before deletion. This cannot be undone.",
        "Confirm Secure Delete",
        "YesNo", "Warning")
    if ($confirm -eq "Yes") {
        try {
            $pyProc = Start-Process -FilePath "python" -ArgumentList "`"$GencryptPy`" secure-delete `"$file`"" -Wait -PassThru -NoNewWindow
            if ($pyProc.ExitCode -eq 0) {
                $delFileBox.Text = ""
                [System.Windows.Forms.MessageBox]::Show("File securely deleted.", "NJ Player")
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Delete failed: $($_.Exception.Message)", "Error")
        }
    }
})

# Settings actions
$assocBtn.Add_Click({
    $result = Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$RootDir\associate.ps1`"" -Wait -PassThru
    if ($result.ExitCode -eq 0) { $actionStatus.Text = "Right-click menu added" }
})

$shortcutBtn.Add_Click({
    $result = Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$RootDir\desktop-shortcut.ps1`"" -Wait -PassThru
    if ($result.ExitCode -eq 0) { $actionStatus.Text = "Desktop shortcut created" }
})

$clearHistBtn.Add_Click({
    $result = Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$RootDir\clear-history.ps1`"" -Wait -PassThru
    $actionStatus.Text = "History cleared"
})

$clearTempBtn.Add_Click({
    if (Test-Path $TempDir) {
        $count = (Get-ChildItem -Path $TempDir -File -ErrorAction SilentlyContinue).Count
        Remove-Item -Path "$TempDir\*" -Force -ErrorAction SilentlyContinue
        $actionStatus.Text = "Cleaned $count temp files"
    }
})

$aboutBtn.Add_Click({
    $aboutText = @"
NJ PLAYER 3.0
Offline Video Enhancement & Encryption Suite

Features:
- 10 GPU-accelerated enhancement presets
- AES-256-GCM encryption with PBKDF2
- 35-pass Gutmann secure deletion
- 7 audio enhancement controls
- Smart content auto-detection
- Split-screen compare mode
- Performance monitoring

Built on mpv player. 100% offline after setup.

For help, see README.md or press F1 during playback.
"@
    [System.Windows.Forms.MessageBox]::Show($aboutText, "About NJ Player 3.0")
})

# ============================================
# STARTUP
# ============================================
$startFolder = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
if (-not (Test-Path $startFolder)) {
    $startFolder = [Environment]::GetFolderPath("Desktop")
}
$script:currentFolder = $startFolder
Load-Videos -Folder $startFolder

if (-not (Test-Path $MpvExe)) {
    $statusLabel.Text = "WARNING: Run install.bat first to download mpv"
    $statusLabel.ForeColor = [System.Drawing.Color]::OrangeRed
}

if (-not (Test-Path $GencryptPy)) {
    $encStatus.Text = "Python security engine not found"
    $encStatus.ForeColor = [System.Drawing.Color]::OrangeRed
    $decStatus.Text = "Python security engine not found"
    $decStatus.ForeColor = [System.Drawing.Color]::OrangeRed
}

$form.Add_Shown({ $form.Activate() })
[System.Windows.Forms.Application]::Run($form)
