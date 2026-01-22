
local commands = {
    {"set", "tempo"},
    {"set", "tempo_acc"},
    {"set", "transposition"},
    {"get", "tempo"},
    {"get", "tempo_acc"},
    {"get", "transposition"}
}
local seqPlayer = 0
for i, c in ipairs(commands) do
    local name = c[1].."_"..c[2]
    hook_chat_command(name, " ", function (msg)
        local func = _G["sequence_player_"..name]
        local val = tonumber(msg)
        if c[1] == "set" then func(seqPlayer, val)
        else djui_chat_message_create(""..func(seqPlayer)) end
        return true
    end)
end

hook_chat_command("set_player", " ", function (msg)
    seqPlayer = tonumber(msg) or 0
    return true
end)

hook_event(HOOK_ON_HUD_RENDER, function ()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)
    local x = djui_hud_get_mouse_x()
    local y = djui_hud_get_mouse_y()

    djui_hud_print_text("player:        "..seqPlayer, x, y+64*0, 2)
    djui_hud_print_text("tempo:         "..sequence_player_get_tempo(seqPlayer), x, y+64*1, 2)
    djui_hud_print_text("tempo acc:     "..sequence_player_get_tempo_acc(seqPlayer), x, y+64*2, 2)
    djui_hud_print_text("transposition: "..sequence_player_get_transposition(seqPlayer), x, y+64*3, 2)

    local val = (14360-sequence_player_get_tempo_acc(seqPlayer))/14360
    val = val ^ 4
    djui_hud_render_rect(x-24, y+16, 16, (val)*(256-24))
end)

-- 14360 = max tempo
local lastAcc = 0
-- hook_event(HOOK_UPDATE, function ()
--     local new = sequence_player_get_tempo_acc(seqPlayer)
--     if last < new then last = new
--     else djui_chat_message_create(""..last) end
-- end)
local lastTempo = 0

local tatums = 0
hook_event(HOOK_UPDATE, function ()
    -- local newAcc = sequence_player_get_tempo_acc(seqPlayer)
    -- if lastAcc < newAcc then djui_chat_message_create("tatum") end
    -- lastAcc = newAcc

    local newTempo = sequence_player_get_tempo(seqPlayer)
    if lastTempo < newTempo then djui_chat_message_create("new tempo: ".. newTempo) end
    lastTempo = newTempo
end)