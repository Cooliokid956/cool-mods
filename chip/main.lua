local channels = {}
function set_volume(self, vol)
    
end
function set_freq(self, hz)
    audio_stream_set_frequency(self.audio, hz*48000)
end
function get_freq(self)
    audio_stream_get_frequency(self.audio)
end
function power(self, onoff)
    if self.powered and not onoff then
        audio_stream_pause(self.audio)
    elseif not self.powered and onoff then
        audio_stream_play(self.audio, true, self.volume)
    end
end
function square()
    local channel = {
        audio = audio_stream_load("sqr.ogg"),
        powered = false,
        volume = 1,
        set_volume = set_volume,
        set_freq = set_freq,
        get_freq = get_freq,
        power = power
    }
    audio_stream_set_looping(channel.audio, true)
    table.insert(channels, channel)
    return channel
end
_G.chip = {
    create = {
        square = square
    }
}


local reserved
hook_chat_command("create", " ", function ()
    reserved = chip.create.square()
    return true
end)
hook_chat_command("get_freq", " ", function ()
    reserved:power(true)
    djui_chat_message_create(""..reserved:get_freq())
    return true
end)
hook_chat_command("set_freq", " ", function (msg)
    reserved:power(true)
    reserved:set_freq(tonumber(msg))
    return true
end)