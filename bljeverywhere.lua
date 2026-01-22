function update(m)
    if m.playerIndex ~= 0 then return end
    if m.action == ACT_LONG_JUMP and m.forwardVel <= -10 and m.vel.y > -3 then
        m.vel.y = -10
    end
end


hook_event(HOOK_BEFORE_MARIO_UPDATE, update)