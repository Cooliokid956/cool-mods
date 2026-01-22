-- name: POV: Super Mario
-- description: in Super Mario 64

local status
gPlayerSyncTable[0].fp = true

local function fp_active(m) return (m.playerIndex ~= 0) and gPlayerSyncTable[m.playerIndex].fp or status end

local actionBlacklist = {
    [ACT_FALL_AFTER_STAR_GRAB] = 1,
    [ACT_STAR_DANCE_EXIT] = 1,
    [ACT_STAR_DANCE_NO_EXIT] = 1,
    [ACT_STAR_DANCE_WATER] = 1,
    [ACT_INTRO_CUTSCENE] = 1,
    [ACT_CREDITS_CUTSCENE] = 1,
    [ACT_JUMBO_STAR_CUTSCENE] = 1,
    -- [ACT_WARP_DOOR_SPAWN] = 1,
    -- [ACT_PULLING_DOOR] = 1,
    -- [ACT_PUSHING_DOOR] = 1,
    -- [ACT_UNLOCKING_KEY_DOOR] = 1,
    -- [ACT_UNLOCKING_STAR_DOOR] = 1,
    [ACT_READING_NPC_DIALOG] = 1,
    [ACT_WAITING_FOR_DIALOG] = 1,
    [ACT_EXIT_LAND_SAVE_DIALOG] = 1,
    [ACT_READING_AUTOMATIC_DIALOG] = 1
}

local cutsceneBlacklist = {
    -- [CUTSCENE_0F_UNUSED] = 1,
    [CUTSCENE_CAP_SWITCH_PRESS] = 1,
    [CUTSCENE_CREDITS] = 1,
    [CUTSCENE_DANCE_CLOSEUP] = 1,
    [CUTSCENE_DANCE_DEFAULT] = 1,
    [CUTSCENE_DANCE_FLY_AWAY] = 1,
    [CUTSCENE_DANCE_ROTATE] = 1,
    -- [CUTSCENE_DEATH_EXIT] = 1,
    -- [CUTSCENE_DEATH_ON_BACK] = 1,
    -- [CUTSCENE_DEATH_ON_STOMACH] = 1,
    [CUTSCENE_DIALOG] = 1,
    -- [CUTSCENE_DOOR_PULL] = 1,
    -- [CUTSCENE_DOOR_PULL_MODE] = 1,
    -- [CUTSCENE_DOOR_PUSH] = 1,
    -- [CUTSCENE_DOOR_PUSH_MODE] = 1,
    [CUTSCENE_DOOR_WARP] = 1,
    [CUTSCENE_ENDING] = 1,
    [CUTSCENE_END_WAVING] = 1,
    [CUTSCENE_ENTER_BOWSER_ARENA] = 1,
    [CUTSCENE_ENTER_CANNON] = 1,
    [CUTSCENE_ENTER_PAINTING] = 1,
    [CUTSCENE_ENTER_POOL] = 1,
    [CUTSCENE_ENTER_PYRAMID_TOP] = 1,
    [CUTSCENE_EXIT_BOWSER_DEATH] = 1,
    [CUTSCENE_EXIT_BOWSER_SUCC] = 1,
    [CUTSCENE_EXIT_FALL_WMOTR] = 1,
    [CUTSCENE_EXIT_PAINTING_SUCC] = 1,
    [CUTSCENE_EXIT_SPECIAL_SUCC] = 1,
    [CUTSCENE_EXIT_WATERFALL] = 1,
    [CUTSCENE_GRAND_STAR] = 1,
    [CUTSCENE_INTRO_PEACH] = 1,
    [CUTSCENE_KEY_DANCE] = 1,
    [CUTSCENE_NONPAINTING_DEATH] = 1,
    [CUTSCENE_PREPARE_CANNON] = 1,
    [CUTSCENE_QUICKSAND_DEATH] = 1,
    [CUTSCENE_RACE_DIALOG] = 1,
    [CUTSCENE_READ_MESSAGE] = 1,
    [CUTSCENE_RED_COIN_STAR_SPAWN] = 1,
    [CUTSCENE_SLIDING_DOORS_OPEN] = 1,
    [CUTSCENE_SSL_PYRAMID_EXPLODE] = 1,
    [CUTSCENE_STANDING_DEATH] = 1,
    [CUTSCENE_STAR_SPAWN] = 1,
    [CUTSCENE_SUFFOCATION_DEATH] = 1,
    [CUTSCENE_UNLOCK_KEY_DOOR] = 1,
    -- [CUTSCENE_UNUSED_EXIT] = 1,
    -- [CUTSCENE_WATER_DEATH] = 1
}

local function fp_cancel()
    local m = gMarioStates[0]
    -- djui_chat_message_create("Cutscene: "..((m.area and m.area.camera and m.area.camera.cutscene) or 0))
    if cutsceneBlacklist[(m.area and m.area.camera and m.area.camera.cutscene) or 0] then return false end
    -- if m.action & ACT_GROUP_CUTSCENE ~= 0 then return false end
    if actionBlacklist[m.action] then return false end
    if first_person_check_cancels(m) then return false end

    return true
end

local hurtTimer = 0
hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    local m = gMarioStates[0]
    if not fp_active(m) then return end
    if m.health - 0x40 * m.hurtCounter <= 0xff or m.hurtCounter > 0 then
        hurtTimer = 30
    end
    if hurtTimer > 0 then
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_color(255, 20, 20, (hurtTimer/30)*100)
        djui_hud_render_rect(0, 0, djui_hud_get_screen_width(), djui_hud_get_screen_height())
        hurtTimer = hurtTimer - 1
    end
end)

hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex == 0 and fp_active(m) then
        vec3f_copy(gFirstPersonCamera.offset, m.marioBodyState.headPos)
        vec3f_sub(gFirstPersonCamera.offset, m.pos)
        gFirstPersonCamera.offset.y = gFirstPersonCamera.offset.y - 50

        if m.marioBodyState.updateTorsoTime + 1 ~= get_global_timer() then vec3f_set(gFirstPersonCamera.offset, 0,0,0) end

        if m.health - 0x40 * m.hurtCounter <= 0xff then
            gFirstPersonCamera.forceRoll = false
            gLakituState.roll = 0x4000
            vec3f_set(gFirstPersonCamera.offset, 0,-80,0)
        else gFirstPersonCamera.forceRoll = true end

        if m.action == ACT_RAGDOLL then
            -- gLakituState.roll = m.faceAngle.z << 3
            gFirstPersonCamera.pitch = sins(m.faceAngle.x) * 0x3F00--<< 3
            gFirstPersonCamera.yaw = m.faceAngle.y --<< 3
        else
            m.faceAngle.y = gFirstPersonCamera.yaw + 0x8000
        end

        if m.marioObj and m.marioObj.platform then
            gFirstPersonCamera.yaw = gFirstPersonCamera.yaw + m.marioObj.platform.oAngleVelYaw
        end
    end
end)

function before_action(m, action)
    if fp_active(m) and m.playerIndex == 0 then
        if action == ACT_TRIPLE_JUMP then
            return ACT_DOUBLE_JUMP
        elseif action == ACT_WALL_KICK_AIR then
            gFirstPersonCamera.yaw = gFirstPersonCamera.yaw + 0x8000
        end
    end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_action)

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if not fp_active(m) then return end
    if m.playerIndex == 0 then

    end

    m.controller.stickX = m.controller.rawStickX/2
    m.controller.stickY = m.controller.rawStickY/2
    m.controller.stickMag = math.sqrt(m.controller.stickX^2+m.controller.stickY^2)
end)

function update_walking_speed_fp(m)
    local maxTargetSpeed = (m.floor and m.floor.type == SURFACE_SLOW) and 24 or 32
    local targetSpeed = m.intendedMag < maxTargetSpeed and m.intendedMag or maxTargetSpeed

    if m.quicksandDepth > 10 then
        targetSpeed = targetSpeed * (6.25 / m.quicksandDepth)
    end

    if m.forwardVel <= 0 then
        m.forwardVel = m.forwardVel + 1.1
    elseif m.forwardVel <= targetSpeed then
        m.forwardVel = m.forwardVel + 1.1 - m.forwardVel / 43
    elseif m.floor and m.floor.normal.y >= 0.95 then
        m.forwardVel = m.forwardVel - 1
    end

    if m.forwardVel > 48 then
        m.forwardVel = 48
    end

    -- m.faceAngle.y = m.intendedYaw - approach_s32((m.intendedYaw - m.faceAngle.y), 0, 0x1600, 0x1600)
    m.faceAngle.y = m.intendedYaw - approach_s32((m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)
    apply_slope_accel(m)

    m.vel.x = sins(m.intendedYaw) * m.forwardVel
    m.vel.z = coss(m.intendedYaw) * m.forwardVel
end

function act_walking(m)
    if not m then return 0 end
    local startPos = {x=0,y=0,z=0}
    local startYaw = m.faceAngle.y

    mario_drop_held_object(m)

    if should_begin_sliding(m) ~= 0 and not fp_active(m) then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    if m.input & INPUT_FIRST_PERSON ~= 0 and not fp_active(m) then
        return begin_braking_action(m)
    end

    if m.input & INPUT_A_PRESSED ~= 0 then
        if fp_active(m) and math.abs((m.intendedYaw - m.faceAngle.y)) > 0x4000 then m.forwardVel = -m.forwardVel end
        return set_jump_from_landing(m)
    end

    if check_ground_dive_or_punch(m) ~= 0 then
        return 1
    end

    if m.input & INPUT_ZERO_MOVEMENT ~= 0 then
        return begin_braking_action(m)
    end

    if analog_stick_held_back(m) ~= 0 and m.forwardVel >= 16 and not fp_active(m) then
        return set_mario_action(m, ACT_TURNING_AROUND, 0)
    end

    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_CROUCH_SLIDE, 0)
    end

    m.actionState = 0

    vec3f_copy(startPos, m.pos)
    if fp_active(m) then update_walking_speed_fp(m)
    else update_walking_speed(m) end

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
        set_character_animation(m, CHAR_ANIM_GENERAL_FALL)
    elseif step == GROUND_STEP_NONE then
        anim_and_audio_for_walk(m)
        if m.intendedMag - m.forwardVel > 16 then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
        end
    elseif step == GROUND_STEP_HIT_WALL then
        push_or_sidle_wall(m, startPos)
        m.actionTimer = 0
    end

    check_ledge_climb_down(m)
    tilt_body_walking(m, startYaw)
    return 0
end
hook_mario_action(ACT_WALKING, act_walking)

hook_chat_command("fp", "to enable first person", function ()
    gPlayerSyncTable[0].fp = not status
    djui_chat_message_create("First Person "..(not status and "ON" or "OFF"))
    return true
end)

hook_event(HOOK_UPDATE, function ()
    if (fp_cancel() and gPlayerSyncTable[0].fp) ~= status then
        status = not status
        set_first_person_enabled(status)
    end
end)