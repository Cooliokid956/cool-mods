-- name: Ball
-- description: ball

E_MODEL_ICO_BALL = smlua_model_util_get_id("ball_geo")
hand = get_texture_info("texture_menu_idle_hand")
boing = audio_sample_load("12222124.mp3")
radius = 100
timer = 0

function find_ball()
    local obj = obj_get_first(OBJ_LIST_DEFAULT)
    while obj ~= nil do
        if get_id_from_behavior(obj.behavior) == id_bhvIcoBall then
            return obj
        end
        obj = obj_get_next(obj)
    end
    return nil
end

---@param o Object
function initball(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.hitboxRadius = radius
    o.hitboxHeight = radius
    o.oBounciness = 0.6
    o.oFriction = 0.9
    o.oInteractType = INTERACT_GRABBABLE

    cur_obj_scale(1.0)
    local m = gMarioStates[0]
    local angle = m.faceAngle.y
    o.oVelY = m.vel.y + 20
    o.oVelX = m.vel.x + math.sin(angle * math.pi / 32768)*60
    o.oVelZ = m.vel.z + math.cos(angle * math.pi / 32768)*60
    network_init_object(o, true, nil)
end

function ball(o)
    o.oVelY = o.oVelY - 2

    print(o.oPosX .. ", " .. o.oPosY .. ", " .. o.oPosZ)
    local floor = cur_obj_update_floor_height_and_get_floor()
    if floor ~= nil then
        print("floor real")
        print(floor.normal.x .. ", " .. floor.normal.y .. ", " .. floor.normal.z)
        local ray = collision_find_surface_on_ray(o.oPosX,o.oPosY,o.oPosZ,-floor.normal.x*radius,-floor.normal.y*radius,-floor.normal.z*radius)
        if ray.surface ~= nil and o.oTimer > 2 then
            local hitDepth = vec3f_dist({x=o.oPosX,y=o.oPosY,z=o.oPosZ},ray.hitPos)
            if hitDepth < radius then
                o.oPosX = o.oPosX + ray.surface.normal.x*(radius-hitDepth)
                o.oPosY = o.oPosY + ray.surface.normal.y*(radius-hitDepth)
                o.oPosZ = o.oPosZ + ray.surface.normal.z*(radius-hitDepth)
            end
            -- vec3f_
            print("ouch!")
--            o.oPosY = o.oPosY + 10
--            o.oVelY = 100
            local pos = {x=0,y=0,z=0}
            local normal = {x=0,y=0,z=0}
            vec3f_copy(normal,floor.normal)
            local vel = {x=0,y=0,z=0}
            vec3f_set(vel,o.oVelX,o.oVelY,o.oVelZ)
            local reflect = {x=0,y=0,z=0}
            vec3f_normalize(vel)
            vec3f_mul(normal,vec3f_dot(floor.normal,vel)*2)
            vec3f_dif(reflect,vel,normal)
            vec3f_set(vel,o.oVelX,o.oVelY,o.oVelZ)

--[[        local dir = {x=0,y=0,z=0}
            vec3f_to_vec3s(dir,ray.surface.normal)
            print(ray.surface.normal.x .. ", " .. ray.surface.normal.y .. ", " .. ray.surface.normal.z)
            print(dir.x .. ", " .. dir.y .. ", " .. dir.z)
            local split = {x=0,y=0,z=0}
            vec3f_copy(split,reflect)
            vec3f_rotate_zxy(split,dir)
            print(dir.x .. ", " .. dir.y .. ", " .. dir.z)
            print(reflect.x .. ", " .. reflect.y .. ", " .. reflect.z .. " to " .. split.x .. ", " .. split.y .. ", " .. split.z)
            ]]
            vec3f_mul(reflect,vec3f_dist(pos,vel))
            local perpendicular = vec3f_project(reflect, reflect, floor.normal)
            local parallel = { x = reflect.x - perpendicular.x, y = reflect.y - perpendicular.y, z = reflect.z - perpendicular.z }
            if vec3f_dist(pos,perpendicular) > 20 then
                audio_sample_play(boing, ray.hitPos,1)
            end

            -- apply friction and restitution
            vec3f_mul(parallel, o.oFriction)
            vec3f_mul(perpendicular, o.oBounciness)

            o.oVelX = parallel.x + perpendicular.x
            o.oVelY = parallel.y + perpendicular.y
            o.oVelZ = parallel.z + perpendicular.z
            o.oPosX = o.oPosX + o.oVelX
            o.oPosY = o.oPosY + o.oVelY
            o.oPosZ = o.oPosZ + o.oVelZ

--        elseif ray.surface == nil and o.oTimer > 2 then
--            ray = collision_find_surface_on_ray(o.oPosX)
        else
            o.oPosX = o.oPosX + o.oVelX
            o.oPosY = o.oPosY + o.oVelY
            o.oPosZ = o.oPosZ + o.oVelZ
        end
    end
    o.oTimer = o.oTimer + 1
    if o.oTimer > 240 then
        obj_mark_for_deletion(o)
    end
end

id_bhvIcoBall = hook_behavior(nil, OBJ_LIST_DEFAULT, true, initball, ball)

function spawnball()
    local m = gMarioStates[0]
    set_mario_action(m,ACT_AIR_THROW,0)
    spawn_sync_object(id_bhvIcoBall, E_MODEL_ICO_BALL, m.pos.x, m.pos.y+radius, m.pos.z, nil)
    return true
end
function onhud()
    local pos = nil
    local obj = find_ball()
    local objpos = nil
    djui_hud_set_resolution(RESOLUTION_N64)
    vec3f_set(objpos,obj.oPosX,obj.oPosY,obj.oPosZ)
    djui_hud_world_pos_to_screen_pos(objpos,pos)
    djui_hud_render_texture(hand,pos.x,pos.y,2,2)
end

---@param m MarioState
function pressdown(m)
    if m.playerIndex ~= 0 then return end
    if m.controller.buttonDown & D_JPAD ~= 0 and timer == 0 then
        spawnball()
        timer = 5
        return
    end
    if timer ~= 0 then
        timer = timer - 1
    end
    print("floor: " .. m.floor.type)
    --m.floor.type = SURFACE_NOT_SLIPPERY
    if m.floor.type ~= SURFACE_BURNING then
        m.floor.type = SURFACE_NOT_SLIPPERY
      end
      
end
hook_chat_command("ball", "to throw ball", spawnball)
hook_event(HOOK_BEFORE_MARIO_UPDATE,pressdown)
-- hook_event(HOOK_ON_HUD_RENDER,onhud)