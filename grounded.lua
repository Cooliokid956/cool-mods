function grounded(m)
if m.playerIndex ~= 0 then return end
    if m.input & INPUT_OFF_FLOOR ~= 0 then
        print("airborne")
    else
        print("on floor")
    end
end
hook_event(HOOK_MARIO_UPDATE,grounded)