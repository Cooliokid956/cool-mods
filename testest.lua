function before(m)
    if m.playerIndex ~= 0 then return end
    print("Before pos: " .. m.pos.x .. ", " .. m.pos.y .. ", " .. m.pos.z)
end
function after(m)
    if m.playerIndex ~= 0 then return end
    print("After pos: " .. m.pos.x .. ", " .. m.pos.y .. ", " .. m.pos.z)
end
hook_event(HOOK_BEFORE_MARIO_UPDATE,before)
hook_event(HOOK_MARIO_UPDATE,after)