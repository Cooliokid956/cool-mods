-- local sound = audio_stream_load("sine.ogg")
-- local sound = audio_stream_load("Ring05.ogg")
-- local sound = audio_stream_load("sine10hz41.ogg")
-- local sound = audio_stream_load("saw10hz41.ogg")
-- local sound = audio_stream_load("saw100hz48.ogg")
-- local sound = audio_stream_load("saw10hz48.ogg")
local sound = audio_load("saw10hz16.ogg")
local hz = 10
local voices

function note2freq(x) return 440*2^((x+0.1)/12) end -- rel to A4

local notes = {
    -43, -31, -24, -19, -12, -- low(2v)
    -7, 0, 5, 12, 17, 21, -- high (3v)
}

local x = 0
local t = 0

local tBEG = 7*30
local tDUR = 6*30
local tEND = tDUR + tBEG
local tHOLD= 5*30
local tCUT = tHOLD + tEND
local vBEG, vMID, vEND = 0.001, 0.01, 0.1

local ig = 4
hook_event(HOOK_UPDATE, function ()
    if ig > 0 then ig = ig - 1 end

    if voices then
        for _, v in ipairs(voices) do
            if t < tBEG then
                v.s.frequency = v.s.frequency + (math.random()-.5)*.4
                v.s.volume = math.lerp(vBEG, vMID, (t)/tBEG)
            elseif t == tBEG then
                v.start = v.s.frequency
            elseif t < tEND then
                v.s.frequency = math.lerp(v.start, v.target, (t - tBEG)/tDUR)
                v.s.volume = math.lerp(vMID, vEND, (t - tBEG)/tDUR)
            elseif t > tCUT then
                v.s.volume = math.max(v.s.volume - 0.001, 0)
            elseif t > tEND then
                v.s.volume = vEND
            end
            v.s.playing = x < 1 or _ == x
            v.s.pan = math.random()*.5-0.25
        end
        t = t + 1
    end

    local c = gControllers[0]
    if c.buttonDown & Z_TRIG ~= 0 then
        x = (x + 1) % (#voices + 1)
    end
    if c.buttonPressed & Y_BUTTON ~= 0 then
        sound:reload()
        voices = nil
        x, t = 0, 0
    end
    if c.buttonDown & X_BUTTON ~= 0 then
        if voices then
            for _, v in ipairs(voices) do
                v.s.frequency = math.random(200, 400)/hz
            end
            t = 0
        return end
        djui_chat_message_create(""..sound.frequency)
        voices = {}
        for i, n in ipairs(notes) do
            local x = (i > 5) and 3 or 2
            for i = 1, x do
                local v = sound:copy()
                v.looping = true
                v.frequency = math.random(200, 400)/hz
                v.volume = 0
                v:play()
                voices[#voices+1] = { s = v, target = note2freq(n)/hz }
            end
        end
    end
end)
