-- ============================================
-- NJ PLAYER 3.0 — PRESET SWITCHING
-- ============================================

local mp = require 'mp'
local msg = require 'mp.msg'

-- Preset definitions
local presets = {
    { name = "off",     key = "CTRL+0", description = "Clean playback" },
    { name = "lucid",   key = "CTRL+1", description = "Adaptive sharpening" },
    { name = "cinema",  key = "CTRL+2", description = "Full pipeline" },
    { name = "anime",   key = "CTRL+3", description = "Anime4K restoration" },
    { name = "hdr",     key = "CTRL+4", description = "HDR tone mapping" },
    { name = "denoise", key = "CTRL+5", description = "Skin-preserving denoise" },
    { name = "motion",  key = "CTRL+6", description = "Motion interpolation" },
    { name = "auto",    key = "CTRL+7", description = "Auto detection" },
    { name = "compare", key = "CTRL+8", description = "Split-screen compare" },
    { name = "restore", key = "CTRL+9", description = "Full restoration" },
}

local current_preset = 0

-- Apply preset by name
local function apply_preset(name)
    local preset_number = nil

    for i, preset in ipairs(presets) do
        if preset.name == name then
            preset_number = i - 1  -- 0-indexed
            break
        end
    end

    if preset_number == nil then
        msg.warn("Unknown preset: " .. name)
        return
    end

    -- Apply the profile
    mp.commandv('apply-profile', 'nj-' .. name)

    current_preset = preset_number

    -- Show OSD message
    local preset = presets[preset_number + 1]
    mp.osd_message(
        string.format("%s Mode\n%s",
            preset.name:upper(),
            preset.description
        ), 2
    )

    msg.info("Applied preset: " .. preset.name)
end

-- Cycle to next preset
local function cycle_preset()
    current_preset = (current_preset % #presets) + 1
    local preset = presets[current_preset]
    apply_preset(preset.name)
end

-- Handle preset messages
mp.register_script_message('nj-preset', function(name)
    apply_preset(name)
end)

mp.register_script_message('nj-cycle', function()
    cycle_preset()
end)

-- Register key bindings
for i, preset in ipairs(presets) do
    mp.add_key_binding(preset.key, 'nj-' .. preset.name, function()
        apply_preset(preset.name)
    end)
end

mp.add_key_binding('F9', 'nj-cycle', cycle_preset)

-- Show current preset on startup
mp.register_event('file-loaded', function()
    local preset = presets[current_preset + 1]
    if preset then
        mp.osd_message(
            string.format("NJ Player — %s Mode", preset.name:upper()),
            1.5
        )
    end
end)

msg.info("NJ Player preset system loaded")
