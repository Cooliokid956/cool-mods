-- name: OOB Shenaniganry (older)
-- description: 

local GI = gNetworkPlayers[0].globalIndex
---@param o Object
function bhv_floor_init(o)
    o.collisionData = gGlobalObjectCollisionData.cannon_lid_seg8_collision_08004950
    o.oCollisionDistance = 65536
end

function bhv_floor_loop(o)
    local m = gMarioStates[network_local_index_from_global(o.globalPlayerIndex)]
    vec3f_to_object_pos(o, m.pos)
    o.oPosY = gLevelValues.floorLowerLimit + 1
    cur_obj_scale(2+math.max(vec3f_length(m.vel), m.controller.stickMag)/15)
    load_object_collision_model()
end

id_bhvFloor = hook_behavior(nil, OBJ_LIST_SURFACE, false, bhv_floor_init, bhv_floor_loop)

local outsidelevel = false
hook_event(HOOK_UPDATE, function ()
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

hook_event(HOOK_BEFORE_PHYS_STEP, function (m)
    vec3f_to_object_pos(obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvFloor), m.pos)
    cur_obj_scale(2+math.max(vec3f_length(m.vel), m.controller.stickMag)/15)
end)

hook_event(HOOK_ON_SYNC_VALID, function ()
    local floor = obj_get_first_with_behavior_id(id_bhvFloor)
    while floor ~= nil do
        if floor.globalPlayerIndex == GI then return end
        floor = obj_get_next_with_same_behavior_id(floor)
    end
    spawn_sync_object(id_bhvFloor, E_MODEL_NONE, 0,0,0, function (o)
        o.globalPlayerIndex = GI
    end)
end)