local lastangle
local apply = false
---@params m MarioState
function stoprot(m)
    if m.playerIndex ~= 0 then return end
    if analog_stick_held_back(m) == 1 and m.action == ACT_LONG_JUMP then
        apply = true
    end
    if apply and (m.action == ACT_LONG_JUMP or m.prevAction == ACT_LONG_JUMP) then
        m.faceAngle.y = lastangle
    else
        lastangle = m.faceAngle.y
        apply = false
    end
end
function stopspin(m,action)
    if action == 1090521221 and m.action == ACT_LONG_JUMP then
        return 1
    end
end
hook_event(HOOK_MARIO_UPDATE,stoprot)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,stopspin)