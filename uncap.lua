local fvel = 0
function before(m)
    fvel = m.forwardVel
end

function after(m)
    if m.action == ACT_WALKING then
        m.forwardVel = fvel
    end
end
hook_event(HOOK_BEFORE_MARIO_UPDATE, before)
hook_event(HOOK_BEFORE_PHYS_STEP, after)