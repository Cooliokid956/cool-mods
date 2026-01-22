-- name: Respawn
-- description: Respawns the player from the last entry point when killed

local sSpawnTypeFromWarpBhv = {
    [id_bhvDoorWarp]                = MARIO_SPAWN_DOOR_WARP,
    [id_bhvStar]                    = MARIO_SPAWN_UNKNOWN_02,
    [id_bhvExitPodiumWarp]          = MARIO_SPAWN_UNKNOWN_03,
    [id_bhvWarp]                    = MARIO_SPAWN_UNKNOWN_03,
    [id_bhvWarpPipe]                = MARIO_SPAWN_UNKNOWN_03,
    [id_bhvFadingWarp]              = MARIO_SPAWN_TELEPORT,
    [id_bhvInstantActiveWarp]       = MARIO_SPAWN_INSTANT_ACTIVE,
    [id_bhvAirborneWarp]            = MARIO_SPAWN_AIRBORNE,
    [id_bhvHardAirKnockBackWarp]    = MARIO_SPAWN_HARD_AIR_KNOCKBACK,
    [id_bhvSpinAirborneCircleWarp]  = MARIO_SPAWN_SPIN_AIRBORNE_CIRCLE,
    [id_bhvDeathWarp]               = MARIO_SPAWN_DEATH,
    [id_bhvSpinAirborneWarp]        = MARIO_SPAWN_SPIN_AIRBORNE,
    [id_bhvFlyingWarp]              = MARIO_SPAWN_FLYING,
    [id_bhvSwimmingWarp]            = MARIO_SPAWN_SWIMMING,
    [id_bhvPaintingStarCollectWarp] = MARIO_SPAWN_PAINTING_STAR_COLLECT,
    [id_bhvPaintingDeathWarp]       = MARIO_SPAWN_PAINTING_DEATH,
    [id_bhvAirborneStarCollectWarp] = MARIO_SPAWN_AIRBORNE_STAR_COLLECT,
    [id_bhvAirborneDeathWarp]       = MARIO_SPAWN_AIRBORNE_DEATH,
    [id_bhvLaunchStarCollectWarp]   = MARIO_SPAWN_LAUNCH_STAR_COLLECT,
    [id_bhvLaunchDeathWarp]         = MARIO_SPAWN_LAUNCH_DEATH
}

local function get_mario_spawn_type(o)
    local spawnType = sSpawnTypeFromWarpBhv[get_id_from_vanilla_behavior(o.behavior)]
    return spawnType or 0
end

local function set_mario_initial_cap_powerup(m)
    local capCourseIndex = gNetworkPlayers[0].currCourseNum

    if capCourseIndex == COURSE_COTMC then
        m.flags = m.flags | MARIO_METAL_CAP | MARIO_CAP_ON_HEAD
        m.capTimer = gLevelValues.metalCapDurationCotmc
    elseif capCourseIndex == COURSE_TOTWC then
        m.flags = m.flags | MARIO_WING_CAP | MARIO_CAP_ON_HEAD
        m.capTimer = gLevelValues.wingCapDurationTotwc
    elseif capCourseIndex == COURSE_VCUTM then
        m.flags = m.flags | MARIO_VANISH_CAP | MARIO_CAP_ON_HEAD
        m.capTimer = gLevelValues.vanishCapDurationVcutm
    end
end

local sActionFromSpawnType = {
    [MARIO_SPAWN_DOOR_WARP]             = ACT_WARP_DOOR_SPAWN,
    [MARIO_SPAWN_UNKNOWN_02]            = ACT_IDLE,
    [MARIO_SPAWN_UNKNOWN_03]            = ACT_EMERGE_FROM_PIPE,
    [MARIO_SPAWN_TELEPORT]              = ACT_TELEPORT_FADE_IN,
    [MARIO_SPAWN_INSTANT_ACTIVE]        = ACT_IDLE,
    [MARIO_SPAWN_AIRBORNE]              = ACT_SPAWN_NO_SPIN_AIRBORNE,
    [MARIO_SPAWN_HARD_AIR_KNOCKBACK]    = ACT_HARD_BACKWARD_AIR_KB,
    [MARIO_SPAWN_SPIN_AIRBORNE_CIRCLE]  = ACT_SPAWN_SPIN_AIRBORNE,
    [MARIO_SPAWN_DEATH]                 = ACT_FALLING_DEATH_EXIT,
    [MARIO_SPAWN_SPIN_AIRBORNE]         = ACT_SPAWN_SPIN_AIRBORNE,
    [MARIO_SPAWN_FLYING]                = ACT_FLYING,
    [MARIO_SPAWN_SWIMMING]              = ACT_WATER_IDLE,
    [MARIO_SPAWN_PAINTING_STAR_COLLECT] = ACT_EXIT_AIRBORNE,
    [MARIO_SPAWN_PAINTING_DEATH]        = ACT_DEATH_EXIT,
    [MARIO_SPAWN_AIRBORNE_STAR_COLLECT] = ACT_FALLING_EXIT_AIRBORNE,
    [MARIO_SPAWN_AIRBORNE_DEATH]        = ACT_UNUSED_DEATH_EXIT,
    [MARIO_SPAWN_LAUNCH_STAR_COLLECT]   = ACT_SPECIAL_EXIT_AIRBORNE,
    [MARIO_SPAWN_LAUNCH_DEATH]          = ACT_SPECIAL_DEATH_EXIT
}

function set_mario_initial_action(m, spawnType, actionArg)
    actionArg = spawnType == MARIO_SPAWN_DOOR_WARP and actionArg
           or ( spawnType == MARIO_SPAWN_FLYING    and 2
           or ( spawnType == MARIO_SPAWN_SWIMMING  and 1
           or (                                        0 )))

    set_mario_action(m, sActionFromSpawnType[spawnType], actionArg)

    set_mario_initial_cap_powerup(m)
end

local spawn
hook_event(HOOK_ON_WARP, function ()
    local obj = obj_get_first(OBJ_LIST_DEFAULT)
    while obj do
        local spawnType = sSpawnTypeFromWarpBhv[get_id_from_vanilla_behavior(obj.behavior)]
        if spawnType and dist_between_objects(gMarioStates[0].marioObj, obj) < 1 then break end
        obj = obj_get_next(obj)
    end
    spawn = obj
end)

-- edited player_respawn function from Arena
function player_respawn(m)
    -- reset most variables
    init_single_mario(m)

    if not spawn then spawn = area_get_warp_node(0xA).object end

    -- spawn location/angle
    m.pos.x = spawn.oPosX
    m.pos.y = spawn.oPosY
    m.pos.z = spawn.oPosZ
    m.faceAngle.y = spawn.oFaceAngleYaw

    -- reset the rest of the variables
    m.capTimer = 0
    m.health = 0x880
    soft_reset_camera(m.area.camera)
    stop_cap_music()

    set_mario_initial_action(m, get_mario_spawn_type(spawn))
    if m.flags & MARIO_METAL_CAP ~= 0 then
        play_cap_music(SEQUENCE_ARGS(4, SEQ_EVENT_METAL_CAP))
    end
    if m.flags & (MARIO_VANISH_CAP | MARIO_WING_CAP) ~= 0 then
        play_cap_music(SEQUENCE_ARGS(4, SEQ_EVENT_POWERUP))
    end

    return false
end
hook_event(HOOK_ON_DEATH, player_respawn)