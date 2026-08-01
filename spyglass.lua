-- name: Spyglass
-- description: Double-tap C-Up in first person\n(action or FP camera) to use the\nspyglass.

local lerp = math.lerp
local easeOutExpo = OUT_EXPO

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

local spyglassActive = {}
local spyglassYaw = 0
local spyglassFootYaw = 0
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
    spyglassActive[m.playerIndex] = 1

    if m.playerIndex == 0 then -- local
        if not initFOV then
            local fpOn = get_first_person_enabled()
            spyglassYaw   = fpOn and gFirstPersonCamera.yaw   or (m.faceAngle.y + 0x8000)
            spyglassFootYaw = spyglassYaw
            spyglassPitch = fpOn and gFirstPersonCamera.pitch or m.faceAngle.z
            spyglassYawVel = 0
            spyglassPitchVel = 0
            initFOV = gFirstPersonCamera.fov
            initCenterL = gFirstPersonCamera.centerL

            override_fp(true)
            gFirstPersonCamera.centerL = false
            gFirstPersonCamera.forcePitch = true
            gFirstPersonCamera.forceYaw = true
        elseif m.input & (INPUT_Z_DOWN|INPUT_B_PRESSED|INPUT_A_DOWN) ~= 0 then
            m.faceAngle.y = m.faceAngle.y + 0x8000
            return set_mario_action(m, ACT_IDLE, 0)
        end
        m.actionTimer = m.actionTimer + 1

        gFirstPersonCamera.fov = lerp(initFOV*.5, initFOV*.1, easeOutExpo(math.min(m.actionTimer, spyglassZoomDuration)/spyglassZoomDuration))

        local sensX = 0.3 * camera_config_get_x_sensitivity()
        local sensY = 0.4 * camera_config_get_y_sensitivity()
        local invX = camera_config_is_x_inverted() and 1 or -1
        local invY = camera_config_is_y_inverted() and 1 or -1
        spyglassYawVel = (spyglassYawVel
            + sensX * (
                invX * m.controller.extStickX
                - 1.5 * djui_hud_get_raw_mouse_x()
            ) - m.controller.stickX
        ) * .9
        spyglassPitchVel = (spyglassPitchVel
            - sensY * (
                invY * m.controller.extStickY
                - 1.5 * djui_hud_get_raw_mouse_y()
            ) - m.controller.stickY
        ) * .9

        spyglassYaw = spyglassYaw + spyglassYawVel
        spyglassPitch = clamp(spyglassPitch + spyglassPitchVel, -0x3F00, 0x3F00)

        local diff = math.max(abs_angle_diff(spyglassFootYaw, spyglassYaw) - 0x2000, 0)
        spyglassFootYaw = approach_s16_symmetric(spyglassFootYaw, spyglassYaw, diff)

        gFirstPersonCamera.yaw = spyglassYaw
        gFirstPersonCamera.pitch = spyglassPitch
        m.faceAngle.y = spyglassYaw
        m.faceAngle.z = spyglassPitch
        m.angleVel.y = spyglassYawVel
        m.angleVel.z = spyglassPitchVel
        m.faceAngle.x = spyglassFootYaw

    else -- remote
        local bodyState = m.marioBodyState
        set_mario_animation(m, MARIO_ANIM_FIRST_PERSON)

        -- client-side prediction
        m.angleVel.y = m.angleVel.y * .9
        m.angleVel.z = m.angleVel.z * .9
        m.faceAngle.y = m.faceAngle.y + m.angleVel.y
        m.faceAngle.z = clamp(m.faceAngle.z + m.angleVel.z, -0x3F00, 0x3F00)
        local diff = math.max(abs_angle_diff(m.faceAngle.x, m.faceAngle.y) - 0x2000, 0)
        m.faceAngle.x = approach_s16_symmetric(m.faceAngle.x, m.faceAngle.y, diff)

        diff = math.s16(m.faceAngle.y - m.faceAngle.x)
        bodyState.allowPartRotation = 1
        bodyState.headAngle.y = diff*3/4
        bodyState.torsoAngle.y = diff/4
        bodyState.headAngle.x = m.faceAngle.z*3/4
        bodyState.torsoAngle.x = m.faceAngle.z/4
    end

    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.x + 0x8000, 0)
    return 0
end
hook_mario_action(ACT_SPYGLASS, act_spyglass)

local cUpTimer = 0
function check_spyglass_action(m)
    if m.action ~= ACT_SPYGLASS then
        if spyglassActive[m.playerIndex] then
            local bodyState = m.marioBodyState
            bodyState.allowPartRotation = 0
            bodyState.headAngle.y = 0
            bodyState.headAngle.x = 0
            bodyState.torsoAngle.y = 0
            bodyState.torsoAngle.x = 0

            spyglassActive[m.playerIndex] = nil
        end

        if m.playerIndex ~= 0 then return end

        if initFOV then -- reset to real fps settings
            gFirstPersonCamera.fov = initFOV
            gFirstPersonCamera.centerL = initCenterL
            gFirstPersonCamera.forceYaw = false
            gFirstPersonCamera.forcePitch = false

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
end
hook_event(HOOK_MARIO_UPDATE, check_spyglass_action)

local function fill_around_rect(x, y, w, h)
    local sw = djui_hud_get_screen_width()+1
    local sh = djui_hud_get_screen_height()

    djui_hud_render_rect(0, 0, sw, y)
    djui_hud_render_rect(0, y, x, h)
    djui_hud_render_rect(x+w, y, sw-x-w, h)
    djui_hud_render_rect(0, y+h, sw, sh-y-h)
end

-- spyglass overlay
local overlay = get_texture_info("texture_transition_circle_half")
hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    if initFOV then
        djui_hud_set_resolution(RESOLUTION_N64)
        local size = 256
        local w = djui_hud_get_screen_width()
        local h = djui_hud_get_screen_height()
        local x = (w-size) / 2 - spyglassYawVel   / 128
        local y = (h-size) / 2 + spyglassPitchVel / 128

        djui_hud_set_color(0, 0, 0, 255)
        fill_around_rect(x, y, size, size)
        x = x + size/2
        djui_hud_set_filter(FILTER_LINEAR)
        djui_hud_render_texture(overlay, x, y, size/overlay.width/2, size/overlay.height)
        djui_hud_render_texture(overlay, x, y, -size/overlay.width/2, size/overlay.height)
    end
end)