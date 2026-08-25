-- ============================================
-- NJ PLAYER 3.0 — COMPARE MODE
-- Split-screen original vs enhanced
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

local compare_enabled = false
local split_position = 50  -- percentage (0-100)
local current_preset = "cinema"

-- ============================================
-- ENABLE COMPARE MODE
-- ============================================
local function enable_compare()
    if compare_enabled then return end

    compare_enabled = true

    -- Store current preset
    local profile = mp.get_property('profile', '')
    if profile and profile ~= '' then
        current_preset = profile:gsub('nj%-', '')
    end

    -- Create split filter
    mp.commandv('vf', 'add', string.format(
        '@compare:lavfi=[split[a][b];' ..
        '[a]null[enhanced];' ..
        '[b]null[original]'
    ))

    -- Left side: Enhanced (current shaders)
    mp.commandv('vf', 'add', string.format(
        '@left:crop=iw*%d/100:ih:0:0',
        split_position
    ))

    -- Right side: Original (no shaders)
    mp.commandv('vf', 'add', string.format(
        '@right:crop=iw*(100-%d)/100:ih:iw*%d/100:0',
        split_position, split_position
    ))

    mp.osd_message(
        string.format(
            "{\\fscx120\\fscy120\\bord2\\1c&H00d4ff&}COMPARE MODE{\\rDefault}\n" ..
            "Left: Enhanced  |  Right: Original\n" ..
            "Drag divider with mouse or use ←→ keys"
        ),
        3
    )
end

-- ============================================
-- DISABLE COMPARE MODE
-- ============================================
local function disable_compare()
    if not compare_enabled then return end

    compare_enabled = false

    -- Remove compare filters
    mp.command('vf remove @right')
    mp.command('vf remove @left')
    mp.command('vf remove @compare')

    mp.osd_message("Compare Mode: Off", 1)
end

-- ============================================
-- TOGGLE COMPARE MODE
-- ============================================
local function toggle_compare()
    if compare_enabled then
        disable_compare()
    else
        enable_compare()
    end
end

-- ============================================
-- ADJUST SPLIT POSITION
-- ============================================
local function move_split(delta)
    if not compare_enabled then return end

    split_position = math.max(10, math.min(90, split_position + delta))

    -- Update crop filters
    mp.commandv('vf', 'remove', '@left')
    mp.commandv('vf', 'remove', '@right')

    mp.commandv('vf', 'add', string.format(
        '@left:crop=iw*%d/100:ih:0:0',
        split_position
    ))

    mp.commandv('vf', 'add', string.format(
        '@right:crop=iw*(100-%d)/100:ih:iw*%d/100:0',
        split_position, split_position
    ))

    mp.osd_message(string.format("Split: %d%%", split_position), 0.5)
end

-- ============================================
-- KEY BINDINGS
-- ============================================
mp.add_key_binding('CTRL+8', 'nj-compare-toggle', toggle_compare)
mp.add_key_binding('ALT+LEFT', 'nj-split-left', function() move_split(-5) end)
mp.add_key_binding('ALT+RIGHT', 'nj-split-right', function() move_split(5) end)

-- ============================================
-- RESET ON FILE CHANGE
-- ============================================
mp.register_event('file-loaded', function()
    if compare_enabled then
        disable_compare()
    end
    split_position = 50
end)

msg.info("Compare mode loaded")
