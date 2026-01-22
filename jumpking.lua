-- name: Ninja Roy Moveset (it be a WIP)
local function limit_angle(a) return (a + 0x8000) % 0x10000 - 0x8000 end

local gRoyStates = {}
local s = 8

gPlayerSyncTable[0].roy = true
for i = 0, MAX_PLAYERS-1 do
    gRoyStates[i] = {
        wallBounce      = 0.5,
        lavaBounce      = 1.2,
        walkSpeed       = 4*s,

        launchSpeed     = 6*s,
        launchJumpPower = 16*s, -- JUMP

        wallSpeed       = 8*s,
        wallJumpPower   = 12*s, -- WALL_JUMP_HEIGHT

        jumpTime        = 0.6*30,
        maxFall         = -20*s,
        gravity         = 1*s,
        -- animStill = 1,
        -- animSmear = 1,
        -- fadeSteps = 4,
        -- scrollLength = 8 * 12,
    }
end

_G.ACT_NR_IDLE   = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT)
_G.ACT_NR_WALK   = allocate_mario_action(ACT_GROUP_MOVING     | ACT_FLAG_MOVING     | ACT_FLAG_ALLOW_FIRST_PERSON)
_G.ACT_NR_CHARGE = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY | ACT_FLAG_PAUSE_EXIT)
_G.ACT_NR_AIR    = allocate_mario_action(ACT_GROUP_AIRBORNE   | ACT_FLAG_AIR        | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
_G.ACT_NR_WALL   = allocate_mario_action(ACT_GROUP_AIRBORNE   | ACT_FLAG_AIR        | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
_G.ACT_NR_SPLAT  = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY | ACT_FLAG_INVULNERABLE)

local royActions = {
    [ACT_NR_IDLE] = 1,
    [ACT_NR_WALK] = 1,
    [ACT_NR_CHARGE] = 1,
    [ACT_NR_AIR] = 1,
    [ACT_NR_WALL] = 1,
    [ACT_NR_SPLAT] = 1
}

local function nr_jump(m)
    local r = gRoyStates[m.playerIndex]
    m.actionTimer = m.actionTimer + 1

    if m.actionTimer >= gRoyStates[m.playerIndex].jumpTime or m.input & INPUT_A_DOWN == 0 then
        local wallJump = m.action == ACT_NR_WALL
        if not wallJump and m.input & INPUT_NONZERO_ANALOG ~= 0 then m.faceAngle.y = m.intendedYaw end
        mario_set_forward_vel(m, wallJump and r.wallSpeed or (m.intendedMag/32 * r.launchSpeed))
        m.vel.y = (m.actionTimer / r.jumpTime) * (wallJump and r.wallJumpPower or r.launchJumpPower)

        play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, 0)
        return set_mario_action(m, ACT_NR_AIR, 0)
    end
    return 0
end

---@param m MarioState
hook_mario_action(ACT_NR_IDLE, function (m)
    set_character_animation(m, CHAR_ANIM_FIRST_PERSON)
    m.vel.y = 0

    if m.input & INPUT_A_DOWN ~= 0 then
        m.actionTimer = 0
        return set_mario_action(m, ACT_NR_CHARGE, 0)
    end
    if m.input & INPUT_NONZERO_ANALOG ~= 0 then
        return set_mario_action(m, ACT_NR_WALK, 0)
    end
end)

---@param m MarioState
hook_mario_action(ACT_NR_WALK, function (m)
    local r = gRoyStates[m.playerIndex]
    set_character_anim_with_accel(m, CHAR_ANIM_RUNNING, 0x00080000)

    m.faceAngle.y = m.intendedYaw
    mario_set_forward_vel(m, m.intendedMag/32 * r.walkSpeed)

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then
        return set_mario_action(m, ACT_NR_AIR, 0)
    end

    if m.input & INPUT_A_DOWN ~= 0 then
        m.actionTimer = 0
        return set_mario_action(m, ACT_NR_CHARGE, 0)
    end
    if m.input & INPUT_NONZERO_ANALOG == 0 then
        return set_mario_action(m, ACT_NR_IDLE, 0)
    end
end)

---@param m MarioState
hook_mario_action(ACT_NR_CHARGE, function (m)
    local r = gRoyStates[m.playerIndex]

    set_character_anim_with_accel(m, CHAR_ANIM_START_CROUCHING, 0x10000)
    -- set_anim_to_frame(m, 15)

    return nr_jump(m)
end)

---@param m MarioState
hook_mario_action(ACT_NR_AIR, { every_frame = function (m)
    local r = gRoyStates[m.playerIndex]
    set_character_animation(m, CHAR_ANIM_DOUBLE_JUMP_RISE)

    if m.vel.y <= r.maxFall then
        play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED)
    end

    local step = perform_air_step(m, 0)
    if step == AIR_STEP_LANDED then
        play_mario_landing_sound(m, SOUND_ACTION_TERRAIN_LANDING)
        return set_mario_action(m,
        (m.vel.y <= r.maxFall or m.actionArg == 1)
        and ACT_NR_SPLAT
        or ACT_NR_IDLE
        , 0)
    elseif step == AIR_STEP_HIT_WALL then
        if m.vel.y < -3 or not m.wall then
            mario_bonk_reflection(m, 0)
            mario_set_forward_vel(m, m.forwardVel * r.wallBounce)
            return
        else
            m.actionTimer = 0
            return set_mario_action(m, ACT_NR_WALL, 0)
        end
    elseif step == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m)
        m.action = ACT_NR_AIR
    end
end,
gravity = function (m)
    local r = gRoyStates[m.playerIndex]

    m.vel.y = math.max(m.vel.y - r.gravity, r.maxFall)
end})

---@param m MarioState
hook_mario_action(ACT_NR_WALL, function (m)
    play_sound_if_no_flag(m, SOUND_ACTION_HIT, MARIO_ACTION_SOUND_PLAYED)
    set_character_animation(m, CHAR_ANIM_START_WALLKICK)

    local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x)
    m.marioObj.header.gfx.angle.y = wallAngle
    if m.actionState == 0 then
        m.faceAngle.y = wallAngle * 2 - m.faceAngle.y + 0x8000
        m.actionState = 1
    elseif m.actionState == 1 and m.input & INPUT_A_DOWN ~= 0 then
        m.actionState = 2
    elseif m.actionState == 2 then
        return nr_jump(m)
    end
end)

---@param m MarioState
hook_mario_action(ACT_NR_SPLAT, function (m)
    if set_character_animation(m, CHAR_ANIM_FALL_OVER_BACKWARDS) == 43 then
        set_anim_to_frame(m, 42)
    end
    play_character_sound_if_no_flag(m, CHAR_SOUND_ATTACKED, MARIO_MARIO_SOUND_PLAYED)
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    -- set_anim_to_frame(m, 40)

    m.actionTimer = m.actionTimer + 1

    if m.actionTimer > 30 and m.input & (INPUT_A_DOWN | INPUT_NONZERO_ANALOG) ~= 0 then
        return set_mario_action(m, ACT_NR_IDLE, 0)
    end
end)

hook_chat_command("roy", "to toggle", function (msg)
    local roy = not gPlayerSyncTable[0].roy
    gPlayerSyncTable[0].roy = roy
    djui_chat_message_create("Ninja Roy is O"..(roy and "N" or "FF"))
    return true
end)

---@param m MarioState
hook_event(HOOK_MARIO_UPDATE, function (m)
    -- local roy = gPlayerSyncTable[m.playerIndex].roy
    -- if roy and not royActions[m.action]
    -- and m.action & ACT_GROUP_CUTSCENE == 0 then
    --     set_mario_action(m, (m.action & ACT_FLAG_AIR) and ACT_NR_AIR or ACT_NR_IDLE, 0)
    -- elseif not roy and royActions[m.action] then
    --     set_mario_action(m, (m.action & ACT_FLAG_AIR) and ACT_FREEFALL or ACT_IDLE, 0)
    -- end
    if m.playerIndex == 0 then
        local roy = gPlayerSyncTable[0].roy
        if roy and not royActions[m.action]
        and m.action & ACT_GROUP_CUTSCENE == 0 then
            set_mario_action(m, (m.action & ACT_FLAG_AIR) and ACT_NR_AIR or ACT_NR_IDLE, 0)
        elseif not roy and royActions[m.action] then
            set_mario_action(m, (m.action & ACT_FLAG_AIR) and ACT_FREEFALL or ACT_IDLE, 0)
        end
    end
end)

-------------- Interaction tweaks --------------

hook_event(HOOK_ALLOW_HAZARD_SURFACE, function (m, type)
    if gPlayerSyncTable[m.playerIndex].roy
    and type == HAZARD_TYPE_LAVA_FLOOR then
        local r = gRoyStates[m.playerIndex]
        m.vel.y = math.max(m.vel.y * r.lavaBounce, r.wallJumpPower * r.lavaBounce)

        m.hurtCounter = m.hurtCounter + ((m.flags & MARIO_CAP_ON_HEAD ~= 0) and 12 or 18)
        return false
    end
end)

hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function (m, action)
    if gPlayerSyncTable[m.playerIndex].roy then
        -- if action & ACT_FLAG_ON_POLE ~= 0 then
        if action == ACT_WALL_KICK_AIR and m.action & ACT_FLAG_ON_POLE ~= 0 then
            return ACT_NR_CHARGE
        end
    end
end)