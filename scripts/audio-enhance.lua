-- ============================================
-- NJ PLAYER 3.0 — AUDIO ENHANCEMENT ENGINE
-- Real-time audio processing pipeline
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Audio enhancement state
local audio_enhancement = {
    enabled = true,
    noise_reduction = true,
    dialogue_boost = true,
    volume_normalize = true,
    bass_restore = false,
    stereo_widen = false,
    night_mode = false,
}

-- Current audio filter chain
local current_filters = {}

-- ============================================
-- AUDIO FILTER DEFINITIONS
-- ============================================

local filters = {
    -- Noise reduction (removes hiss and background noise)
    noise_reduction = {
        name = "Noise Reduction",
        filter = "afftdn=nf=-50:nr=12",
        description = "Removes background hiss and noise"
    },

    -- Dialogue enhancement (boosts speech clarity)
    dialogue_boost = {
        name = "Dialogue Boost",
        filter = "dialoguenhance=original=1:enhance=1.5",
        description = "Enhances speech clarity"
    },

    -- Dynamic range compression (evens out volume)
    volume_normalize = {
        name = "Volume Normalize",
        filter = "acompressor=threshold=-20:ratio=3:attack=20:release=250",
        description = "Evens out volume levels"
    },

    -- Bass restoration (adds warmth)
    bass_restore = {
        name = "Bass Restore",
        filter = "bass=g=3:f=100",
        description = "Adds warmth to thin audio"
    },

    -- Stereo widening (spatial expansion)
    stereo_widen = {
        name = "Stereo Widen",
        filter = "stereowiden=level=1.2",
        description = "Expands stereo field"
    },

    -- Night mode (compresses dynamic range)
    night_mode = {
        name = "Night Mode",
        filter = "acompressor=threshold=-30:ratio=8:attack=10:release=100",
        description = "Reduces loud sounds for night viewing"
    },

    -- Loudness normalization (broadcast standard)
    loudness_normalize = {
        name = "Loudness Normalize",
        filter = "loudnorm=I=-16:TP=-1.5:LRA=11",
        description = "Broadcast-standard loudness"
    },
}

-- ============================================
-- BUILD FILTER CHAIN
-- ============================================
local function build_filter_chain()
    local active_filters = {}

    if audio_enhancement.enabled then
        if audio_enhancement.noise_reduction then
            table.insert(active_filters, filters.noise_reduction.filter)
        end

        if audio_enhancement.dialogue_boost then
            table.insert(active_filters, filters.dialogue_boost.filter)
        end

        if audio_enhancement.bass_restore then
            table.insert(active_filters, filters.bass_restore.filter)
        end

        if audio_enhancement.volume_normalize then
            table.insert(active_filters, filters.volume_normalize.filter)
        end

        if audio_enhancement.stereo_widen then
            table.insert(active_filters, filters.stereo_widen.filter)
        end
    end

    if audio_enhancement.night_mode then
        table.insert(active_filters, filters.night_mode.filter)
    end

    -- Always apply loudness normalization for consistency
    table.insert(active_filters, filters.loudness_normalize.filter)

    return active_filters
end

-- ============================================
-- SHOW AUDIO STATUS
-- ============================================
local function show_audio_status()
    local active = {}

    if audio_enhancement.enabled then
        if audio_enhancement.noise_reduction then
            table.insert(active, "Noise Reduction")
        end
        if audio_enhancement.dialogue_boost then
            table.insert(active, "Dialogue Boost")
        end
        if audio_enhancement.bass_restore then
            table.insert(active, "Bass Restore")
        end
        if audio_enhancement.volume_normalize then
            table.insert(active, "Volume Normalize")
        end
        if audio_enhancement.stereo_widen then
            table.insert(active, "Stereo Widen")
        end
    end

    if audio_enhancement.night_mode then
        table.insert(active, "Night Mode")
    end

    if #active == 0 then
        mp.osd_message("Audio: Off", 1)
    else
        local status = string.format(
            "Audio Enhancement: %s",
            table.concat(active, " + ")
        )
        mp.osd_message(status, 2)
    end
end

-- ============================================
-- APPLY FILTER CHAIN
-- ============================================
local function apply_audio_filters()
    local chain = build_filter_chain()

    if #chain > 0 then
        local filter_string = table.concat(chain, ",")
        mp.set_property('af', filter_string)
        current_filters = chain
    else
        mp.set_property('af', '')
        current_filters = {}
    end

    -- Show status
    show_audio_status()
end

-- ============================================
-- TOGGLE FUNCTIONS
-- ============================================
local function toggle_audio_enhancement()
    audio_enhancement.enabled = not audio_enhancement.enabled
    apply_audio_filters()
end

local function toggle_noise_reduction()
    audio_enhancement.noise_reduction = not audio_enhancement.noise_reduction
    apply_audio_filters()
end

local function toggle_dialogue_boost()
    audio_enhancement.dialogue_boost = not audio_enhancement.dialogue_boost
    apply_audio_filters()
end

local function toggle_volume_normalize()
    audio_enhancement.volume_normalize = not audio_enhancement.volume_normalize
    apply_audio_filters()
end

local function toggle_bass_restore()
    audio_enhancement.bass_restore = not audio_enhancement.bass_restore
    apply_audio_filters()
end

local function toggle_stereo_widen()
    audio_enhancement.stereo_widen = not audio_enhancement.stereo_widen
    apply_audio_filters()
end

local function toggle_night_mode()
    audio_enhancement.night_mode = not audio_enhancement.night_mode
    apply_audio_filters()
end

-- ============================================
-- AUDIO PROFILE PRESETS
-- ============================================
local audio_profiles = {
    normal = {
        enabled = false,
        noise_reduction = false,
        dialogue_boost = false,
        volume_normalize = false,
        bass_restore = false,
        stereo_widen = false,
        night_mode = false,
    },
    enhanced = {
        enabled = true,
        noise_reduction = true,
        dialogue_boost = true,
        volume_normalize = true,
        bass_restore = false,
        stereo_widen = false,
        night_mode = false,
    },
    dialogue = {
        enabled = true,
        noise_reduction = true,
        dialogue_boost = true,
        volume_normalize = true,
        bass_restore = false,
        stereo_widen = false,
        night_mode = false,
    },
    music = {
        enabled = true,
        noise_reduction = false,
        dialogue_boost = false,
        volume_normalize = true,
        bass_restore = true,
        stereo_widen = true,
        night_mode = false,
    },
    night = {
        enabled = true,
        noise_reduction = true,
        dialogue_boost = true,
        volume_normalize = true,
        bass_restore = false,
        stereo_widen = false,
        night_mode = true,
    },
}

local function apply_audio_profile(profile_name)
    local profile = audio_profiles[profile_name]
    if not profile then
        msg.warn("Unknown audio profile: " .. profile_name)
        return
    end

    for key, value in pairs(profile) do
        audio_enhancement[key] = value
    end

    apply_audio_filters()

    local profile_display = {
        normal = "Normal",
        enhanced = "Enhanced",
        dialogue = "Dialogue Boost",
        music = "Music",
        night = "Night Mode",
    }

    mp.osd_message(
        string.format("🔊 Audio: %s", profile_display[profile_name] or profile_name),
        2
    )
end

-- ============================================
-- SCRIPT MESSAGE HANDLERS
-- ============================================
mp.register_script_message('nj-audio-toggle', function()
    toggle_audio_enhancement()
end)

mp.register_script_message('nj-dialogue-boost', function()
    toggle_dialogue_boost()
end)

mp.register_script_message('nj-noise-reduction', function()
    toggle_noise_reduction()
end)

mp.register_script_message('nj-volume-normalize', function()
    toggle_volume_normalize()
end)

mp.register_script_message('nj-bass-restore', function()
    toggle_bass_restore()
end)

mp.register_script_message('nj-stereo-widen', function()
    toggle_stereo_widen()
end)

mp.register_script_message('nj-night-mode', function()
    toggle_night_mode()
end)

mp.register_script_message('nj-audio-profile', function(profile)
    apply_audio_profile(profile)
end)

-- ============================================
-- KEY BINDINGS
-- ============================================
mp.add_key_binding('CTRL+SHIFT+A', 'nj-audio-toggle', toggle_audio_enhancement)
mp.add_key_binding('CTRL+SHIFT+D', 'nj-dialogue-boost', toggle_dialogue_boost)
mp.add_key_binding('CTRL+SHIFT+N', 'nj-noise-reduction', toggle_noise_reduction)
mp.add_key_binding('CTRL+SHIFT+V', 'nj-volume-normalize', toggle_volume_normalize)
mp.add_key_binding('CTRL+SHIFT+B', 'nj-bass-restore', toggle_bass_restore)
mp.add_key_binding('CTRL+SHIFT+W', 'nj-stereo-widen', toggle_stereo_widen)
mp.add_key_binding('CTRL+SHIFT+M', 'nj-night-mode', toggle_night_mode)

-- ============================================
-- INITIALIZATION
-- ============================================
mp.register_event('file-loaded', function()
    -- Apply default audio profile
    apply_audio_profile('enhanced')
end)

msg.info("Audio enhancement engine loaded")
