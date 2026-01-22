gSquashStates = {}

local DEFAULT_DAMPING = .7
local DEFAULT_TENSION = .3

for i = 0, MAX_PLAYERS-1 do
    gSquashStates[i] = {
        y = 160,
        yVel = 0,
        damping = DEFAULT_DAMPING,
        tension = DEFAULT_TENSION
    }
end

hook_event(HOOK_ON_LEVEL_INIT, function ()
    for i = 0, MAX_PLAYERS-1 do
        gSquashStates[i].y = gMarioStates[i].pos.y + 160
    end
end)

---@param m MarioState
hook_event(HOOK_MARIO_UPDATE, function (m)
    if not m.marioObj
    or not is_player_in_local_area(m) then return end
    local s = gSquashStates[m.playerIndex]

    s.damping = approach_f32_asymptotic(s.damping, DEFAULT_DAMPING, .1)
    s.tension = approach_f32_asymptotic(s.tension, DEFAULT_TENSION, .1)

    s.yVel = (s.yVel + (m.pos.y + 160 - s.y) * s.tension) * s.damping
    s.y = math.max(s.y + s.yVel, m.pos.y + 10)
    local scaleY = (s.y - m.pos.y) / 160
    m.marioObj.header.gfx.scale.y = scaleY
end)

hook_event(HOOK_ON_SET_MARIO_ACTION, function (m)
    if m.action == ACT_GROUND_POUND_LAND then
        local s = gSquashStates[m.playerIndex]
        s.damping = 1
        s.tension = .1
    end
end)

hook_chat_command("setdamping", "to set damping", function (x)
    DEFAULT_DAMPING = tonumber(x) or DEFAULT_DAMPING
    return true
end)

hook_chat_command("settension", "to set tension", function (x)
    DEFAULT_TENSION = tonumber(x) or DEFAULT_TENSION
    return true
end)

hook_event(HOOK_ON_HUD_RENDER, function ()
    local s = gSquashStates[0]
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_print_text("Squash state for player 0", 0, 0, 1)
    djui_hud_print_text("Damping: "..s.damping, 0, 32, 1)
    djui_hud_print_text("Tension: "..s.tension, 0, 64, 1)
end)