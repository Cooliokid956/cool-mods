local l = gLakituState
local rblxCam = {
    enabled = false,
    pitch = 0,
    yaw = 0,
    dist = 1000,
    targetDist = 1000,
    mouseLocked = false,
    prevMouseLock = nil
}

local BLOCKED = (U_CBUTTONS|D_CBUTTONS)
local buttons
local scrollDist = 150

function capture_c_buttons(m)
    if m.playerIndex ~= 0
    or l.mode ~= CAMERA_MODE_NEWCAM then return end

    local c = m.controller
    buttons = {
        buttonDown = c.buttonDown,
        buttonPressed = c.buttonPressed & ~(buttons and buttons.buttonDown or 0)
    }
    c.buttonDown = c.buttonDown & ~BLOCKED
    c.buttonPressed = c.buttonPressed & ~BLOCKED

    c = buttons.buttonPressed

    rblxCam.targetDist = math.max(rblxCam.targetDist - ((c & U_CBUTTONS ~= 0) and scrollDist or 0) + ((c & D_CBUTTONS ~= 0) and scrollDist or 0), 0)
end
hook_event(HOOK_BEFORE_MARIO_UPDATE, capture_c_buttons)

function roblox_cam(m)
    if m.playerIndex ~= 0
    or l.mode ~= CAMERA_MODE_NEWCAM then return end

    camera_config_enable_analog_cam(buttons.buttonDown & (L_CBUTTONS|R_CBUTTONS) == 0)
    camera_config_set_aggression(0)
    camera_config_set_pan_level(0)
    camera_config_set_deceleration(255)

    set_handheld_shake(HAND_CAM_SHAKE_OFF)
    vec3s_set(gLakituState.shakeMagnitude, 0, 0, 0)

    rblxCam.targetDist = math.max(rblxCam.targetDist - djui_hud_get_mouse_scroll_y() * scrollDist, 0)

    rblxCam.dist = approach_f32_asymptotic(rblxCam.dist, rblxCam.targetDist, .4)

    rblxCam.pitch = calculate_pitch(l.goalPos, l.goalFocus)
    rblxCam.yaw = calculate_yaw(l.goalPos, l.goalFocus)

    local normal = vec3f(
        coss(rblxCam.pitch) * sins(rblxCam.yaw),
        sins(rblxCam.pitch),
        coss(rblxCam.pitch) * coss(rblxCam.yaw)
    )

    gLakituState.posHSpeed = 0
    gLakituState.posVSpeed = 0
    gLakituState.focHSpeed = 0
    gLakituState.focVSpeed = 0

    vec3f_copy(l.focus, m.pos)
    l.focus.y = l.focus.y + 120

    if rblxCam.dist > 50 then
        local orig = rblxCam.dist
        vec3f_mul(normal, -orig)
        local ray = collision_find_surface_on_ray(l.focus.x, l.focus.y, l.focus.z, normal.x, normal.y, normal.z)
        rblxCam.dist = math.min(orig, vec3f_dist(l.focus, ray.hitPos))
        vec3f_mul(normal, -1/orig)
    end

    l.pos.x = -rblxCam.dist * normal.x
    l.pos.y = -rblxCam.dist * normal.y
    l.pos.z = -rblxCam.dist * normal.z
    vec3f_add(l.pos, l.focus)

    local dist = vec3f_dist(l.pos, l.focus)
    if dist < 200 then
        m.flags = m.flags | MARIO_TELEPORTING
        m.fadeWarpOpacity = dist/200*0xFF
    else m.flags = m.flags & ~MARIO_TELEPORTING end

    if rblxCam.dist < 50 then
        vec3f_mul(normal, 50)
        vec3f_add(l.focus, normal)
    end
    local mouse = rblxCam.dist < 10 or (djui_hud_get_mouse_buttons_down() & R_MOUSE_BUTTON ~= 0)
    camera_config_enable_mouse_look(mouse)

    vec3f_copy(m.area.camera.focus, l.focus)
    vec3f_copy(l.curFocus, l.focus)
    vec3f_copy(l.goalFocus, l.focus)
    vec3f_copy(m.area.camera.pos, l.pos)
    vec3f_copy(l.curPos, l.pos)
    vec3f_copy(l.goalPos, l.pos)
end
hook_event(HOOK_MARIO_UPDATE, roblox_cam)

-- hook_event(HOOK_ON_SET_CAMERA_MODE, function (c, mode)
--     djui_chat_message_create("mode: "..mode)
-- end)