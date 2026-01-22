-- name: Forwards Long Jump
-- description: Allows performing the BLJ in both directions

gPlayerSyncTable[0].enabled = true

local sign
function store(m, action)
    if gPlayerSyncTable[m.playerIndex].enabled and action == ACT_LONG_JUMP then
        sign = signum_positive(m.forwardVel)
        m.forwardVel = m.forwardVel * -sign
    end
end
function set(m)
    if gPlayerSyncTable[m.playerIndex].enabled and m.action == ACT_LONG_JUMP and sign then
        m.forwardVel = m.forwardVel * -sign
        sign = nil
    end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, store)
hook_event(HOOK_ON_SET_MARIO_ACTION, set)

hook_chat_command("flj", "to toggle", function ()
    gPlayerSyncTable[0].enabled = not gPlayerSyncTable[0].enabled
    djui_chat_message_create("The forwards long jump is "..(gPlayerSyncTable[0].enabled and "on." or "off."))
    return true
end)
