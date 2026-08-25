-- ============================================
-- NJ PLAYER 3.0 — PERFORMANCE MONITOR
-- Real-time GPU/CPU stats display
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Monitor state
local monitor_visible = false
local monitor_timer = nil

-- ============================================
-- GET VIDEO STATS
-- ============================================
local function get_video_stats()
    local stats = {}

    -- Resolution
    local width = mp.get_property_number('width', 0)
    local height = mp.get_property_number('height', 0)
    stats.resolution = string.format("%dx%d", width, height)

    -- FPS
    stats.fps = mp.get_property_number('container-fps', 0)
    stats.current_fps = mp.get_property_number('estimated-fps', 0)

    -- Bitrate
    local bitrate = mp.get_property_number('video-bitrate', 0)
    if bitrate > 1000 then
        stats.bitrate = string.format("%.1f Mbps", bitrate / 1000)
    else
        stats.bitrate = string.format("%.0f kbps", bitrate)
    end

    -- Codec
    stats.codec = mp.get_property('video-codec', 'Unknown')

    -- HW decode
    stats.hwdec = mp.get_property('hwdec-current', 'None')

    -- Drop frames
    stats.dropped = mp.get_property_number('drop-frame-count', 0)

    -- Time
    local time_pos = mp.get_property_number('time-pos', 0)
    local duration = mp.get_property_number('duration', 0)
    stats.time = string.format("%s / %s",
        mp.format_time(time_pos),
        mp.format_time(duration)
    )

    -- Audio
    stats.audio_codec = mp.get_property('audio-codec', 'None')
    stats.audio_channels = mp.get_property('audio-params/channel-count', 0)
    stats.audio_samplerate = mp.get_property('audio-params/samplerate', 0)

    return stats
end

-- ============================================
-- SHOW PERFORMANCE MONITOR
-- ============================================
local function show_monitor()
    local stats = get_video_stats()

    local monitor_text = string.format(
        "{\\fscx110\\fscy110\\bord2\\1c&H00d4ff&}PERFORMANCE MONITOR{\\rDefault}\n\n" ..
        "{\\1c&Hb0b0c0&}VIDEO{\\rDefault}\n" ..
        "  Resolution: {\\1c&Hffffff&}%s{\\rDefault}\n" ..
        "  Codec: {\\1c&Hffffff&}%s{\\rDefault}\n" ..
        "  FPS: {\\1c&Hffffff&}%.1f{\\rDefault} (target: %.1f)\n" ..
        "  Bitrate: {\\1c&Hffffff&}%s{\\rDefault}\n" ..
        "  HW Decode: {\\1c&Hffffff&}%s{\\rDefault}\n" ..
        "  Dropped: {\\1c&Hffffff&}%d{\\rDefault}\n\n" ..
        "{\\1c&Hb0b0c0&}AUDIO{\\rDefault}\n" ..
        "  Codec: {\\1c&Hffffff&}%s{\\rDefault}\n" ..
        "  Channels: {\\1c&Hffffff&}%d{\\rDefault}\n" ..
        "  Sample Rate: {\\1c&Hffffff&}%d Hz{\\rDefault}\n\n" ..
        "{\\1c&Hb0b0c0&}TIME{\\rDefault}\n" ..
        "  {\\1c&Hffffff&}%s{\\rDefault}",
        stats.resolution,
        stats.codec,
        stats.current_fps, stats.fps,
        stats.bitrate,
        stats.hwdec,
        stats.dropped,
        stats.audio_codec,
        stats.audio_channels,
        stats.audio_samplerate,
        stats.time
    )

    mp.osd_message(monitor_text, 3)
end

-- ============================================
-- TOGGLE MONITOR
-- ============================================
local function toggle_monitor()
    monitor_visible = not monitor_visible

    if monitor_visible then
        show_monitor()
        -- Auto-refresh every 2 seconds
        monitor_timer = mp.add_periodic_timer(2, function()
            if monitor_visible then
                show_monitor()
            end
        end)
    else
        if monitor_timer then
            monitor_timer:kill()
            monitor_timer = nil
        end
        mp.osd_message("", 0.1)
    end
end

-- ============================================
-- KEY BINDINGS
-- ============================================
mp.add_key_binding('CTRL+SHIFT+P', 'nj-perf-monitor', toggle_monitor)

-- ============================================
-- STOP MONITOR ON FILE CHANGE
-- ============================================
mp.register_event('file-loaded', function()
    if monitor_visible then
        monitor_visible = false
        if monitor_timer then
            monitor_timer:kill()
            monitor_timer = nil
        end
    end
end)

msg.info("Performance monitor loaded")
