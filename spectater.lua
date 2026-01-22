local specplayer = 0

function camupdate(m)
if m.playerIndex == 0 then
    gLakituState.yaw = gMarioStates[specplayer].area.camera.yaw
    vec3f_copy(gLakituState.curFocus,gMarioStates[specplayer].area.camera.focus)
    vec3f_copy(m.area.camera.focus,gMarioStates[specplayer].area.camera.focus)
    vec3f_copy(gLakituState.pos,gMarioStates[specplayer].area.camera.pos)
    print("Player " .. specplayer .. ": " .. gMarioStates[specplayer].area.camera.pos.x .. ", " .. gMarioStates[specplayer].area.camera.pos.y .. ", " .. gMarioStates[specplayer].area.camera.pos.z)
end
end
function setplayer(msg)
    if tonumber(msg) ~= fail and tonumber(msg) >= 0 and tonumber(msg) <= 15 then
        specplayer = math.floor(tonumber(msg))
    end
    djui_chat_message_create("Following Player #" .. msg .. "!")
    return true
end
hook_event(HOOK_MARIO_UPDATE,camupdate)
hook_chat_command("spectate","to spectate a player (0 to reset)",setplayer)