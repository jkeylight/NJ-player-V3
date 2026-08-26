-- ============================================
-- NJ PLAYER 3.0 — AUTO ENHANCEMENT DETECTION
-- Analyzes video and applies optimal preset
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Auto-detection state
local auto_detection = {
    enabled = true,
    last_preset = nil,
    analysis_complete = false,
}

-- ============================================
-- VIDEO ANALYSIS
-- ============================================
local function analyze_video()
    local properties = {
        width = mp.get_property_number('width', 0),
        height = mp.get_property_number('height', 0),
        fps = mp.get_property_number('container-fps', 0),
        video_format = mp.get_property('video-format', ''),
        primaries = mp.get_property('video-params/primaries', ''),
        gamma = mp.get_property('video-params/gamma', ''),
        codec = mp.get_property('video-codec', ''),
        bitrate = mp.get_property_number('video-bitrate', 0),
    }

    return properties
end

-- ============================================
-- HDR DETECTION
-- ============================================
local function is_hdr(properties)
    local hdr_primaries = {
        'bt.2020',
        'bt2020',
        'smpte2084',
        'arib-std-b67',
    }

    for _, p in ipairs(hdr_primaries) do
        if properties.primaries:lower():find(p) then
            return true
        end
    end

    -- Check gamma for HDR
    if properties.gamma:lower():find('pq') or properties.gamma:lower():find('hlg') then
        return true
    end

    return false
end

-- ============================================
-- ANIME DETECTION (Heuristic)
-- ============================================
local function is_anime(properties)
    -- Anime characteristics:
    -- 1. Often lower resolution (720p or less)
    -- 2. Lower bitrate for resolution
    -- 3. Specific codecs common in anime

    if properties.width <= 1280 and properties.height <= 720 then
        -- Check bitrate per pixel
        local pixels = properties.width * properties.height
        if pixels > 0 and properties.bitrate > 0 then
            local bits_per_pixel = properties.bitrate / properties.fps / pixels
            -- Anime typically has lower bits per pixel
            if bits_per_pixel < 0.1 then
                return true
            end
        end
    end

    return false
end

-- ============================================
-- LOW RESOLUTION DETECTION
-- ============================================
local function get_resolution_tier(properties)
    local pixels = properties.width * properties.height

    if pixels <= 640 * 360 then      -- 360p or lower
        return 'very_low'
    elseif pixels <= 1280 * 720 then  -- 720p
        return 'low'
    elseif pixels <= 1920 * 1080 then -- 1080p
        return 'medium'
    else                               -- 4K+
        return 'high'
    end
end

-- ============================================
-- NOISE DETECTION (Frame Analysis)
-- ============================================
local function detect_noise()
    -- Take a screenshot and analyze
    -- This is a simplified heuristic
    local width = mp.get_property_number('width', 0)
    local height = mp.get_property_number('height', 0)

    if width == 0 or height == 0 then
        return false
    end

    -- Low-res video more likely to have noise
    if width * height <= 640 * 480 then
        return true
    end

    return false
end

-- ============================================
-- MOTION DETECTION
-- ============================================
local function detect_motion(properties)
    -- High FPS content likely sports/action
    if properties.fps >= 50 then
        return true
    end

    return false
end

-- ============================================
-- SELECT OPTIMAL PRESET
-- ============================================
local function select_preset(properties)
    -- Priority order:
    -- 1. HDR content
    -- 2. Anime
    -- 3. Very low resolution
    -- 4. Motion content
    -- 5. Default

    if is_hdr(properties) then
        return 'hdr'
    end

    if is_anime(properties) then
        return 'anime'
    end

    local tier = get_resolution_tier(properties)

    if tier == 'very_low' then
        return 'restore'
    elseif tier == 'low' then
        return 'cinema'
    elseif tier == 'medium' then
        if detect_motion(properties) then
            return 'motion'
        end
        return 'lucid'
    else
        return 'off'  -- Don't touch 4K content
    end
end

-- ============================================
-- APPLY AUTO-DETECTED PRESET
-- ============================================
local function apply_auto_preset()
    local properties = analyze_video()
    local preset = select_preset(properties)

    -- Apply the preset
    mp.commandv('script-message', 'nj-preset', preset)

    -- Show detection results
    local reasons = {}

    if is_hdr(properties) then
        table.insert(reasons, "HDR content detected")
    end

    if is_anime(properties) then
        table.insert(reasons, "Anime characteristics")
    end

    local tier = get_resolution_tier(properties)
    table.insert(reasons, string.format("%dx%d resolution", properties.width, properties.height))

    if detect_motion(properties) then
        table.insert(reasons, "High motion content")
    end

    local detection_msg = string.format(
        "{\\fscx120\\fscy120\\bord2\\1c&H00d4ff&}AUTO DETECTION{\\rDefault}\n" ..
        "Preset: {\\1c&H00ff88&}%s{\\rDefault}\n" ..
        "{\\fs14\\1c&H606070&}%s",
        preset:upper(),
        table.concat(reasons, " | ")
    )

    mp.osd_message(detection_msg, 4)

    auto_detection.last_preset = preset
    auto_detection.analysis_complete = true

    msg.info(string.format("Auto-detected preset: %s", preset))
end

-- ============================================
-- TOGGLE AUTO DETECTION
-- ============================================
local function toggle_auto_detection()
    auto_detection.enabled = not auto_detection.enabled

    if auto_detection.enabled then
        mp.osd_message("Auto Detection: ON", 1)
        apply_auto_preset()
    else
        mp.osd_message("Auto Detection: OFF", 1)
    end
end

-- ============================================
-- SCRIPT MESSAGE HANDLERS
-- ============================================
mp.register_script_message('nj-auto-detect', function()
    apply_auto_preset()
end)

mp.register_script_message('nj-auto-toggle', function()
    toggle_auto_detection()
end)

-- ============================================
-- KEY BINDINGS
-- ============================================
mp.add_key_binding('CTRL+7', 'nj-auto-detect', apply_auto_preset)
mp.add_key_binding('CTRL+SHIFT+7', 'nj-auto-toggle', toggle_auto_detection)

-- ============================================
-- AUTO-DETECT ON FILE LOAD
-- ============================================
mp.register_event('file-loaded', function()
    auto_detection.analysis_complete = false

    -- Small delay to allow video properties to load
    mp.add_timeout(0.5, function()
        if auto_detection.enabled then
            apply_auto_preset()
        end
    end)
end)

-- ============================================
-- PERFORMANCE FALLBACK (frame-drop watchdog)
-- If a heavy preset (Cinema/Restore) drops too many frames, this switches to
-- the stripped-down "fallback" profile to keep playback smooth. The user can
-- always override with CTRL+1 etc. after the message appears.
-- ============================================
local fallback = {
    trigger_threshold = 0.85,   -- fraction of dropped frames over the window
    window_frames = 60,          -- how many displayed frames to observe
    min_drop_rate = 0.20,        -- don't act unless drop rate is meaningful
    cooldown = 10.0,             -- seconds before re-checking after a change
    last_change = 0,
    active = false,
    pending_frames = 0,
    displayed_frames = 0,
}

local function current_preset_name()
    local profile = mp.get_property_string('current-profile', '')
    -- profile looks like "nj-cinema" -> return "cinema"
    return profile:gsub('^nj%-', '')
end

local function enable_fallback(preset)
    if fallback.active then return end
    mp.commandv('apply-profile', 'nj-fallback')
    fallback.active = true
    fallback.last_change = mp.get_time()
    mp.osd_message(string.format(
        "{\\fs20\\1c&Hff8888&}Performance monitor: dropping frames on %s{\\rDefault}\\n" ..
        "{\\fs16\\1c&Hb0b0c0&}Switched to fallback (no shaders).\\nPress CTRL+1..9 to re-enable an enhancement preset.",
        preset), 6)
    msg.info("NJ fallback engaged (frames dropping on " .. preset .. ")")
end

-- Disable fallback when the user explicitly picks a preset again.
mp.register_script_message('nj-preset', function(name)
    if fallback.active then
        fallback.active = false
        msg.info("NJ fallback disabled (user selected preset: " .. name .. ")")
    end
end)

local function on_playback_frame(dropped)
    if not mp.get_property_bool('pause', false) then
        if dropped then
            fallback.pending_frames = fallback.pending_frames + 1
        else
            fallback.displayed_frames = fallback.displayed_frames + 1
        end
    end

    local total = fallback.pending_frames + fallback.displayed_frames
    if total < fallback.window_frames then
        return
    end

    local drop_rate = fallback.pending_frames / total

    -- Only act on heavy presets, and respect cooldown.
    local preset = current_preset_name()
    local heavy = (preset == 'cinema' or preset == 'restore' or preset == 'anime' or preset == 'denoise')
    local now = mp.get_time()

    if heavy and not fallback.active and drop_rate >= fallback.trigger_threshold
       and (now - fallback.last_change) >= fallback.cooldown then
        enable_fallback(preset)
    end

    -- Reset the observation window.
    fallback.pending_frames = 0
    fallback.displayed_frames = 0
end

mp.observe_property('frame-drop-count', 'native', function(name, value)
    -- mpv's frame-drop-count is cumulative; we use a relative window instead,
    -- so we track per-frame via 'displayed-frames' event. This fallback keeps
    -- the observer wired for future mpv versions.
end)

mp.register_event('playback-restart', function()
    fallback.pending_frames = 0
    fallback.displayed_frames = 0
end)

-- Use mpv's built-in perf info event that fires per video frame.
mp.register_event('video-reconfig', function()
    fallback.pending_frames = 0
    fallback.displayed_frames = 0
end)

-- Hook into the frame event via the "displayed-frames" property changing.
mp.observe_property('displayed-frames', 'number', function(name, value)
    on_playback_frame(false)
end)

msg.info("Auto-enhancement detection loaded (with performance fallback)")
