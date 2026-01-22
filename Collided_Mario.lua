-- name: Platform that follows you around

local colObjs = {}

function bhv_mario_collision_init(o)
    o.collisionData = smlua_collision_util_get("ttc_seg7_collision_07015584")
end

function bhv_mario_collision_loop(o)
    local m = gMarioStates[o.oBehParams]
    if is_player_active(m) == 0 then return end

    vec3f_to_object_pos(o, m.pos)
    o.oPosY = o.oPosY - (m.input & INPUT_Z_DOWN ~= 0 and 200 or 0)
    cur_obj_scale(0.5)
    obj_set_vel(o, m.vel.x, m.vel.y, m.vel.z)

    load_object_collision_model()
end
id_bhvMarioCollision = hook_behavior(nil, OBJ_LIST_SURFACE, false, bhv_mario_collision_init, bhv_mario_collision_loop)

function spawn_collision(m)
    local i = m.playerIndex
    if not colObjs[i] -- no object referenced
       or colObjs[i].activeFlags == ACTIVE_FLAG_DEACTIVATED -- referenced object doesn't exist
       or obj_has_behavior_id(colObjs[i], id_bhvMarioCollision) == 0 -- referenced object isn't a mario collision object
    then
        colObjs[i] = spawn_non_sync_object(id_bhvMarioCollision, E_MODEL_TTC_ROTATING_HEXAGON, 0,0,0, function (o)
            o.oBehParams = i
        end)
        djui_chat_message_create("spawn collision #"..i)
    end
end
hook_event(HOOK_MARIO_UPDATE, spawn_collision)