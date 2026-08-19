local sequence_status = -1
local speen = audio_stream_load("S1_A8.ogg")

local sequence_timer = 0
local colorintensity = 0

hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex == 0 and m.health - 0x40*m.hurtCounter < 0x100 and sequence_status == -1 then
        sequence_status = 0
        audio_stream_play(speen, true, 1)
        camera_freeze()
        enable_time_stop_including_mario()
    end

    if sequence_status == -1 or m.playerIndex ~= 0 then return end
    if sequence_timer == 0 then
        djui_chat_message_create("new color")
        if sequence_status == 0 then
            play_transition(WARP_TRANSITION_FADE_INTO_COLOR, 5, 20,60,255)
        elseif sequence_status == 1 then
            colorintensity = 20
            play_transition(WARP_TRANSITION_FADE_INTO_COLOR, 5, 60,100,255)
        elseif sequence_status == 2 then
            colorintensity = 60
            play_transition(WARP_TRANSITION_FADE_INTO_COLOR, 5, 130,170,255)
        elseif sequence_status == 3 then
            colorintensity = 130
            play_transition(WARP_TRANSITION_FADE_INTO_COLOR, 5, 255,255,255)
        elseif sequence_status == 6 then
            level_trigger_warp(m, WARP_OP_DEATH)
            camera_unfreeze()
            sequence_status = -1
        return end
    end

    sequence_timer = sequence_timer + 1
    if sequence_timer == 10 then
        sequence_timer = 0
        sequence_status = sequence_status + 1
    end
    djui_chat_message_create("status: "..sequence_status)
    djui_chat_message_create("timer: "..sequence_timer)
end)

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    djui_hud_set_resolution(RESOLUTION_N64)
    if sequence_status > 0 then
        djui_hud_set_color(colorintensity, colorintensity, 255, 255)
        djui_hud_render_rect(0, 0, 65535, 240)
    end
end)