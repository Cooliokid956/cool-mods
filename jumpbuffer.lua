---@param m MarioState
hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if m.prevAction & ACT_FLAG_AIR ~= 0 and m.action & ACT_FLAG_AIR == 0 and m.framesSinceA < 8 then
        m.controller.buttonPressed = m.controller.buttonPressed | A_BUTTON
        m.framesSinceA = 8
    end
end)