local COL_CLOUD_WALKABLE = smlua_collision_util_get("cloud_collision")
local E_MODEL_CLOUD = smlua_model_util_get_id("cloud_geo")
---@param o Object
function cloud_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_scale(1)
    o.collisionData = COL_CLOUD_WALKABLE
    o.oHomeX = o.oPosX
    o.oHomeY = o.oPosY
    o.oHomeZ = o.oPosZ
    spawn_non_sync_object(id_bhvCloud, E_MODEL_MIST, o.oPosX, o.oPosY, o.oPosZ,
    function(obj)
        obj.parentObj = o
        obj.oOpacity = 1
        obj.oBehParams2ndByte = 1
        obj_scale(obj, 3)
    end)
    network_init_object(o,true,nil)
end
---@param o Object
function cloud_loop(o)
    m = nearest_mario_state_to_object(o)
    -- current vel + (target pos - current pos)*damping
    if o.oAction == -2 then
        o.oVelY = (o.oVelY + (o.oHomeY - o.oPosY)*.01)*.8
        o.oVelX = (o.oVelX + (o.oHomeX - o.oPosX)*.01)*.8
        o.oVelZ = (o.oVelZ + (o.oHomeZ - o.oPosZ)*.01)*.8
        cur_obj_scale(.25)
        if dist_between_object_and_point(o,o.oHomeX,o.oHomeY,o.oHomeZ) < 100 then
            o.oAction = -1
        end
    elseif o.oAction == -1 then
        o.oVelY = (o.oHomeY - o.oPosY)*.2
        o.oVelX = (o.oHomeX - o.oPosX)*.2
        o.oVelZ = (o.oHomeZ - o.oPosZ)*.2
        cur_obj_scale(.5)
        if dist_between_object_and_point(o,o.oHomeX,o.oHomeY,o.oHomeZ) < 5 then
            o.oAction = 0
            cur_obj_scale(1)
        end
    elseif o.oAction == 2 then
        o.oAction = -2
        o.oVelY = 0
        o.oVelX = 0
        o.oVelZ = 0
    elseif o.oAction > 1 then
        o.oVelY = o.oVelY * .9
        o.oVelX = o.oVelX * .9
        o.oVelZ = o.oVelZ * .9
        o.oAction = o.oAction - 1
    elseif dist_between_object_and_point(o,o.oPosX, m.pos.y, o.oPosZ) < 120 and cur_obj_lateral_dist_from_obj_to_home(m.marioObj) < 260 and m.floor.object ~= nil and m.action & ACT_FLAG_AIR == 0 then
        o.oVelY = (o.oVelY + ((o.oHomeY - ((cur_obj_lateral_dist_from_obj_to_home(m.marioObj)-260)/2)^2/300) - o.oPosY)*.3)*.8
        o.oVelX = (o.oVelX + (o.oHomeX - o.oPosX)*.3)*.8
        o.oVelZ = (o.oVelZ + (o.oHomeZ - o.oPosZ)*.3)*.8

        if m.prevAction & ACT_FLAG_AIR ~= 0 and o.oAction == 0 then
            o.oVelY = o.oVelY + m.vel.y * ((dist_between_objects(o,m.marioObj)-400)/20)^2/1000
            o.oAction = 1
        end
    elseif cur_obj_lateral_dist_from_obj_to_home(m.marioObj) < 250 and (((m.actionTimer == 15 and m.action == ACT_GROUND_POUND) or (m.prevAction == ACT_GROUND_POUND and m.action == ACT_HARD_BACKWARD_AIR_KB)) and (m.pos.y + m.vel.y*1.2 < o.oPosY and o.oPosY < m.pos.y + 200)) then
            o.oVelY = o.oVelY + 200 * ((dist_between_objects(o,m.marioObj)-400)/20)^2/700
            o.oVelX = sins(obj_angle_to_object(o,m.marioObj)+math.random(-1000,1000)) * -10 + sins(obj_angle_to_object(o,m.marioObj)+math.random(-1000,1000)) * -5 * (((cur_obj_lateral_dist_from_obj_to_home(m.marioObj)-250)/20)^2)*.1
            o.oVelZ = coss(obj_angle_to_object(o,m.marioObj)+math.random(-1000,1000)) * -10 + coss(obj_angle_to_object(o,m.marioObj)+math.random(-1000,1000)) * -5 * (((cur_obj_lateral_dist_from_obj_to_home(m.marioObj)-250)/20)^2)*.1
            o.oAction = 90
            if m.action ~= ACT_HARD_BACKWARD_AIR_KB then
                set_mario_action(m,ACT_HARD_BACKWARD_AIR_KB,0)
                mario_set_forward_vel(m, 0)
                play_character_sound(m, CHAR_SOUND_WAAAOOOW)
            end
            return
    else
        o.oVelY = (o.oVelY + (o.oHomeY - o.oPosY)*.3)*.8
        o.oVelX = (o.oVelX + (o.oHomeX - o.oPosX)*.3)*.8
        o.oVelZ = (o.oVelZ + (o.oHomeZ - o.oPosZ)*.3)*.8
        if o.oAction > 1 then
            o.oAction = o.oAction - 1
        else
            o.oAction = 0
        end
    end
    o.oPosX = o.oPosX + o.oVelX
    o.oPosY = o.oPosY + o.oVelY
    o.oPosZ = o.oPosZ + o.oVelZ
    if o.oAction <= 1 then
        load_object_collision_model()
    end
end

id_bhvCloudWalkable = hook_behavior(nil,OBJ_LIST_SURFACE,true,cloud_init,cloud_loop)

function cloud_spawner(o)
    o.oHomeX = o.oPosX
    o.oHomeZ = o.oPosZ
    for i = 1, 5, 1 do
        for i = 1, 5, 1 do
            spawn_sync_object(id_bhvCloudWalkable,E_MODEL_CLOUD,o.oPosX,o.oPosY,o.oPosZ,
            function(obj)
                obj.oFaceAngleYaw = 10922
            end)
            o.oFaceAngleYaw = o.oFaceAngleYaw + 21845
            o.oPosX = o.oPosX + sins(o.oFaceAngleYaw)*100
            o.oPosZ = o.oPosZ + coss(o.oFaceAngleYaw)*100
            spawn_sync_object(id_bhvCloudWalkable,E_MODEL_CLOUD,o.oPosX,o.oPosY,o.oPosZ,
            function(obj)
                obj.oFaceAngleYaw = 0
            end)
            o.oFaceAngleYaw = o.oFaceAngleYaw - 10922
            o.oPosX = o.oPosX + sins(o.oFaceAngleYaw)*100
            o.oPosZ = o.oPosZ + coss(o.oFaceAngleYaw)*100
        end
        o.oPosX = o.oHomeX
        o.oPosZ = o.oPosZ + 100
        for i = 1, 5, 1 do
            spawn_sync_object(id_bhvCloudWalkable,E_MODEL_CLOUD,o.oPosX,o.oPosY,o.oPosZ,
            function(obj)
                obj.oFaceAngleYaw = 0
            end)
            o.oFaceAngleYaw = o.oFaceAngleYaw + 21845
            o.oPosX = o.oPosX + sins(o.oFaceAngleYaw)*100
            o.oPosZ = o.oPosZ + coss(o.oFaceAngleYaw)*100
            spawn_sync_object(id_bhvCloudWalkable,E_MODEL_CLOUD,o.oPosX,o.oPosY,o.oPosZ,
            function(obj)
                obj.oFaceAngleYaw = 10922
            end)
            o.oFaceAngleYaw = o.oFaceAngleYaw - 21845
            o.oPosX = o.oPosX + sins(o.oFaceAngleYaw)*100
            o.oPosZ = o.oPosZ + coss(o.oFaceAngleYaw)*100
        end
        o.oPosX = o.oHomeX
        o.oPosZ = o.oPosZ + 100
    end
end

id_bhvCloudSpawner = hook_behavior(nil, OBJ_LIST_SPAWNER,true,cloud_spawner,nil)
---@param m MarioState
function spawncloud(m)
    if m.controller.buttonDown & R_JPAD ~= 0 and (dist_between_objects(obj_get_nearest_object_with_behavior_id(m.marioObj,id_bhvCloudWalkable),m.marioObj) > 30 or obj_get_nearest_object_with_behavior_id(m.marioObj,id_bhvCloudWalkable) == nil) then
        spawn_sync_object(id_bhvCloudWalkable,E_MODEL_CLOUD,m.pos.x,m.pos.y,m.pos.z,nil)
    end
end

function spawn_spawner(msg)
    m = gMarioStates[0]
    spawn_non_sync_object(id_bhvCloudSpawner,E_MODEL_NONE,m.pos.x,m.pos.y,m.pos.z,nil)
    return true
end
hook_chat_command("cloud","spawn",spawn_spawner)
hook_event(HOOK_MARIO_UPDATE,spawncloud)