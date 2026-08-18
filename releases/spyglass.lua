-- name: Spyglass
-- description: Double-tap C-Up in first person\n(action or FP camera) to use the\nspyglass.

-- local blobs!!
local gFirstPersonCamera = gFirstPersonCamera
local get_mouse_down, clamp, max, s16 = djui_hud_get_mouse_buttons_down, math.clamp, math.max, math.s16
local get_first_person_enabled, set_mario_action = get_first_person_enabled, set_mario_action
local camera_config_get_x_sensitivity, camera_config_get_y_sensitivity, camera_config_is_x_inverted, camera_config_is_y_inverted, djui_hud_get_raw_mouse_x, djui_hud_get_raw_mouse_y = camera_config_get_x_sensitivity, camera_config_get_y_sensitivity, camera_config_is_x_inverted, camera_config_is_y_inverted, djui_hud_get_raw_mouse_x, djui_hud_get_raw_mouse_y
local abs_angle_diff, approach_s16_symmetric, approach_s16_asymptotic = abs_angle_diff, approach_s16_symmetric, approach_s16_asymptotic
local resolution, color, filter, screen_width, screen_height, rect_interp, tex_interp = djui_hud_set_resolution, djui_hud_set_color, djui_hud_set_filter, djui_hud_get_screen_width, djui_hud_get_screen_height, djui_hud_render_rect_interpolated, djui_hud_render_texture_interpolated
local N64, LINEAR = RESOLUTION_N64, FILTER_LINEAR
-- constants
local INPUT_B_PRESSED, INPUT_A_DOWN, ACT_FIRST_PERSON, INPUT_Z_DOWN, M_MOUSE_BUTTON, MARIO_ANIM_FIRST_PERSON, START_BUTTON, CAMERA_MODE_NEWCAM, ACT_FLAG_ALLOW_FIRST_PERSON, U_CBUTTONS = INPUT_B_PRESSED, INPUT_A_DOWN, ACT_FIRST_PERSON, INPUT_Z_DOWN, M_MOUSE_BUTTON, MARIO_ANIM_FIRST_PERSON, START_BUTTON, CAMERA_MODE_NEWCAM, ACT_FLAG_ALLOW_FIRST_PERSON, U_CBUTTONS

local overrideFP
local realFPStatus = false

local set_fp = set_first_person_enabled
---@param enable boolean
function _G.set_first_person_enabled(enable)
    realFPStatus = enable
    if overrideFP == nil then set_fp(enable) end
end

local function override_fp(enable)
    overrideFP = enable
    local mode
    if enable == nil then mode = realFPStatus else mode = enable end
    set_fp(mode)
end

local spyglassStates = {}
for i = 0, gServerSettings.maxPlayers-1 do
    spyglassStates[i] = {
        active = false;
        yaw = 0;
        footYaw = 0;
        pitch = 0;
        targetYaw = 0;
        targetPitch = 0;
    }
end

local initFOV, initCenterL
local HEAD_ABS_RANGE = 0x3FFF

_G.ACT_SPYGLASS = allocate_mario_action(ACT_GROUP_STATIONARY|ACT_FLAG_STATIONARY|ACT_FLAG_ALLOW_FIRST_PERSON|ACT_FLAG_PAUSE_EXIT)
function act_spyglass(m)
    local s = spyglassStates[m.playerIndex]

    if m.playerIndex == 0 then -- local
        if not initFOV then
            local fpOn = get_first_person_enabled()
            s.yaw = fpOn and (gFirstPersonCamera.yaw - 0x8000) or m.faceAngle.y
            s.targetYaw = s.yaw
            s.pitch = fpOn and gFirstPersonCamera.pitch or m.faceAngle.z
            s.yawVel = 0
            s.pitchVel = 0
            initFOV = gFirstPersonCamera.fov
            zoomFOV = initFOV
            initCenterL = gFirstPersonCamera.centerL

            override_fp(true)
            gFirstPersonCamera.centerL = false
            gFirstPersonCamera.forcePitch = true
            gFirstPersonCamera.forceYaw = true
        elseif m.input & (INPUT_B_PRESSED|INPUT_A_DOWN) ~= 0 then
            m.faceAngle.y = m.actionArg == ACT_FIRST_PERSON and s.footYaw or s.yaw
            return set_mario_action(m, m.actionArg, 0)
        end

        gFirstPersonCamera.fov = gFirstPersonCamera.fov + (initFOV*.1 - gFirstPersonCamera.fov) * .3

        local sensX = 0.3 * camera_config_get_x_sensitivity()
        local sensY = 0.4 * camera_config_get_y_sensitivity()
        local invX = camera_config_is_x_inverted() and 1 or -1
        local invY = camera_config_is_y_inverted() and 1 or -1
        s.yawVel = (s.yawVel
            + sensX * (
                invX * m.controller.extStickX
                - 1.5 * djui_hud_get_raw_mouse_x()
            ) - m.controller.stickX
        ) * .9
        s.pitchVel = (s.pitchVel
            - sensY * (
                invY * m.controller.extStickY
                - 1.5 * djui_hud_get_raw_mouse_y()
            ) - m.controller.stickY
        ) * .9

        m.actionState = (m.input & INPUT_Z_DOWN) | (get_mouse_down() & M_MOUSE_BUTTON)
        if m.actionState ~= 0 then -- brake
            s.yawVel, s.pitchVel = s.yawVel * .5, s.pitchVel * .5
        end

        s.yaw = s.yaw + s.yawVel
        s.pitch = clamp(s.pitch + s.pitchVel, -0x3FF0, 0x3FFF)

        local diff = max(abs_angle_diff(s.footYaw, s.yaw) - HEAD_ABS_RANGE, 0)
        s.footYaw = approach_s16_symmetric(s.footYaw, s.yaw, diff)

        gFirstPersonCamera.yaw = s.yaw + 0x8000
        gFirstPersonCamera.pitch = s.pitch
        m.faceAngle.y = s.yaw
        m.faceAngle.z = s.pitch
        m.angleVel.y = s.yawVel
        m.angleVel.z = s.pitchVel

    else -- remote
        local bodyState = m.marioBodyState
        set_mario_animation(m, MARIO_ANIM_FIRST_PERSON)
        if not s.active then
            s.footYaw = m.faceAngle.y
            s.yaw = m.faceAngle.y
            s.pitch = m.faceAngle.z
        end

        -- client-side prediction
        m.angleVel.y, m.angleVel.z = m.angleVel.y * .9, m.angleVel.z * .9
        if m.actionState ~= 0 then -- brake
            m.angleVel.y, m.angleVel.z = m.angleVel.y * .5, m.angleVel.z * .5
        end
        m.faceAngle.y = m.faceAngle.y + m.angleVel.y
        m.faceAngle.z = clamp(m.faceAngle.z + m.angleVel.z, -0x3FF0, 0x3FFF)

        s.yaw = approach_s16_asymptotic(s.yaw, m.faceAngle.y, 3)
        s.pitch = approach_s16_asymptotic(s.pitch, m.faceAngle.z, 3)

        local diff = max(abs_angle_diff(s.footYaw, s.yaw) - HEAD_ABS_RANGE, 0)
        s.footYaw = approach_s16_symmetric(s.footYaw, s.yaw, diff)

        diff = s16(s.yaw - s.footYaw)
        bodyState.allowPartRotation = 1
        bodyState.headAngle.y = diff*3/4
        bodyState.torsoAngle.y = diff/4
        bodyState.headAngle.x = s.pitch*3/4
        bodyState.torsoAngle.x = s.pitch/4
    end

    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, s.footYaw, 0)
    s.active = true

    m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
    return 0
end
hook_mario_action(ACT_SPYGLASS, act_spyglass)
local ACT_SPYGLASS = ACT_SPYGLASS

local cUpTimer = 0
function check_spyglass_action(m)
    if m.action ~= ACT_SPYGLASS then
        local s = spyglassStates[m.playerIndex]
        if s and s.active then
            local body = m.marioBodyState
            body.allowPartRotation = 0
            body.headAngle.y, body.headAngle.x = 0, 0
            body.torsoAngle.y, body.torsoAngle.x = 0, 0

            spyglassStates[m.playerIndex].active = false
        end

        if m.playerIndex ~= 0 then return end

        if initFOV then -- reset to real fps settings
            gFirstPersonCamera.fov = initFOV
            gFirstPersonCamera.centerL = initCenterL
            gFirstPersonCamera.forceYaw = false
            gFirstPersonCamera.forcePitch = false

            override_fp()
            initFOV = nil
        end

        if m.action == ACT_FIRST_PERSON
        or (((m.area and m.area.camera and m.area.camera.mode == CAMERA_MODE_NEWCAM) or get_first_person_enabled()) and m.action & ACT_FLAG_ALLOW_FIRST_PERSON ~= 0) then
            if m.controller.buttonPressed & U_CBUTTONS ~= 0 then
                if cUpTimer > 0 then
                    m.faceAngle.y = m.faceAngle.y + m.statusForCamera.headRotation.y
                    m.faceAngle.z = m.statusForCamera.headRotation.x
                    return set_mario_action(m, ACT_SPYGLASS, m.action)
                end
                cUpTimer = 8
            end
        end
        cUpTimer = max(0, cUpTimer - 1)
    end
end
hook_event(HOOK_MARIO_UPDATE, check_spyglass_action)

local function inverse_rect_interp(xP, yP, wP, hP, x, y, w, h)
    local sw = screen_width()+1
    local sh = screen_height()

    rect_interp(0, 0, sw, yP, 0, 0, sw, y)
    rect_interp(0, yP, xP, hP, 0, y, x, h)
    rect_interp(xP+wP, yP, sw-xP-wP, hP, x+w, y, sw-x-w, h)
    rect_interp(0, yP+hP, sw, sh-yP-hP, 0, y+h, sw, sh-y-h)
end

-- spyglass overlay
local overlay = get_texture_info("texture_transition_circle_half")
local xP, yP, sizeP
hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    if initFOV then
        local s = spyglassStates[0]
        resolution(N64)
        local size = 360 * (1-gFirstPersonCamera.fov/initFOV)
        local w = screen_width()
        local h = screen_height()
        local x = (w-size) / 2 - s.yawVel   / 128
        local y = (h-size) / 2 + s.pitchVel / 128
        if not xP then xP, yP, sizeP = x, y, size end

        color(0, 0, 0, 255)
        inverse_rect_interp(xP, yP, sizeP, sizeP, x, y, size, size)
        filter(LINEAR)
        tex_interp(overlay, xP + sizeP/2, yP, sizeP/overlay.width/2, sizeP/overlay.height, x + size/2, y, size/overlay.width/2, size/overlay.height)
        tex_interp(overlay, xP + sizeP/2, yP, -sizeP/overlay.width/2, sizeP/overlay.height, x + size/2, y, -size/overlay.width/2, size/overlay.height)
        xP, yP, sizeP = x, y, size
    else xP = nil end
end)