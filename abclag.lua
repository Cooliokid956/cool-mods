-- name: A Button Challenge: Lag Edition
local num = 0
local lpa = 1000

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

hook_chat_command("reset", "lag", function ()
    num = 0
    return true
end)
hook_chat_command("lpa", "(Lag per A Press, default 1)", function (msg)
    lpa = (tonumber(msg) or 0)*1000
    return true
end)

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        num = num + lpa
    end
end)