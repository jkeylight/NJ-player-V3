-- ============================================
-- NJ PLAYER 3.0 — ZOOM & PAN CONTROLS
-- Essential for low-res video inspection
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Zoom state
local zoom_levels = {1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.0}
local current_zoom_index = 1
local pan_x = 0  -- -1 to 1 (0 = center)
local pan_y = 0  -- -1 to 1 (0 = center)

-- ============================================
-- ZOOM FUNCTIONS
-- ============================================
local function apply_zoom(zoom_factor)
    mp.set_property('video-zoom', zoom_factor)

    -- Reset pan when zooming
    mp.set_property('video-pan-x', 0)
    mp.set_property('video-pan-y', 0)
    pan_x = 0
    pan_y = 0

    -- Show zoom level
    if zoom_factor == 1.0 then
        mp.osd_message("Zoom: 100% (Original)", 1)
    else
        mp.osd_message(string.format("Zoom: %.0f%%", zoom_factor * 100), 1)
    end
end

local function cycle_zoom()
    current_zoom_index = (current_zoom_index % #zoom_levels) + 1
    apply_zoom(zoom_levels[current_zoom_index])
end

local function zoom_in()
    current_zoom_index = math.min(current_zoom_index + 1, #zoom_levels)
    apply_zoom(zoom_levels[current_zoom_index])
end

local function zoom_out()
    current_zoom_index = math.max(current_zoom_index - 1, 1)
    apply_zoom(zoom_levels[current_zoom_index])
end

local function reset_zoom()
    current_zoom_index = 1
    apply_zoom(1.0)
end

-- ============================================
-- PAN FUNCTIONS
-- ============================================
local function pan(dx, dy)
    local current_zoom = zoom_levels[current_zoom_index]

    -- Only allow panning when zoomed in
    if current_zoom <= 1.0 then
        mp.osd_message("Zoom in first to pan", 1)
        return
    end

    pan_x = math.max(-1, math.min(1, pan_x + dx))
    pan_y = math.max(-1, math.min(1, pan_y + dy))

    mp.set_property('video-pan-x', pan_x)
    mp.set_property('video-pan-y', pan_y)

    mp.osd_message(string.format("Pan: %.0f%%, %.0f%%", pan_x * 100, pan_y * 100), 0.5)
end

local function pan_left()
    pan(-0.1, 0)
end

local function pan_right()
    pan(0.1, 0)
end

local function pan_up()
    pan(0, -0.1)
end

local function pan_down()
    pan(0, 0.1)
end

-- ============================================
-- CROP BLACK BARS
-- ============================================
local function crop_black_bars()
    mp.commandv('vf', 'add', 'crop=0.05:0.05:0.05:0.05')
    mp.osd_message("Cropped black bars", 1)
end

-- ============================================
-- ROTATE
-- ============================================
local rotation = 0

local function rotate_video()
    rotation = (rotation + 90) % 360
    mp.set_property('video-params/rotate', rotation)
    mp.osd_message(string.format("Rotation: %d°", rotation), 1)
end

-- ============================================
-- FLIP
-- ============================================
local function flip_horizontal()
    local current = mp.get_property('video-params/mirrored', 'no')
    if current == 'yes' then
        mp.set_property('video-params/mirrored', 'no')
        mp.osd_message("Flip: Off", 1)
    else
        mp.set_property('video-params/mirrored', 'yes')
        mp.osd_message("Flip: Horizontal", 1)
    end
end

-- ============================================
-- SLOW MOTION
-- ============================================
local function toggle_slow_motion()
    local current_speed = mp.get_property_number('speed', 1.0)
    if current_speed == 0.5 then
        mp.set_property('speed', 1.0)
        mp.osd_message("Speed: Normal", 1)
    else
        mp.set_property('speed', 0.5)
        mp.osd_message("Speed: 0.5x (Slow Motion)", 1)
    end
end

-- ============================================
-- A-B LOOP
-- ============================================
local ab_loop_a = nil
local ab_loop_b = nil

local function toggle_ab_loop()
    local pos = mp.get_property_number('time-pos', 0)

    if ab_loop_a == nil then
        ab_loop_a = pos
        mp.osd_message(string.format("A-B Loop: A = %s", mp.format_time(pos)), 1)
    elseif ab_loop_b == nil then
        ab_loop_b = pos
        mp.set_property('ab-loop-a', ab_loop_a)
        mp.set_property('ab-loop-b', ab_loop_b)
        mp.osd_message(
            string.format("A-B Loop: %s → %s",
                mp.format_time(ab_loop_a),
                mp.format_time(ab_loop_b)
            ), 2
        )
    else
        -- Reset
        ab_loop_a = nil
        ab_loop_b = nil
        mp.set_property('ab-loop-a', 'no')
        mp.set_property('ab-loop-b', 'no')
        mp.osd_message("A-B Loop: Off", 1)
    end
end

-- ============================================
-- CLEAR RESUME POSITION
-- ============================================
local function clear_resume_position()
    mp.command('script-message/clear-watch-later-config')
    mp.osd_message("Resume position cleared", 1)
end

-- ============================================
-- KEY BINDINGS
-- ============================================
mp.add_key_binding('z', 'nj-zoom', cycle_zoom)
mp.add_key_binding('ALT+UP', 'nj-zoom-in', zoom_in)
mp.add_key_binding('ALT+DOWN', 'nj-zoom-out', zoom_out)
mp.add_key_binding('ALT+0', 'nj-zoom-reset', reset_zoom)
mp.add_key_binding('CTRL+LEFT', 'nj-pan-left', pan_left)
mp.add_key_binding('CTRL+RIGHT', 'nj-pan-right', pan_right)
mp.add_key_binding('CTRL+UP', 'nj-pan-up', pan_up)
mp.add_key_binding('CTRL+DOWN', 'nj-pan-down', pan_down)
mp.add_key_binding('c', 'nj-crop', crop_black_bars)
mp.add_key_binding('r', 'nj-rotate', rotate_video)
mp.add_key_binding('h', 'nj-flip-h', flip_horizontal)
mp.add_key_binding('s', 'nj-slow-motion', toggle_slow_motion)
mp.add_key_binding('l', 'nj-ab-loop', toggle_ab_loop)
mp.add_key_binding('CTRL+BACKSPACE', 'nj-clear-resume', clear_resume_position)

msg.info("Zoom & pan controls loaded")
