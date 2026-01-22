local function get_mouse_world_pos()
    local l = gLakituState
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local rh = djui_hud_get_screen_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    local w = djui_hud_get_screen_width()
    local h = djui_hud_get_screen_height()
    local x = djui_hud_get_mouse_x()*240/rh
    local y = djui_hud_get_mouse_y()*240/rh
    local zoffset = 290

    local camrot = {
        x = -calculate_pitch(l.pos, l.focus),
        y = calculate_yaw(l.pos, l.focus),
        z = l.roll
    }

    local cursor = {
        x = w / 2 - x,
        y = h / 2 - y,
        z = zoffset
    }

    djui_hud_set_resolution(RESOLUTION_N64)
    vec3f_rotate_zxy(cursor, camrot)
    -- vec3f_add(cursor, l.pos)
    -- local normal = vec3f()
    -- vec3f_dif(normal, cursor, l.pos)
    -- vec3f_mul(normal, 30)
    -- local ray = collision_find_surface_on_ray(l.pos.x, l.pos.y, l.pos.z, normal.x, normal.y, normal.z)
    vec3f_mul(cursor, 30)
    local ray = collision_find_surface_on_ray(l.pos.x, l.pos.y, l.pos.z, cursor.x, cursor.y, cursor.z)
    vec3f_copy(cursor, ray.hitPos)
    return cursor
end

hook_event(HOOK_UPDATE, function ()
    local cursor = get_mouse_world_pos()

    local o = obj_get_first_with_behavior_id(id_bhvChainChomp)
    if not o then return end
    if true then
        obj_rotate_towards_point(o, cursor,0,0,2,2)
        if gMarioStates[0].controller.buttonDown & R_JPAD ~= 0 then
            o.oAngleVelRoll = o.oAngleVelRoll + 0x100
            djui_chat_message_create("SPEEEEN")
        end
        o.oMoveAngleRoll = o.oMoveAngleRoll + o.oAngleVelRoll
        obj_set_face_angle_to_move_angle(o)
    end
end)

function mario_rotate_towards_vel(m, pitchDiv, yawDiv)
    local angle = m.marioObj.header.gfx.angle
    local zero = {x=0,y=0,z=0}

    angle.x = approach_s16_asymptotic(angle.x, calculate_pitch(zero, m.vel), pitchDiv);
    angle.y = approach_s16_asymptotic(angle.y, calculate_yaw(zero, m.vel), yawDiv);
end