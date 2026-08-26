-- ============================================
-- NJ PLAYER 3.0 — PLAYER OVERLAY
-- Minimal controls with fade in/out
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Overlay state
local overlay_visible = false
local mouse_last_move = 0
local mouse_idle_timeout = 3  -- seconds

-- Colors (matching UI theme)
local COLORS = {
    accent = '00d4ff',
    bg = '0a0a0f',
    text = 'ffffff',
    text_secondary = 'b0b0c0',
}

-- Current enhancement preset
local current_preset = "Auto"

-- ============================================
-- OSD MESSAGE STYLING
-- ============================================
local function show_styled_message(text, duration)
    mp.osd_message(text, duration or 2)
end

-- ============================================
-- PRESET DISPLAY
-- ============================================
local function show_preset_info(preset_name, description)
    local msg = string.format(
        "{\\fscx125\\fscy125\\bord2\\bord\\1c&H%s&}%s{\\rDefault}\n{\\fs18\\1c&H%s&}%s",
        COLORS.accent, preset_name:upper(),
        COLORS.text_secondary, description
    )
    show_styled_message(msg, 2.5)
end

-- ============================================
-- MOUSE IDLE DETECTION
-- ============================================
mp.register_event('mouse-move', function()
    mouse_last_move = mp.get_time()

    if not overlay_visible then
        -- Show overlay
        mp.command('script-message osc-visibility always')
        overlay_visible = true
    end
end)

-- Check mouse idle every second
mp.add_periodic_timer(1, function()
    if overlay_visible and (mp.get_time() - mouse_last_move) > mouse_idle_timeout then
        -- Hide overlay
        mp.command('script-message osc-visibility auto')
        overlay_visible = false
    end
end)

-- ============================================
-- ENHANCEMENT STATUS DISPLAY
-- ============================================
local presets = {
    off     = { name = "Off",     desc = "Clean playback" },
    lucid   = { name = "Lucid",   desc = "Adaptive sharpening" },
    cinema  = { name = "Cinema",  desc = "Full restoration pipeline" },
    anime   = { name = "Anime",   desc = "Anime4K restoration" },
    hdr     = { name = "HDR",     desc = "HDR tone mapping" },
    denoise = { name = "Denoise", desc = "Skin-preserving denoise" },
    motion  = { name = "Motion",  desc = "Frame interpolation" },
    auto    = { name = "Auto",    desc = "Smart detection" },
    compare = { name = "Compare", desc = "Split-screen" },
    restore = { name = "Restore", desc = "Full restoration" },
}

-- Listens to 'nj-preset-info' broadcast by nj-presets.lua (which applies the
-- profile). This handler only updates the on-screen display, so it never
-- overrides the preset-application handler in nj-presets.lua.
mp.register_script_message('nj-preset-info', function(name)
    if presets[name] then
        current_preset = name
        show_preset_info(presets[name].name, presets[name].desc)
    end
end)

-- ============================================
-- CUSTOM OSD FOR ENHANCEMENT
-- ============================================
local function show_enhancement_osd()
    if current_preset and presets[current_preset] then
        local p = presets[current_preset]
        show_preset_info(p.name, p.desc)
    end
end

-- Show on file load
mp.register_event('file-loaded', function()
    show_enhancement_osd()
end)

-- ============================================
-- TOP INFO BAR
-- ============================================
local function show_info_bar()
    local filename = mp.get_property('filename', 'Unknown')
    local time_pos = mp.get_property('time-pos', 0)
    local duration = mp.get_property('duration', 0)

    local formatted_time = string.format("%s / %s",
        mp.format_time(time_pos),
        mp.format_time(duration)
    )

    local info = string.format(
        "{\\fscx110\\fscy110\\bord2\\1c&H%s&}%s{\\rDefault}  {\\fs16\\1c&H%s&}%s",
        COLORS.accent, current_preset:upper(),
        COLORS.text_secondary, formatted_time
    )

    mp.osd_message(info, 1.5)
end

mp.add_key_binding('TAB', 'nj-show-info', function()
    show_info_bar()
end)

-- ============================================
-- HELP OVERLAY
-- ============================================
local help_text = [[
{\fscx120\fscy120\bord2\bord\1c&H00d4ff&}NJ PLAYER 3.0{\rDefault}

{\fs16\1c&Hb0b0c0&}ENHANCEMENT{\rDefault}
  F9          Cycle presets
  CTRL+0-9    Direct preset selection
  CTRL+8      Compare mode

{\fs16\1c&Hb0b0c0&}AUDIO{\rDefault}
  CTRL+SHIFT+A   Toggle enhancement
  CTRL+SHIFT+D   Dialogue boost

{\fs16\1c&Hb0b0c0&}VIDEO{\rDefault}
  Z           Zoom
  C           Crop black bars
  S           Screenshot
  TAB+2       Tech stats

{\fs16\1c&Hb0b0c0&}SECURITY{\rDefault}
  CTRL+E      Encrypt current video
  CTRL+D      Decrypt & play
]]

mp.add_key_binding('SHIFT+H', 'nj-help', function()
    mp.osd_message(help_text, 8)
end)

msg.info("NJ Player overlay loaded")
