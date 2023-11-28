--! \brief    Fast-forward on demand.
--! \details  This script allows the user to fast-forward when pressing the key, which is
--!           something like pressing the right arrow key in iQIYI.
--! \usage    Press to fast-forward. Release to restore.
--! \configs  Place custom configs in `script-opts/fast-forward.conf` :
--!           Example:
--!               key=ctrl+right
--!               speed=2.0
--!           Default configs: see below.
--! \author   Purple4pur
--! \website  https://github.com/purple4pur/mpv-scripts
--! \version  0.1.0
--! \license  MIT

-- default configs
local opt = {
    key = "END", -- key binding
    speed = 3.0, -- fast-forward speed
}
require("mp.options").read_options(opt, "fast-forward")

-- checks on speed setting
local msg = require("mp.msg")
if opt.speed <= 0.0 then
    msg.error("invalid speed setting: " .. opt.speed)
    opt.speed = 3.0
elseif opt.speed < 1.0 then
    msg.warn("fast-forward speed (" .. opt.speed .. ") is slower than 1.0")
end

-- main function
local normal_speed = 1.0
local ffing = false
function fast_forward(params)
    if params.event == "down" then
        -- record current playback speed
        normal_speed = mp.get_property_native("speed")
        ffing = false

    elseif params.event == "repeat" then
        -- set to fast-forward speed
        if not ffing then
            mp.set_property_native("speed", opt.speed)
            mp.osd_message("Fast-forwarding >>>")
            ffing = true
        end

    elseif params.event == "up" then
        -- reset to normal speed
        mp.set_property_native("speed", normal_speed)
        ffing = false
    end
end

-- apply key binding
mp.add_forced_key_binding(opt.key, "fast-forward", fast_forward, {complex = true})
