
local range = 12288
hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if m.input & INPUT_NONZERO_ANALOG ~= 0 then
        local t = m.marioObj.oTimer/50
        local angle = atan2s(m.controller.stickY, m.controller.stickX)
        local woowoo = math.sin(2 * t) + math.sin(math.pi * t)
        m.intendedYaw = m.intendedYaw + woowoo*range
        m.controller.stickX = m.controller.stickMag * sins(angle+woowoo*range)
        m.controller.stickY = m.controller.stickMag * coss(angle+woowoo*range)
    end
end)
function on_get_command(msg)
    if not network_is_server() then
        djui_chat_message_create("You need to be the host!")
        return true
    end

    djui_chat_message_create(tostring(get_environment_region(1)))
    djui_chat_message_create(tostring(get_environment_region(2)))
    return true
end

function on_set_command(msg)
    if not network_is_server() then
        djui_chat_message_create("You need to be the host!")
        return true
    end

    local num = tonumber(msg)
    set_environment_region(1, num)
    set_environment_region(2, num)
    return true
end

hook_chat_command("waterset", "to set the first two water levels", on_set_command)
hook_chat_command("waterget", "to get the first two water levels", on_get_command)