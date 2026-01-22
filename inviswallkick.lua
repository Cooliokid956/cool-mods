function swap(m, action)
    print(m.action .. " -> " .. action)
    if action == 16910512 and m.action ~= 2215 then
        m.wallKickTimer = 5
        print("corrected")
        return 2215
    end
end
function nilfloor(m)
if m.playerIndex ~= 0 then return end
    if m.floor == nil then
        print("nil floor!")
    end
    
end
hook_event(HOOK_BEFORE_MARIO_UPDATE,nilfloor)
hook_event(HOOK_MARIO_UPDATE,nilfloor)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,swap)