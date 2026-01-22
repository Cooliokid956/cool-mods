hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function (m, action)
if action == ACT_AIR_HIT_WALL then
    if math.floor(m.pos.y) % 16 ~= 0 then
        return 1
    elseif m.input & INPUT_A_PRESSED ~= 0 then
--        m.faceAngle.y = m.faceAngle.y + 0x8000
        return ACT_JUMP
    end
end
end)