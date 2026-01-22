-- name: Click the Star
-- description: Click the Star to Win

gGlobalSyncTable.minDist = 1100

local function vec3f(x, y, z)
    return {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }
end

local function obj_pos_to_vec3f(o)
    return vec3f(o.oPosX, o.oPosY, o.oPosZ)
end

local function ray_from(v1, v2)
    return collision_find_surface_on_ray(v1.x, v1.y, v1.z, v2.x-v1.x, v2.y-v1.y, v2.z-v1.z)
end

local starBhv = {
    id_bhvStar,
    id_bhvSpawnedStar,
    id_bhvSpawnedStarNoLevelExit,
    id_bhvStarSpawnCoordinates,
    id_bhvGrandStar
}

hook_event(HOOK_ON_HUD_RENDER, function ()
    local m = gMarioStates[0]
    if not m or m.controller.buttonPressed & A_BUTTON == 0 then return end -- not clicking; collect no stars

    djui_hud_set_resolution(RESOLUTION_DJUI)   -- mouse and screen position are wacky so we need to get
    local r = djui_hud_get_screen_height()/240 -- the ratio between the actual height and n64 height

    djui_hud_set_resolution(RESOLUTION_N64)

    local minDist = gGlobalSyncTable.minDist or 1100

    local fp = get_first_person_enabled()
    local mouse = {
        x = fp and djui_hud_get_screen_width() /2 or djui_hud_get_mouse_x()/r,
        y = fp and djui_hud_get_screen_height()/2 or djui_hud_get_mouse_y()/r,
        z = 0
    }

    local c = gLakituState.pos
    local star

    for _, bhv in pairs(starBhv) do
        star = obj_get_first_with_behavior_id(bhv)

        while star do
            local pos = vec3f()
            local size = -365/star.header.gfx.cameraToObject.z * star.hitboxHeight
            if djui_hud_world_pos_to_screen_pos({x=star.oPosX,y=star.oPosY,z=star.oPosZ}, pos) then
                pos.z = 0
                if vec3f_dist(mouse, pos) < size then
                    local ray = ray_from(c, obj_pos_to_vec3f(star))
                    if not ray.surface and vec3f_dist(c, ray.hitPos) < minDist then
                        obj_copy_pos(m.marioObj, star)
                    end
                end
            end
            star = obj_get_next_with_same_behavior_id(star)
        end
    end
end)

if network_is_server() then
hook_chat_command("min-dist", "[number]", function (msg)
    msg = tonumber(msg)

    if msg then
        gGlobalSyncTable.minDist = msg
    else djui_chat_message_create("Please enter a valid number") end
    return true
end)
end