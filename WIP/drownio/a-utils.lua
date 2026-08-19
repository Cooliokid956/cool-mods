function SEQUENCE_ARGS(priority, seqId) return ((priority << 8) | seqId) end

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

function easeOutSine(x) return math.sin((x * math.pi) / 2) end