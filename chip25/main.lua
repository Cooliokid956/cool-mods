--- @type Chip[]
local chips = {}

local function DEFAULT_LOOP(self)
    audio_stream_set_volume(self.wave, self.amplitude)
    audio_stream_set_frequency(self.wave, self.frequency / (self.root or 1))
    if self.power ~= self.powered then
        if self.power then audio_stream_play(self.wave, true, self.amplitude)
        else audio_stream_stop(self.wave) end
        self.powered = self.power
    end
end

local function LOOP_POINTS(lstart, lend)
    return function (self)
        audio_stream_set_loop_points(self.wave, lstart, lend)
    end
end

--- @class Chip
--- @field name string
--- @field channels Channel[]

--- @class Channel
--- @field name string
--- @field wave ModAudio
--- @field root integer?
--- @field amplitude number
--- @field frequency number
--- @field power boolean
--- @field powered boolean
--- @field loop function

--- @class ChipSetup
--- @field name string
--- @field channels ChannelSetup[]

--- @class ChannelSetup
--- @field name string
--- @field wave string
--- @field root integer?
--- @field control table?

_G.chip = {
    --- @param c ChipSetup
    --- @return Chip
    register = function (c)
        --- @type Chip
        local chip = {
            name = c.name,
            channels = {}
        }
        for i, channel in ipairs(c.channels) do
            local nchan = {}
            nchan.name = channel.name

            local wave = tostring(channel.wave)
            nchan.wave = audio_stream_load(wave)
            if not nchan.wave then
                log_to_console("Missing waveform: "..wave)
                return nil
            end
            audio_stream_set_looping(nchan.wave, true)
            nchan.amplitude = 1
            nchan.frequency = 440
            nchan.power = false
            nchan.powered = false
            if channel.root then nchan.root = channel.root end

            local cont = channel.control
            if cont then
                if cont.init then cont.init(nchan) end
                for field, val in pairs(cont) do
                    nchan[field] = val
                end
            end
            if not nchan.loop then
                nchan.loop = DEFAULT_LOOP
            end
            chip.channels[i] = nchan
        end
        table.insert(chips, chip)
        return chip
    end,
    DEFAULT_LOOP = DEFAULT_LOOP
}

function update_chips()
    for _, chip in ipairs(chips) do
        for _, chan in ipairs(chip.channels) do
            chan:loop()
        end
    end
end
hook_event(HOOK_UPDATE, update_chips)

-- C-Chip
local r = 48000
-- local r = 55

local cChipPulseControls = {
    init = function (self)
        self.duty = .5
        audio_stream_set_loop_points(self.wave, self.duty*r, self.duty*r + r)
    end,
    loop = function (self)
        chip.DEFAULT_LOOP(self)
        audio_stream_set_loop_points(self.wave, self.duty*r, self.duty*r + r)
    end
}

--- @type ChipSetup
local cchip = {
    name = "C-Chip",
    channels = {
        { name = "Pulse 1", wave = "pulse0.ogg", control = cChipPulseControls },
        { name = "Pulse 2", wave = "pulse1.ogg", control = cChipPulseControls },
        { name = "Pulse 3", wave = "pulse2.ogg", control = cChipPulseControls },
        { name = "Pulse 4", wave = "pulse3.ogg", control = cChipPulseControls },
        { name = "Triangle 1", wave = "triangle0.ogg" },
        { name = "Triangle 2", wave = "triangle1.ogg" },
        { name = "Triangle 3", wave = "triangle2.ogg" },
        { name = "Triangle 4", wave = "triangle3.ogg" },
        { name = "Wizmy Piano", wave = "df.ogg", root = 500 },
        { name = "Strings", wave = "StringHigh.ogg", root = 370, control = { init = LOOP_POINTS(10869, 31086)} }
    }
}
cchip = chip.register(cchip)

function N(x) return 440*2^(x/12) end
c = 0
v = 0
ci = 1
hook_event(HOOK_MARIO_UPDATE, function (m)
    if not cchip or m.playerIndex ~= 0 then return end
    local capped = (m.flags & MARIO_CAP_ON_HEAD ~= 0)
    local chan = cchip.channels[capped and ci or 9]
    chan.power = (v > .001)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    chan.amplitude = .06 * ((djui_hud_get_screen_height()-djui_hud_get_mouse_y())/djui_hud_get_screen_height())
    chan.duty = djui_hud_get_mouse_x()/djui_hud_get_screen_width()
    chan.frequency = N(c)

    --wowo
    chan.amplitude = .1*v * (capped and 1 or 8)
    -- chan.amplitude = .1/m.framesSinceA
    chan.frequency = capped and N((-gFirstPersonCamera.pitch / 0x400)) or 1
    chan.frequency = N((-gFirstPersonCamera.pitch / 0x400))
    if m.controller.buttonDown & Z_TRIG ~= 0 then chan.frequency = N((-gFirstPersonCamera.pitch // 0x400)) end
    if m.controller.buttonDown & Y_BUTTON ~= 0 then v = v + .1 end
    v = v * .85

    if m.controller.buttonPressed & L_JPAD ~= 0 then c = c - 1 end
    if m.controller.buttonPressed & R_JPAD ~= 0 then c = c + 1 end

    djui_chat_message_create(""..chan.amplitude)
    djui_chat_message_create(""..chan.duty)
    djui_chat_message_create(""..chan.frequency)
    djui_chat_message_create((chan.duty*r)..", "..(chan.duty*r + r))
    djui_chat_message_create(""..audio_stream_get_frequency(chan.wave))
    djui_chat_message_create(""..audio_stream_get_position(chan.wave))
end)

hook_chat_command("setchan", " ", function (msg)
    cchip.channels[ci].power = false
    ci = tonumber(msg)
    cchip.channels[ci].power = true
    return true
end)