local sound = audio_stream_load("df.ogg")
sound.looping = true
local ogfreq
local played
local inc = 0
hook_event(HOOK_UPDATE, function ()
    if not played then played = true
        audio_stream_play(sound, false, 1)
        ogfreq = sound.frequency
    end
    inc = inc + gMarioStates[0].forwardVel/40
    sound.volume = 2 + coss(get_global_timer()*0x8000)/2
    sound.frequency = ogfreq + sins(inc*0x1000)*0.1
end)