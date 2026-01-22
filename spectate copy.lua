local specplayer = 0

function camupdate(m)
if m.playerIndex == specplayer then
    gLakituState.yaw = m.area.camera.yaw
    vec3f_copy(gLakituState.curFocus, m.area.camera.focus)
    vec3f_copy(m.area.camera.focus, m.area.camera.focus)
    vec3f_copy(gLakituState.pos, m.area.camera.pos)
    print("Player " .. specplayer .. ": " .. m.area.camera.pos.x .. ", " .. m.area.camera.pos.y .. ", " .. m.area.camera.pos.z)
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