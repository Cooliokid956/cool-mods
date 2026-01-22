local mul = 1
hook_event(HOOK_BEFORE_PHYS_STEP, function (m)
    vec3f_mul(m.vel, mul)
end)
hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex == 0 then
        vec3f_mul(m.vel, 1/mul)
    end
end)
hook_chat_command("mul", "to mul", function (msg)
    mul = tonumber(msg)
end)