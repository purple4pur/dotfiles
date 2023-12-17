--! \brief    Fast-forward on demand.
--! \details  This script allows the user to fast-forward when pressing the key, which is
--!           something like pressing the right arrow key in iQIYI.
--! \usage    Press to fast-forward. Release to restore.
--! \configs  Place custom configs in `script-opts/fast-forward.conf` :
--!           Example:
--!               key=ctrl+right
--!               speed=2.0
--!               autospeed=off
--!           Default configs: see below.
--! \author   Purple4pur
--! \website  https://github.com/purple4pur/mpv-scripts
--! \version  0.2.0
--! \license  MIT

-- default configs
local opt = {
    key = "END",              -- key binding
    speed = 3.0,              -- fixed fast-forward speed (ignored in autospeed mode)

    -- autospeed mode: automatically change ff-speed based on current speed
    autospeed = "on",         -- available values: on, off
    autospeed_adjuster = 2.5, -- multiplier applied to current speed
    autospeed_max = 4.0,      -- maximum value of ff-speed in autospeed mode
}
require("mp.options").read_options(opt, "fast-forward") -- read configs from `fast-forward.conf`

-- checks on settings
--{{{
local msg = require("mp.msg")
if opt.autospeed ~= "on" and opt.autospeed ~= "off" then
    msg.error("invalid autospeed setting: " .. opt.autospeed .. ". Restore to default value (on)")
    opt.autospeed = "on"
end

if opt.autospeed == "on" then
    -- autospeed mode settings
    msg.info("using autospeed mode")
    if opt.autospeed_adjuster <= 0.0 then
        msg.error("invalid autospeed_adjuster setting: " .. opt.autospeed_adjuster)
        opt.autospeed_adjuster = 2.5
    elseif opt.autospeed_adjuster <= 1.0 then
        msg.warn("autospeed_adjuster (" .. opt.autospeed_adjuster .. ") is not greater than 1.0")
    end

    if opt.autospeed_max <= 1.0 then
        msg.warn("autospeed_max (" .. opt.autospeed_max .. ") is not greater than 1.0")
    end
else
    -- fixed speed mode settings
    msg.info("using fixed speed mode")
    if opt.speed <= 0.0 then
        msg.error("invalid speed setting: " .. opt.speed)
        opt.speed = 3.0
    elseif opt.speed <= 1.0 then
        msg.warn("fixed fast-forward speed (" .. opt.speed .. ") is not greater than 1.0")
    end
end
--}}}

-- main function
local normal_speed = 1.0
local ffing = false
function fast_forward(params)
    --{{{
    if params.event == "down" then
        -- record current playback speed
        normal_speed = mp.get_property_native("speed")
        ffing = false

    elseif params.event == "repeat" then
        -- set to fast-forward speed
        if not ffing then
            local ffspeed = opt.speed
            if opt.autospeed == "on" then
                ffspeed = normal_speed * opt.autospeed_adjuster
                if ffspeed > opt.autospeed_max then
                    ffspeed = opt.autospeed_max
                end
            end

            mp.set_property_native("speed", ffspeed)
            mp.osd_message(string.format("Fast-forwarding (%.1fx) >>>>", ffspeed))
            ffing = true
        end

    elseif params.event == "up" then
        -- reset to normal speed
        mp.set_property_native("speed", normal_speed)
        mp.osd_message(string.format("Normal playback (%.1fx) >", normal_speed))
        ffing = false
    end
    --}}}
end

-- apply key binding
mp.add_forced_key_binding(opt.key, "fast-forward", fast_forward, {complex = true})
