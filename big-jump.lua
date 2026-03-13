-- name: Big Jump

local lastYVel = {}
hook_event(HOOK_ON_SET_MARIO_ACTION, function (m)
    if m.prevAction & ACT_FLAG_AIR == 0 and lastYVel[m.playerIndex] then
        if m.vel.y > lastYVel[m.playerIndex] then
            m.vel.y = m.vel.y * 10
        end
    end
    lastYVel[m.playerIndex] = m.vel.y
end)