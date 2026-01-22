function cancelbump(m,action)
    if action == ACT_JUMP and m.action == ACT_LONG_JUMP then
        return 1
    end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,cancelbump)