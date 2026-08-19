-- name: Wowozela

--- @class Sample
--- @field name      string
--- @field file      string
--- @field root      integer?
--- @field loopStart integer?
--- @field loopEnd   integer?

function hsv2rgb(h, s, v)
	local C = v * s
	local m = v - C
	local r, g, b = m, m, m
	if h == h then
		local h_ = (h % 1.0) * 6
		local X = C * (1 - math.abs(h_ % 2 - 1))
		C, X = C + m, X + m
		if     h_ < 1 then r, g, b = C, X, m
		elseif h_ < 2 then r, g, b = X, C, m
		elseif h_ < 3 then r, g, b = m, C, X
		elseif h_ < 4 then r, g, b = m, X, C
		elseif h_ < 5 then r, g, b = X, m, C
		else               r, g, b = C, m, X
		end
	end
	return {r, g, b}
end

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

--- @type Sample[]
local samples = {}

local samplers = {}
for i = 0, MAX_PLAYERS - 1 do
    samples[i] = {}
end

_G.WowozelaAPI = {
    defSample = function (name, file, extra)
        local sample = {
            name = name,
            file = file
        }
        if extra then
            if extra.root then sample.root = extra.root end
            if extra.loop
           and extra.loop[1]
           and extra.loop[2]
            then
                sample.loopStart = extra.loop[1]
                sample.loopEnd   = extra.loop[2]
            end
        end
        table.insert(samples, sample)
    end,
}

local r = 48000

WowozelaAPI.defSample("Pulse 1", "pulse0.ogg")
WowozelaAPI.defSample("Pulse 2", "pulse1.ogg")
WowozelaAPI.defSample("Pulse 3", "pulse2.ogg")
WowozelaAPI.defSample("Pulse 4", "pulse3.ogg")
WowozelaAPI.defSample("Triangle 1", "triangle0.ogg")
WowozelaAPI.defSample("Triangle 2", "triangle1.ogg")
WowozelaAPI.defSample("Triangle 3", "triangle2.ogg")
WowozelaAPI.defSample("Triangle 4", "triangle3.ogg")
WowozelaAPI.defSample("Wizmy Piano", "df.ogg", { root = 500 })
WowozelaAPI.defSample("Strings", "StringHigh.ogg", { root = 370, loop = { 10869, 31086 } })

function N(x) return 440*2^(x/12) end
c = 0
v = 0
ci = 1

local pitch = 0
hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex ~= 0 then return end
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local sensY = 0.4 * camera_config_get_y_sensitivity()
    local invY = camera_config_is_y_inverted() and 1 or -1
    local extStickY = m.controller.extStickY
    if extStickY == 0 then
        extStickY = (clamp(m.controller.buttonDown & U_CBUTTONS, 0, 1) - clamp(m.controller.buttonDown & D_CBUTTONS, 0, 1)) * 24
    end
    local mouse_y = djui_hud_get_raw_mouse_y()

    pitch = pitch - (sensY * (invY * extStickY - 1.5 * mouse_y))
    gFirstPersonCamera.forcePitch = true
    gFirstPersonCamera.pitch = pitch
    gFirstPersonCamera.forceRoll = false
    gLakituState.roll = (((pitch + 0x4000) // 0x8000) % 2) * 0x8000

    djui_chat_message_create(""..(pitch+0x4000))
    -- chan.amplitude = .06 * ((djui_hud_get_screen_height()-djui_hud_get_mouse_y())/djui_hud_get_screen_height())

    -- --wowo
    -- chan.amplitude = .1*v * (capped and 1 or 8)
    -- -- chan.amplitude = .1/m.framesSinceA
    -- chan.frequency = capped and N((-gFirstPersonCamera.pitch / 0x400)) or 1
    -- chan.frequency = N((-gFirstPersonCamera.pitch / 0x400))

    -- if m.controller.buttonDown & Z_TRIG ~= 0 then chan.frequency = N((-gFirstPersonCamera.pitch // 0x4000)) end
    if m.controller.buttonDown & Y_BUTTON ~= 0 then v = v + .1 end
    v = v * .85
end)

hook_event(HOOK_UPDATE, function ()
    for i = 1, NUM_OBJ_LISTS-1 do
        local o = obj_get_first(i)
        if o then
            o.hookRender = 69
            djui_chat_message_create("1")
            return
        end
    end
end)

hook_event(HOOK_ON_OBJECT_RENDER, function(obj)
    if obj.hookRender == 69 then
        camera = geo_get_current_camera()
        camera.fnNode.node.hookProcess = 69
        djui_chat_message_create("2")
    end
end)

hook_event(HOOK_ON_GEO_PROCESS, function(node, i)
    if node.hookProcess ~= 69 then return end
    djui_chat_message_create(""..node.type)

    cast_graph_node(node).rollScreen = (((pitch + 0x4000) // 0x8000) % 2) * 0x8000
    djui_chat_message_create(""..cast_graph_node(node).rollScreen)
end)
