-- ============================================
-- NJ PLAYER 3.0 — SETTINGS MANAGER
-- Loads and saves user preferences
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Settings file path
local settings_path = mp.command_native({"expand-path", "~~/nj-config/settings.json"})

-- Default settings
local default_settings = {
    version = "3.0.1",
    enhancement = {
        default_preset = "auto",
        auto_detect = true,
        preserve_skin_tone = true,
        deband_strength = 0.4,
        denoise_strength = 0.3,
        sharpen_strength = 0.5,
        upscale_target = 2,
    },
    audio = {
        enabled = true,
        noise_reduction = true,
        dialogue_boost = true,
        volume_normalize = true,
        bass_restore = false,
        stereo_widen = false,
        night_mode = false,
        loudness_target = -16,
    },
    security = {
        encryption = "AES-256-GCM",
        secure_delete_passes = 35,
        clear_ram_on_exit = true,
        lock_after_minutes = 5,
        max_password_attempts = 5,
    },
    appearance = {
        theme = "dark",
        accent_color = "#00d4ff",
        show_fps = false,
        show_status = true,
        font_size = 12,
    },
    performance = {
        hardware_decoding = "auto",
        gpu_api = "auto",
        target_fps = 60,
        auto_quality_adjust = true,
        battery_saver = true,
    },
    playback = {
        save_position = true,
        resume_playback = true,
        default_volume = 100,
        default_speed = 1.0,
        default_subtitle_track = "auto",
    },
}

-- Current settings
local settings = {}

-- ============================================
-- LOAD SETTINGS
-- ============================================
local function load_settings()
    local file = io.open(settings_path, "r")

    if file then
        local content = file:read("*all")
        file:close()

        local ok, parsed = pcall(function()
            return mp.utils.parse_json(content)
        end)

        if ok and parsed then
            -- Merge with defaults (shallow merge for simplicity)
            for key, value in pairs(default_settings) do
                settings[key] = parsed[key] or value
            end
        else
            msg.warn("Failed to parse settings.json, using defaults")
            settings = default_settings
        end
    else
        msg.info("No settings.json found, using defaults")
        settings = default_settings

        -- Create default settings file
        save_settings()
    end

    return settings
end

-- ============================================
-- SAVE SETTINGS
-- ============================================
function save_settings()
    local json = mp.utils.format_json(settings)

    local file = io.open(settings_path, "w")
    if file then
        file:write(json)
        file:close()
        msg.info("Settings saved")
    else
        msg.warn("Failed to save settings")
    end
end

-- ============================================
-- APPLY SETTINGS
-- ============================================
local function apply_settings()
    -- Apply enhancement settings
    if settings.enhancement and settings.enhancement.default_preset then
        mp.commandv('script-message', 'nj-preset', settings.enhancement.default_preset)
    end

    -- Apply audio settings
    if settings.audio and settings.audio.enabled then
        mp.commandv('script-message', 'nj-audio-profile', 'enhanced')
    end

    -- Apply performance settings
    if settings.performance and settings.performance.hardware_decoding then
        mp.set_property('hwdec', settings.performance.hardware_decoding)
    end

    -- Apply playback settings
    if settings.playback then
        if settings.playback.default_volume then
            mp.set_property('volume', settings.playback.default_volume)
        end

        if settings.playback.default_speed then
            mp.set_property('speed', settings.playback.default_speed)
        end

        if settings.playback.save_position then
            mp.set_property('save-position-on-quit', 'yes')
        end
    end
end

-- ============================================
-- UPDATE SETTING
-- ============================================
local function update_setting(category, key, value)
    if not settings[category] then
        settings[category] = {}
    end

    settings[category][key] = value
    save_settings()
    apply_settings()

    mp.osd_message(string.format("Setting updated: %s.%s = %s", category, key, tostring(value)), 2)
end

-- ============================================
-- SCRIPT MESSAGE HANDLERS
-- ============================================
mp.register_script_message('nj-settings-get', function(category, key)
    if settings[category] and settings[category][key] ~= nil then
        return settings[category][key]
    end
    return nil
end)

mp.register_script_message('nj-settings-set', function(category, key, value)
    update_setting(category, key, value)
end)

mp.register_script_message('nj-settings-save', function()
    save_settings()
end)

-- ============================================
-- INITIALIZATION
-- ============================================
settings = load_settings()

mp.register_event('file-loaded', function()
    apply_settings()
end)

msg.info("Settings manager loaded")
