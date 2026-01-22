-- name: Spyglass
-- description: Double-tap C-Up in first person\n(action or FP camera) to use the\nspyglass.

local function limit_angle(a) return (a + 0x8000) % 0x10000 - 0x8000 end
local function lerp(a, b, t) return a * (1 - t) + b * t end
local function easeOutExpo(x) return x == 1 and 1 or 1 - 2^(-10 * x) end

local overrideFP
local realFPStatus = false

local set_fp = set_first_person_enabled
---@param enable boolean
function _G.set_first_person_enabled(enable)
    realFPStatus = enable
    if overrideFP == nil then set_fp(enable) end
end

function override_fp(enable)
    overrideFP = enable
    local mode
    if enable == nil then mode = realFPStatus else mode = enable end
    set_fp(mode)
end

local spyglassYaw = 0
local spyglassPitch = 0
local spyglassYawVel = 0
local spyglassPitchVel = 0
local initFOV
local initCenterL
local spyglassZoomDuration = 40

_G.ACT_SPYGLASS = allocate_mario_action(ACT_GROUP_STATIONARY|ACT_FLAG_STATIONARY|ACT_FLAG_IDLE)
---@param m MarioState
---@return integer
function act_spyglass(m)
    if m.playerIndex == 0 then
        if m.actionTimer == 0 then
            local fpOn = get_first_person_enabled()
            spyglassYaw   = fpOn and gFirstPersonCamera.yaw   or m.faceAngle.y + 0x8000
            spyglassPitch = fpOn and gFirstPersonCamera.pitch or m.faceAngle.z
            spyglassYawVel = 0
            spyglassPitchVel = 0
            initFOV = gFirstPersonCamera.fov
            initCenterL = gFirstPersonCamera.centerL
            override_fp(true)
        elseif m.input & (INPUT_Z_DOWN|INPUT_B_PRESSED|INPUT_A_DOWN) ~= 0 then
            return set_mario_action(m, ACT_IDLE, 0)
        end
        m.actionTimer = m.actionTimer + 1

        gFirstPersonCamera.fov = lerp(initFOV*.5, initFOV*.1, easeOutExpo(math.min(m.actionTimer, spyglassZoomDuration)/spyglassZoomDuration))
        gFirstPersonCamera.centerL = false

        local sensX = 0.3 * camera_config_get_x_sensitivity()
        local sensY = 0.4 * camera_config_get_y_sensitivity()
        local invX = camera_config_is_x_inverted() and 1 or -1
        local invY = camera_config_is_y_inverted() and 1 or -1
        spyglassYawVel = (spyglassYawVel + sensX * (invX * m.controller.extStickX - 1.5 * djui_hud_get_raw_mouse_x())) * .9
        spyglassPitchVel = (spyglassPitchVel - sensY * (invY * m.controller.extStickY - 1.5 * djui_hud_get_raw_mouse_y())) * .9

        spyglassYaw = limit_angle(spyglassYaw + spyglassYawVel)
        spyglassPitch = clamp(spyglassPitch + spyglassPitchVel, -0x3F00, 0x3F00)

        gFirstPersonCamera.yaw = spyglassYaw
        gFirstPersonCamera.pitch = spyglassPitch
        m.faceAngle.y = spyglassYaw
        m.faceAngle.z = spyglassPitch
        m.angleVel.y = spyglassYawVel
        m.angleVel.z = spyglassPitchVel
    else
        local bodyState = m.marioBodyState
        set_mario_animation(m, MARIO_ANIM_FIRST_PERSON)

        -- client-side prediction
        m.angleVel.y = m.angleVel.y * .9
        m.angleVel.z = m.angleVel.z * .9
        m.faceAngle.y = m.faceAngle.y + m.angleVel.y
        m.faceAngle.z = clamp(m.faceAngle.z + m.angleVel.z, -0x3F00, 0x3F00)

        bodyState.allowPartRotation = 1
        bodyState.headAngle.y = m.angleVel.y*5
        bodyState.headAngle.x = m.faceAngle.z*3/4
        bodyState.torsoAngle.y = m.angleVel.y*2
        bodyState.torsoAngle.x = m.faceAngle.z*1/4
    end
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    return 0
end
hook_mario_action(ACT_SPYGLASS, act_spyglass)

local cUpTimer = 0
function check_spyglass_action(m)
    if m.playerIndex ~= 0
    or m.action == ACT_SPYGLASS then return end
    -- reset to real fps settings
    if initFOV then
        gFirstPersonCamera.fov = initFOV
        gFirstPersonCamera.centerL = initCenterL

        local bodyState = m.marioBodyState
        bodyState.allowPartRotation = 0
        bodyState.headAngle.y = 0
        bodyState.headAngle.x = 0
        bodyState.torsoAngle.y = 0
        bodyState.torsoAngle.x = 0

        override_fp(nil)
        initFOV = nil
    end

    if m.action == ACT_FIRST_PERSON
    or (((m.area and m.area.camera and m.area.camera.mode == CAMERA_MODE_NEWCAM) or get_first_person_enabled()) and m.action & ACT_FLAG_ALLOW_FIRST_PERSON ~= 0) then
        if m.controller.buttonPressed & U_CBUTTONS ~= 0 then
            if cUpTimer > 0 then
                return set_mario_action(m, ACT_SPYGLASS, 0)
            end
            cUpTimer = 8
        end
    end
    cUpTimer = math.max(0, cUpTimer - 1)
end
hook_event(HOOK_MARIO_UPDATE, check_spyglass_action)

local function fill_around_rect(x, y, w, h)
    local res = djui_hud_get_resolution()
    local tsh = djui_hud_get_screen_height()
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local sw = djui_hud_get_screen_width()
    local sh = djui_hud_get_screen_height()

    local ratio = sh/tsh
    sw, sh = sw*ratio, sh*ratio
    x, y, w, h = x*ratio, y*ratio, w*ratio, h*ratio

    djui_hud_render_rect(0, 0, sw, y)
    djui_hud_render_rect(0, y, x, h)
    djui_hud_render_rect(x+w, y, sw-x-w, h)
    djui_hud_render_rect(0, y+h, sw, sh-y-h)

    djui_hud_set_resolution(res)
end

-- spyglass overlay
hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    if initFOV then
        djui_hud_set_resolution(RESOLUTION_N64)
        local size = 192
        local w = djui_hud_get_screen_width()
        local h = djui_hud_get_screen_height()
        local x = (w-size) / 2 - spyglassYawVel   / 128
        local y = (h-size) / 2 + spyglassPitchVel / 128

        djui_hud_set_color(0, 0, 0, 255)
        fill_around_rect(x, y, size, size)

        djui_hud_set_color(0, 0, 0, 20)
        local segcount = 32
        for i = 1, segcount do
            djui_hud_set_rotation(i/segcount*0x10000, -1, .5)
            for o = 0, 16 do
                djui_hud_render_rect(x+size-o, y, size/2-o, size)
            end
        end
    end
end)