-- name: knuckles chaotix ring tether mod in coop

function lerp(a, b, t) return a * (1 - t) + b * t end
function vec3f_lerp(a, b, t)
    return {
        x = lerp(a.x, b.x, t),
        y = lerp(a.y, b.y, t),
        z = lerp(a.z, b.z, t)
    }
end
function vec3f(x, y, z)
    return {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }
end

TETHER_MIN_DIST = 370
TETHER_MAX_SEG = 7
TETHER_SEG_DIST = 50
hook_chat_command("tether", "[ID]", function (msg)
    local id = tonumber(msg)
    if id and not gMarioStates[id] then id = nil end
    if not id and gPlayerSyncTable[0].tether then djui_chat_message_create("The tether was cut.")
    elseif id then djui_chat_message_create("Tethered to player "..id.."!")
    else djui_chat_message_create("There's no tether to cut.") end
    gPlayerSyncTable[0].tether = id and network_global_index_from_local(id)
    return true
end)

function get_tether_status(m)
    local id = gPlayerSyncTable[m.playerIndex].tether
    return id and network_local_index_from_global(id)
end

function update_tether(m)
    local lID = get_tether_status(m)
    local l
    if lID then
        l = gMarioStates[lID]
        if not get_tether_status(l) then
            l = nil
        end
    end

    if l then
        djui_chat_message_create("tethering player "..m.playerIndex.." with player "..l.playerIndex)
        -- insert tether stuff !!!!!!!
        if get_global_timer() % 4 == 0 then
            local segments = math.min(vec3f_dist(m.pos, l.pos) // TETHER_SEG_DIST, TETHER_MAX_SEG)
            djui_chat_message_create("segments: "..segments)
            for i = 1, segments do
                local pos = vec3f_lerp(m.pos, l.pos, i/(segments+1))
                local rand = vec3f()
                random_vec3s(rand, 10, 10, 10)
                vec3f_add(pos, rand)
                spawn_non_sync_object(id_bhvSparkleParticleSpawner, E_MODEL_SPARKLES, pos.x, pos.y, pos.z, nil)
            end
        end
    end
end
hook_event(HOOK_MARIO_UPDATE, update_tether)