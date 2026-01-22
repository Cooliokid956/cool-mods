-- name: Death Stare
-- description: Look at me.

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

local enemies = {
    id_bhvGoomba,
    id_bhvBobomb,
    id_bhvKoopa
}

hook_event(HOOK_ON_HUD_RENDER, function ()
    local m = gMarioStates[0]
    -- if not (true) then return end -- always attack >:)

    djui_hud_set_resolution(RESOLUTION_N64)

    local minDist = gGlobalSyncTable.minDist or 1100

    local fp = get_first_person_enabled()
    if not fp then return end
    local mouse = {
        x = djui_hud_get_screen_width() /2,
        y = djui_hud_get_screen_height()/2,
        z = 0
    }

    local c = gLakituState.pos
    local enemy

    djui_hud_render_rect(mouse.x-1, mouse.y-1, 2, 2)
    for _, bhv in pairs(enemies) do
        enemy = obj_get_first_with_behavior_id(bhv)

        while enemy do
            local pos = vec3f()
            local enemyPos = obj_pos_to_vec3f(enemy)
            enemyPos.y = enemyPos.y + enemy.hitboxHeight/2 + enemy.hitboxDownOffset
            if djui_hud_world_pos_to_screen_pos(enemyPos, pos) then
                local size = -365/pos.z * enemy.hitboxHeight * (djui_hud_get_fov_coeff and djui_hud_get_fov_coeff() or 0)
                pos.z = 0
                djui_hud_render_rect(pos.x-size/2, pos.y-size/2, size, size)
                -- djui_hud_render_rect(pos.x, pos.y, size, size)
                if vec3f_dist(mouse, pos) < size/2 then
                    local ray = ray_from(c, enemyPos)
                    if not ray.surface and vec3f_dist(c, ray.hitPos) < minDist then
                        enemy.oInteractStatus = enemy.oInteractStatus | (ATTACK_KICK_OR_TRIP | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED)
                    end
                end
            end
            enemy = obj_get_next_with_same_behavior_id(enemy)
        end
    end
end)

if network_is_server() then
hook_chat_command("ds-min-dist", "[number]", function (msg)
    msg = tonumber(msg)

    if msg then
        gGlobalSyncTable.minDist = msg
    else djui_chat_message_create("Please enter a valid number") end
    return true
end)
end

hook_chat_command("override", "level", function (msg)
    network_player_set_override_location(gNetworkPlayers[0], msg)
    return true
end)