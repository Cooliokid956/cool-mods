local playing
local music = audio_stream_load("16_Unknown_1.ogg")
audio_stream_set_looping(music, false)
function update_music()
    local act = obj_get_first_with_behavior_id(id_bhvActSelector)
    if act then
        if not playing then
            audio_stream_play(music, true, 1)
            playing = true
        end
        stop_background_music(0x0D)
    else
        playing = false
        audio_stream_stop(music)
    end
end
hook_event(HOOK_UPDATE, update_music)