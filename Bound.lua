local function lerp(a,b,t) return a*(1-t)+b*t end
local function vec3f_lerp(v1, v2, t)
    return {
        x = lerp(v1.x, v2.x, t),
        y = lerp(v1.y, v2.y, t),
        z = lerp(v1.z, v2.z, t)
    }
end
function get_closest_edge(x, z, surf)
    local vx = {
    [0]=surf.vertex1.x,
        surf.vertex2.x,
        surf.vertex3.x
    }
    local vz = {
    [0]=surf.vertex1.z,
        surf.vertex2.z,
        surf.vertex3.z
    }

    local a = ((vz[0] - z) * (vx[1] - vx[0]) - (vx[0] - x) * (vz[1] - vz[0]))
    local b = ((vz[1] - z) * (vx[2] - vx[1]) - (vx[1] - x) * (vz[2] - vz[1]))
    local c = ((vz[2] - z) * (vx[0] - vx[2]) - (vx[2] - x) * (vz[0] - vz[2]))

    local max = math.min(a,b,c)

    if max == a then
        return { surf.vertex1, surf.vertex2 }
    elseif max == b then
        return { surf.vertex2, surf.vertex3 }
    else
        return { surf.vertex3, surf.vertex1 }
    end
end

hook_event(HOOK_ON_COLLIDE_LEVEL_BOUNDS, function (m)
    local edge = get_closest_edge(m.pos.x, m.pos.z, m.floor)
    if not edge then return end

    for i=0, 20 do
        local p = vec3f_lerp(edge[1], edge[2], math.random())
        spawn_sync_object(
            id_bhvCoinSparkles,
            E_MODEL_SPARKLES,
            p.x, p.y+math.random(250), p.z,
            nil)
    end
end)