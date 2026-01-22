-- name: OOB Shenaniganry (old)
-- description: 

ba = 163.835
of = 0
---@param o Object
function bhv_floor_init(o)
    o.collisionData = gGlobalObjectCollisionData.unknown_seg8_collision_080262F8
    o.oCollisionDistance = 524288
    o.header.gfx.skipInViewCheck = true
end

function bhv_floor_loop(o)
    --local m = gMarioStates[network_local_index_from_global(o.globalPlayerIndex)]
    o.oPosY = gLevelValues.floorLowerLimit + 1
    o.oPosX, o.oPosZ = 0,0
    obj_set_angle(o, 0,0,0)
    cur_obj_scale(ba)
    load_object_collision_model()
end

id_bhvFloor = hook_behavior(nil, OBJ_LIST_SURFACE, false, bhv_floor_init, bhv_floor_loop)

local outsidelevel = false
hook_event(HOOK_UPDATE, function ()
    print(200*ba+of)
    local m = gMarioStates[0]
    if m.floor.object ~= nil then
        print(m.pos.x, m.pos.y, m.pos.z)
        if obj_has_behavior_id(m.floor.object, id_bhvFloor) ~= 0 and outsidelevel ~= 1 then
            play_secondary_music(0, 0, 0, 20)
            outsidelevel = true
        end
    elseif outsidelevel then
        stop_secondary_music(50)
        outsidelevel = false
    end
end)

hook_event(HOOK_ON_LEVEL_INIT, function ()
    spawn_non_sync_object(id_bhvFloor, E_MODEL_DL_CANNON_LID, of,0,of, nil)
end)

hook_chat_command("set", " ", function (msg)
    if tonumber(msg) == fail then
        djui_chat_message_create(tostring(ba))
    else
        ba = tonumber(msg)
    end
end)