function djui_hud_render_line(x1,y1,x2,y2,thickness)
    local angle = atan2s(x2-x1,y1-y2)
    local length = math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
    djui_hud_set_rotation(angle, 0, .5)
    djui_hud_render_rect(x1,y1-thickness/2,length,thickness)
    djui_hud_set_rotation(0,0,0)
end


E_MODEL_BEAM = smlua_model_util_get_id("beam_geo")
sBeam = audio_sample_load("boom.ogg")

gPlayerSyncTable[0].cvecs = {}
for i = 1, 6 do
gPlayerSyncTable[0].cvecs[i] = {}
gPlayerSyncTable[0].cvecs[i].x = 0
gPlayerSyncTable[0].cvecs[i].y = 0
gPlayerSyncTable[0].cvecs[i].z = 0
end

target = {x=0,y=0,z=0}
zoffset = 290

MAX_AMMO = 120
ammo = MAX_AMMO
ammoRefill = 0
function render_rect(pos,size)
    djui_hud_render_rect(pos.x-size/2,pos.y-size/2,size,size)
end

objLists = {
    OBJ_LIST_PLAYER,
    OBJ_LIST_DESTRUCTIVE,
    OBJ_LIST_GENACTOR,
    OBJ_LIST_PUSHABLE,
    OBJ_LIST_SURFACE
}

function detect_collided_object(o, lists)
    for _, list in ipairs(lists) do
        local obj = obj_get_first(list)
        while obj ~= nil do
            if obj_check_hitbox_overlap(o, obj) and obj_has_behavior(obj, o.behavior) == 0 then
                return obj
            end
            obj = obj_get_next(obj)
        end
    end
end
---@param o Object
function beam_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oBuoyancy = 0
    o.oGravity = 0
    o.hitboxHeight = 50
    o.hitboxRadius = 25
    cur_obj_scale(.5)
    audio_sample_play(sBeam, {x=o.oPosX,y=o.oPosY,z=o.oPosZ}, 1)
end
function beam_loop(o)
    cur_obj_set_billboard_if_vanilla_cam()
    o.oForwardVel = 30*coss(o.oMoveAnglePitch)
    o.oVelY = 30*sins(o.oMoveAnglePitch)
    local flags = object_step()
    local col = detect_collided_object(o, objLists)
    if col ~= nil then
        if (get_object_list_from_behavior(col.behavior) == OBJ_LIST_PLAYER and col.globalPlayerIndex ~= o.globalPlayerIndex) or get_object_list_from_behavior(col.behavior) ~= OBJ_LIST_PLAYER then
            print(get_behavior_name_from_id(get_id_from_behavior(col.behavior)))
            obj_mark_for_deletion(o)
            col.oInteractStatus = col.oInteractStatus | (ATTACK_KICK_OR_TRIP | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB)
        end
    end
    if flags & (OBJ_COL_FLAG_HIT_WALL|OBJ_COL_FLAG_GROUNDED|OBJ_COL_FLAGS_LANDED) ~= 0 or o.oForwardVel == 0 then
        obj_mark_for_deletion(o)
    end
end
id_bhvBeam = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, true, beam_init, beam_loop, "bhvBeam")

---@param m MarioState
function shoot(m)
    if m.playerIndex == 0 then
        if m.controller.buttonDown & B_BUTTON ~= 0 and ammo > 0 then
            local pos = m.marioBodyState.headPos
            spawn_sync_object(id_bhvBeam, E_MODEL_BEAM, pos.x, pos.y, pos.z, function (o)
                o.globalPlayerIndex = network_global_index_from_local(m.playerIndex)
                o.oMoveAngleYaw = calculate_yaw(pos, target)
                o.oMoveAnglePitch = calculate_pitch(pos, target)
                o.oFaceAnglePitch = 16384
            end)
            ammo = ammo - 1
            m.controller.buttonPressed = m.controller.buttonPressed & ~B_BUTTON
        end
        if ammoRefill ~= 0 then
            ammoRefill = ammoRefill - 1
        elseif ammo < MAX_AMMO then
            ammo = ammo + 1
            ammoRefill = 20
        end
    end
end
hook_event(HOOK_BEFORE_MARIO_UPDATE, shoot)

hook_event(HOOK_ON_HUD_RENDER, function ()
    ---@type LakituState
    local l = gLakituState
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local rh = djui_hud_get_screen_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    local w = djui_hud_get_screen_width()
    local h = djui_hud_get_screen_height()
    local x = djui_hud_get_mouse_x()*240/rh
    local y = djui_hud_get_mouse_y()*240/rh
    local mpos = {x=0,y=0,z=0}
    djui_hud_world_pos_to_screen_pos(gMarioStates[0].pos, mpos)
    local camrot = {
        x = -calculate_pitch(l.pos, l.focus),
        y = calculate_yaw(l.pos, l.focus),
        z = l.roll
    }
    local corner = {
        {x = w / 2, y =-h / 2, z = zoffset}, -- up left
        {x =-w / 2, y =-h / 2, z = zoffset}, -- up right
        {x = w / 2, y = h / 2, z = zoffset}, -- down left
        {x =-w / 2, y = h / 2, z = zoffset}  -- down right
    }
    local cursor = {
        x = w / 2 - x,
        y = h / 2 - y,
        z = zoffset
    }
    local screen = {
        {x=0,y=0,z=0},
        {x=0,y=0,z=0},
        {x=0,y=0,z=0},
        {x=0,y=0,z=0},
        {x=0,y=0,z=0}
    }
    vec3f_copy(gPlayerSyncTable[0].cvecs[6], l.pos)
    for i = 1, 4 do
        vec3f_rotate_zxy(corner[i], camrot)
        vec3f_add(corner[i], l.pos)
        djui_hud_world_pos_to_screen_pos(corner[i], screen[i])
        vec3f_copy(gPlayerSyncTable[0].cvecs[i], corner[i])
        l.posHSpeed = .1
        l.posVSpeed = .1
        l.focHSpeed = .1
        l.focVSpeed = .1
    end
    djui_hud_set_resolution(RESOLUTION_N64)
    vec3f_rotate_zxy(cursor, camrot)
    vec3f_add(cursor, l.pos)
    djui_hud_world_pos_to_screen_pos(cursor, screen[5])
    local normal = {x=0,y=0,z=0}
    vec3f_dif(normal, cursor, l.pos)
    vec3f_mul(normal, 30)
    --vec3f_normalize(normal)
    local ray = collision_find_surface_on_ray(l.pos.x, l.pos.y, l.pos.z, normal.x, normal.y, normal.z)
    vec3f_copy(cursor, ray.hitPos)
    vec3f_copy(target, ray.hitPos)
    vec3f_copy(gPlayerSyncTable[0].cvecs[5], cursor)

    --render_rect(screen[5], 20)
    --djui_hud_render_line(w/2, h/2, screen[5].x, screen[5].y, 10)
    djui_hud_set_resolution(RESOLUTION_N64)
    for i = 1, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            if gPlayerSyncTable[i].cvecs ~= nil then
                local m = gMarioStates
                local points = gPlayerSyncTable[i].cvecs
                local screen = {
                    {x=0,y=0,z=0},
                    {x=0,y=0,z=0},
                    {x=0,y=0,z=0},
                    {x=0,y=0,z=0},
                    {x=0,y=0,z=0},
                    {x=0,y=0,z=0}
                }
                for a = 1, 6 do
                    djui_hud_world_pos_to_screen_pos(points[a], screen[a])
                end
                djui_hud_render_line(screen[1].x, screen[1].y, screen[6].x, screen[6].y, 3)
                djui_hud_render_line(screen[2].x, screen[2].y, screen[6].x, screen[6].y, 3)
                djui_hud_render_line(screen[3].x, screen[3].y, screen[6].x, screen[6].y, 3)
                djui_hud_render_line(screen[4].x, screen[4].y, screen[6].x, screen[6].y, 3)
                djui_hud_render_line(screen[1].x, screen[1].y, screen[2].x, screen[2].y, 3)
                djui_hud_render_line(screen[2].x, screen[2].y, screen[4].x, screen[4].y, 3)
                djui_hud_render_line(screen[4].x, screen[4].y, screen[3].x, screen[3].y, 3)
                djui_hud_render_line(screen[3].x, screen[3].y, screen[1].x, screen[1].y, 3)
                djui_hud_render_line(screen[5].x, screen[5].y, screen[6].x, screen[6].y, 3)
                render_rect(screen[5], 5)
            end
        end
    end
end)