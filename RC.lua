gGlobalSyncTable.RC = true

function mario_update(m)
    if m.forwardVel > 5 and m.action & ACT_FLAG_AIR ~= 0 and gGlobalSyncTable.RC then
        m.faceAngle.y = atan2s(m.vel.z, m.vel.x)
    end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)

function on_RC_command(msg)
    gGlobalSyncTable.RC = not gGlobalSyncTable.RC
    if gGlobalSyncTable.RC then
        djui_chat_message_create("RC On")
    else
        djui_chat_message_create("RC Off")
    end
    return true
end


if network_is_server() then
    hook_chat_command("RC", "to turn responsive controls on or off", on_RC_command)
end