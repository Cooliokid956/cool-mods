local ttsqueue = {}
local speed = 157
local pitch = 140
local voice = "Adult Male #1, American English (TruVoice)"

function onchat(m,msg)
    table.insert( ttsqueue, { s = audio_stream_load_url("https://www.tetyys.com/SAPI4/SAPI4?/SAPI4/SAPI4?text=" .. msg .. "&voice=" .. voice .. "&pitch=" .. pitch .. "&speed=" .. speed), c=0 } )
    --table.insert( ttsqueue, { s = audio_stream_load_url("http://sm64ts.cf/"..msg..".mp3"), c=0 } )
end

function trackaudio()
    for i, audio in pairs(ttsqueue) do
        if audio.s.loaded and audio.c==0 then
            audio_stream_play(audio.s,false,1)
            print("sound played")
            audio.c = 1
        else
            audio.c = audio.c + 1
        end
        if audio.c > 1000 then
            table.remove(ttsqueue,i)
        end
    end
end
hook_event(HOOK_UPDATE,trackaudio)
hook_event(HOOK_ON_CHAT_MESSAGE,onchat)