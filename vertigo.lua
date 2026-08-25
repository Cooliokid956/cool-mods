-- name: Vertigo effect
-- description: try moving your stick up and down

-- local blobs
local geo_get_current_master_list, geo_get_current_perspective, vec3f_copy, vec3f_sub, vec3f_mul, vec3f_add, vec3f_dist, set_override_fov, set_override_near, set_override_far = geo_get_current_master_list, geo_get_current_perspective, vec3f_copy, vec3f_sub, vec3f_mul, vec3f_add, vec3f_dist, set_override_fov, set_override_near, set_override_far
local max = math.max
local fov = gFOVState
local l = gLakituState

local zoomFac = 1
local speedZoom = 0
local master
local persp

local prevShakeMag = 0

hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex ~= 0 then return end
    vec3f_copy(l.pos, l.curPos)

    if not master or ~master then
        if m.marioObj.hookRender ~= 0 then
            m.marioObj.hookRender = 1
        end
    end

    if speedZoom > 0 then
        zoomFac = max(zoomFac + ((1 - m.forwardVel*speedZoom) - zoomFac)*.1, fov.fov/170)
    end
end)

hook_event(HOOK_ON_OBJECT_RENDER, function ()
    master = geo_get_current_master_list().node
    master.hookProcess = 1
    persp = geo_get_current_perspective()
end)

hook_event(HOOK_BEFORE_GEO_PROCESS, function (node)
    if node ~= master then return end
    vec3f_sub(l.pos, l.focus)
    vec3f_mul(l.pos, zoomFac)
    vec3f_add(l.pos, l.focus)

    -- soften shakes at low FOVs
    if fov.shakeAmplitude > prevShakeMag then
        fov.shakeAmplitude = fov.shakeAmplitude / zoomFac
    end
    prevShakeMag = fov.shakeAmplitude

    set_override_fov(fov.fov / zoomFac)

    local offset = vec3f_dist(l.curPos, l.pos) * (zoomFac > 1 and 1 or -1)
    set_override_near(max(0.1,persp.near + offset))
    set_override_far(persp.far + offset)

    zoomFac = max(zoomFac + gControllers[0].extStickY/1e3*zoomFac, fov.fov/170)
end)

hook_chat_command("speed-zoom", "[NUMBER] - set speed zoom strength (0 to turn off, .01 recommended)", function (msg)
    speedZoom = tonumber(msg) or 0
    return true
end)