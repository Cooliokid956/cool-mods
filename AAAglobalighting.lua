function is_down(m, input) return m.controller.buttonDown & input ~= 0 end

local l = gLakituState
---@param m MarioState
function setlighting(m)
    local camrot = {
        x = -calculate_pitch(l.pos, l.focus),
        y = calculate_yaw(l.pos, l.focus),
        z = l.roll
    }
    local offset = {
        x = 40/127,
        y = 40/127,
        z = 40/127
    }
    vec3f_dif(camrot, l.focus, l.pos)
    -- camrot.x = -camrot.x
    camrot.y = -camrot.y
    camrot.z = -camrot.z
    --camrot.y = 0
    vec3f_normalize(camrot)
    vec3f_sub(camrot, offset)
    if m.playerIndex ~= 0 then return end
    --m.marioBodyState.lightingDirX = m.marioBodyState.lightingDirX + (is_down(m, Y_BUTTON) and .05 or 0)
    --djui_chat_message_create(tostring(m.marioBodyState.lightingDirX))
    --m.marioBodyState.lightingDirY = m.marioBodyState.lightingDirY + (is_down(m, Y_BUTTON) and .075 or 0)
    --djui_chat_message_create(tostring(m.marioBodyState.lightingDirY))
    --m.marioBodyState.lightingDirZ = m.marioBodyState.lightingDirZ + (is_down(m, Y_BUTTON) and .1 or 0)
    --djui_chat_message_create(tostring(m.marioBodyState.lightingDirZ))
    --m.marioBodyState.lightingDirX = (is_down(m, Y_BUTTON) and 0 or camrot.x)
    --m.marioBodyState.lightingDirY = (is_down(m, Y_BUTTON) and 0 or camrot.y)
    --m.marioBodyState.lightingDirZ = (is_down(m, Y_BUTTON) and 0 or camrot.z)
    set_lighting_dir(0, (is_down(m, Y_BUTTON) and 0 or camrot.x))
    set_lighting_dir(1, (is_down(m, Y_BUTTON) and 0 or camrot.y))
    set_lighting_dir(2, (is_down(m, Y_BUTTON) and 0 or camrot.z))
end
hook_event(HOOK_MARIO_UPDATE, setlighting)

---@param o Object
hook_event(HOOK_ON_OBJECT_RENDER, function (o)
    local camrot = {
        x = -calculate_pitch(l.pos, l.focus),
        y = calculate_yaw(l.pos, l.focus),
        z = l.roll
    }
    djui_hud_set_resolution(RESOLUTION_N64)
    local w = djui_hud_get_screen_width()
    local h = djui_hud_get_screen_height()
    local zoffset = 290
    local corner = {
        {x = w / 2*.7, y =h / 2*.7, z = zoffset}, -- up left
        {x =-w / 2*.7, y =h / 2*.7, z = zoffset}, -- up right
    }
    for i = 1, 2 do
        vec3f_rotate_zxy(corner[i], camrot)
        vec3f_add(corner[i], l.pos)
    end
    if o.hookRender == 10 then
        if o.oAnimations ~= gObjectAnimations.chain_chomp_seg6_anims_06025178 then
            o.oAnimations = gObjectAnimations.chain_chomp_seg6_anims_06025178
            obj_init_animation(o, 0)
        end
        if cur_obj_check_if_at_animation_end()~=0 then
            cur_obj_init_animation_and_anim_frame(0, 0)
        end
        obj_scale(o, .1)
        obj_set_angle(o, camrot.x-0x8000, camrot.y+0x4000, camrot.z)
        --mtxf_rotate_xyz_and_translate(o.header.gfx.prevThrowMatrix, {x=0,y=0,z=0},{x=-0x8000,y=0x4000,z=0})
        vec3f_to_object_pos(o, corner[1])
    elseif o.hookRender == 20 then
        obj_scale(o, .1)
        obj_set_angle(o, camrot.x, camrot.y, camrot.z)
        vec3f_to_object_pos(o, corner[2])
    end
end)

--hook_event(HOOK_ON_LEVEL_INIT, function ()
--    spawn_non_sync_object(id_bhvStaticObject, E_MODEL_CHAIN_CHOMP, 0,0,0,
--    function (o)
--        o.hookRender = 10
--    end)
--    spawn_non_sync_object(id_bhvStaticObject, E_MODEL_TTC_ROTATING_CUBE, 0,0,0,
--    function (o)
--        o.hookRender = 20
--    end)
--end)

-- hook_behavior(id_bhvKingBobomb, OBJ_LIST_GENACTOR, false, nil, function (o)
--     cur_obj_set_home_once()
--     o.setHome = false
-- end)

-- hook_chat_command("bk", "bring", function()
--     vec3f_to_object_pos(obj_get_first_with_behavior_id(id_bhvKingBobomb), gMarioStates[0].pos)
--     return true
-- end)