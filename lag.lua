local num = 10000

function something()
    local a = 3
    local b = 5
    local c

    c = (b*b+a+a+a)^a*math.sqrt(a)+sqrf(33)

    return sqrf(sqrf(sqrf(sqrf(sqrf(c)))))
end

function lag()
    for i=0, num do something() end
end
hook_event(HOOK_UPDATE, lag)

hook_chat_command("lag", "[number]", function (msg)
    num = (tonumber(msg) or 0)*10000
    return true
end)

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        num = num + 1000
    end
end)