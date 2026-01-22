-- name: Multiplier
-- description: For the keyboard players!! Tiptoe past those piranha plants by setting your control-stick\nmagnitude multiplier using \n\n/mag [0.0.. to 1.0..]\n\nor adjusting it using D-Pad Up/Down.\n\nalso rapid fire because why not

local mag = 1
local magoffset = 0
local rapid = false
local unsafe = false

function setmag(msg)
    if tonumber(msg) ~= fail and tonumber(msg) >= 0 and tonumber(msg) <= 63 then
        mag = msg
        djui_chat_message_create("Multiplier set to " .. tostring(mag) .. ".")
    else
        djui_chat_message_create("Try a number between 0 and 63.")
    end
    return true
end
---@param m MarioState
function beforeMario(m)
    if m.playerIndex ~= 0 then return end
    if m.controller.buttonDown & U_JPAD ~= 0 then
        magoffset = magoffset + 1
        print("up")
    end
    if m.controller.buttonDown & D_JPAD ~= 0 then
        magoffset = magoffset - 1
        print("down")
    end
    if m.controller.stickMag == 0 then
        magoffset = 0
    end
    m.controller.stickMag = (m.controller.stickMag + magoffset) * mag
    local stickAng = atan2s(m.controller.stickY, m.controller.stickX)
    m.controller.stickX = (m.controller.stickX + magoffset*sins(stickAng)) * mag
    m.controller.stickY = (m.controller.stickY + magoffset*coss(stickAng)) * mag
    m.controller.rawStickX = (m.controller.rawStickX + magoffset*sins(stickAng)) * mag
    m.controller.rawStickY = (m.controller.rawStickY + magoffset*coss(stickAng)) * mag
    if m.controller.buttonDown & A_BUTTON ~= 0 and rapid then
        m.controller.buttonPressed = m.controller.buttonPressed | A_BUTTON
    end
    if m.controller.buttonDown & B_BUTTON ~= 0 and rapid then
        m.controller.buttonPressed = m.controller.buttonPressed | B_BUTTON
    end
end

function togglerapid()
    rapid = not rapid
    return true
end

function toggleunsafe()
    unsafe = not unsafe
    return true
end

if network_is_server() then
    hook_chat_command('unsafe', "to enter/exit unsafe mode (SERVER SETTING)", toggleunsafe)
end
hook_chat_command('mag', "[0-1] to set magnitude, [0-63] if in unsafe mode", setmag)
hook_chat_command('rapid', "to toggle rapid fire", togglerapid)
hook_event(HOOK_BEFORE_MARIO_UPDATE, beforeMario)