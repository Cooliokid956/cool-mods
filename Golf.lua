-- name: Golf

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if m.controller.stickMag > 1 then
        m.controller.stickMag = 1
    end
end)