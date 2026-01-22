local min = {x = 0, y = 0, z = 0}
local max = {x = 0, y = 0, z = 0}
local lm = gMarioStates[0]
local p = gNetworkPlayers[0]
local cam = {x=0,y=0,z=0}
local levels = {
    [LEVEL_HYRULE] = true
}
function updatecam(o)
if o.playerIndex ~= 0 or not levels[p.currLevelNum] then return end
    min.x = lm.pos.x
    max.x = lm.pos.x
    min.y = lm.pos.y
    max.y = lm.pos.y
    for i = 1, MAX_PLAYERS-2, 1 do
        if gNetworkPlayers[i].connected then
        local m = gMarioStates[i]
        min.x = math.min(min.x,m.pos.x)
        min.y = math.min(min.y,m.pos.y)
        max.x = math.max(max.x,m.pos.x)
        max.y = math.max(max.y,m.pos.y)
        end
    end

    cam.x = cam.x + ((min.x+max.x)/2-cam.x)*.1
    cam.y = cam.y + ((min.y+max.y)/2+120-cam.y)*.1
    cam.z = cam.z + (math.max(vec3f_dist(min,max)*1.6,900)-cam.z)*.1
    vec3f_copy(gLakituState.goalFocus,cam)
    vec3f_copy(gLakituState.curFocus,cam)
    vec3f_copy(gLakituState.focus,cam)
    vec3f_copy(lm.area.camera.focus,cam)
    gLakituState.posHSpeed = 0
    gLakituState.posVSpeed = 0
    gLakituState.focHSpeed = 0
    gLakituState.focVSpeed = 0
    vec3f_copy(gLakituState.goalPos,cam)
    vec3f_copy(gLakituState.curPos,cam)
    vec3f_copy(gLakituState.pos,cam)
    vec3f_copy(lm.area.camera.pos,cam)
    gLakituState.goalFocus.z = 0
    gLakituState.curFocus.z = 0
    gLakituState.focus.z = 0
    if pause[0].timer ~= nil then
        camera_freeze()
        enable_time_stop_including_mario()
    else
        camera_unfreeze()
        disable_time_stop_including_mario()
    end
end
hook_event(HOOK_MARIO_UPDATE,updatecam)
sOverrideCameraModes = {
    [CAMERA_MODE_RADIAL]            = true,
    [CAMERA_MODE_OUTWARD_RADIAL]    = true,
    [CAMERA_MODE_CLOSE]             = true,
    [CAMERA_MODE_SLIDE_HOOT]        = true,
    [CAMERA_MODE_PARALLEL_TRACKING] = true,
    [CAMERA_MODE_FIXED]             = true,
    [CAMERA_MODE_FREE_ROAM]         = true,
    [CAMERA_MODE_SPIRAL_STAIRS]     = true,
    [CAMERA_MODE_ROM_HACK]          = true,
}
function on_set_camera_mode(c, mode, frames)
    if levels[p.currLevelNum] and sOverrideCameraModes[mode] ~= nil and mode ~= CAMERA_MODE_NONE then
        -- do not allow change
        set_camera_mode(c, CAMERA_MODE_NONE, frames)
        return false
    end
end
hook_event(HOOK_ON_SET_CAMERA_MODE, on_set_camera_mode)