local bright = 255
local amb
-- hook_event(HOOK_UPDATE, function ()
--     set_lighting_dir(2, -127)
--     set_lighting_color(0, bright)
--     set_lighting_color(1, bright)
--     set_lighting_color(2, bright)
--     set_lighting_color_ambient(0, amb)
--     set_lighting_color_ambient(1, amb)
--     set_lighting_color_ambient(2, amb)
-- end)

hook_chat_command("setbr", "ightness", function (msg)
    bright = tonumber(msg) or 255
    return true
end)

hook_chat_command("setamb", "ient", function (msg)
    amb = tonumber(msg) or 255
    return true
end)

---@param m MarioState
hook_event(HOOK_MARIO_UPDATE, function (m)
    local b = m.marioBodyState
    b.lightingDirZ = -127
    b.lightR = bright
    b.lightG = bright
    b.lightB = bright
    b.shadeR = amb
    b.shadeG = amb
    b.shadeB = amb
end)