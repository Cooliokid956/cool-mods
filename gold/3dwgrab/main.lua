-- name: 3D World Player Grab

local g2l = network_local_index_from_global
local l2g = network_global_index_from_local

_G.ACT_3DW_GRABBED = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_AIR|ACT_FLAG_IDLE)

---@param m1 MarioState
---@param m2 MarioState
---@return boolean
local function is_grab_pair(m1, m2)
    return (m1.action == ACT_3DW_GRABBED and m1.actionArg == l2g(m2.playerIndex))
        or (m2.action == ACT_3DW_GRABBED and m2.actionArg == l2g(m1.playerIndex))
end

---@param m MarioState
---@return MarioState|nil
local function get_grabber_mario_state(m)
    return m.action == ACT_3DW_GRABBED and gMarioStates[g2l(m.actionArg)] or nil
end

---@param m MarioState
---@return MarioState|nil
local function get_grabbed_mario_state(m)
    for i=0, MAX_PLAYERS-1 do
        local g = gMarioStates[i]
        if (g.action == ACT_3DW_GRABBED and g.actionArg == l2g(m.playerIndex)) then
        return g end
    end
end

---@param o Object
---@return GraphNodeObject
local function GFX(o) return o.header.gfx end

local exitActs = {
    [ACT_PUSHING_DOOR]=1,
    [ACT_PULLING_DOOR]=1
}

---@param m MarioState
local function act_3dw_grabbed(m)
    local g = get_grabber_mario_state(m)

    -- failsafes
    if not g
    or exitActs[g.action]
    or g.action & ACT_GROUP_CUTSCENE ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end
    
    set_character_animation(m, CHAR_ANIM_FIRST_PERSON)

    -- copy grabber's physics
    vec3f_copy(m.pos, g.pos)
    m.pos.y = g.pos.y + g.marioObj.hitboxHeight

    vec3f_copy(m.vel, g.vel)
    m.forwardVel = g.forwardVel

    vec3s_copy(m.faceAngle, g.faceAngle)
    vec3s_copy(m.angleVel, g.angleVel)

    -- don't release instantly
    if m.actionTimer > 0 then m.actionTimer = m.actionTimer - 1 end
    -- throw on release
    if m.actionTimer < 1 and g.controller.buttonDown & (X_BUTTON | Y_BUTTON) == 0 then
        m.forwardVel = 30 + g.forwardVel
        m.vel.y = 15 + g.vel.y

        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    -- fall on grabber hurt
    if g.hurtCounter > 0 then
        return set_mario_action(m, g.action, 0)
    end

    -- jump off of grabber
    if m.controller.buttonDown & A_BUTTON ~= 0 then
        return set_mario_action(m, ACT_JUMP, 0)
    end
end
hook_mario_action(ACT_3DW_GRABBED, act_3dw_grabbed)

---@param m MarioState
---@param o Object
---@param int InteractionType
hook_event(HOOK_ALLOW_INTERACT, function (m, o, int)
    if int == INTERACT_PLAYER then
        local g = gMarioStates[g2l(o.globalPlayerIndex)]

        if is_grab_pair(m, g) then return false end
    end
end)

---@param m MarioState
---@param o Object
---@param int InteractionType
hook_event(HOOK_ON_INTERACT, function (m, o, int)
    if int == INTERACT_PLAYER then
        if m.controller.buttonPressed & (X_BUTTON | Y_BUTTON) ~= 0 then
            local angleToPlayer = obj_angle_to_object(m.marioObj, o)
            print(abs_angle_diff(m.faceAngle.y, angleToPlayer))
            if abs_angle_diff(m.faceAngle.y, angleToPlayer) < 0x2400 then
                local g = gMarioStates[g2l(o.globalPlayerIndex)]
                g.actionTimer = 12
                set_mario_action(g, ACT_3DW_GRABBED, l2g(m.playerIndex))
            end
        end
    end
end)

hook_event(HOOK_ALLOW_PVP_ATTACK, function (m, g)
    if m.action == ACT_3DW_GRABBED or is_grab_pair(m, g) then return false end
end)

local animOverride = {
    [CHAR_ANIM_GENERAL_FALL]          = CHAR_ANIM_GRAB_GENERAL_FALL,
    [CHAR_ANIM_SINGLE_JUMP]           = CHAR_ANIM_GRAB_SINGLE_JUMP,
    [CHAR_ANIM_LAND_FROM_SINGLE_JUMP] = CHAR_ANIM_GRAB_LAND_FROM_SINGLE_JUMP,
    [CHAR_ANIM_IDLE_HEAD_LEFT]        = CHAR_ANIM_GRAB_IDLE,
    [CHAR_ANIM_IDLE_HEAD_RIGHT]       = CHAR_ANIM_GRAB_IDLE,
    [CHAR_ANIM_IDLE_HEAD_CENTER]      = CHAR_ANIM_GRAB_IDLE,
    [CHAR_ANIM_FIRST_PERSON]          = CHAR_ANIM_GRAB_IDLE,
    [CHAR_ANIM_WALKING]               = CHAR_ANIM_GRAB_WALKING,
    [CHAR_ANIM_RUNNING]               = CHAR_ANIM_GRAB_RUNNING
}

local function fix_mario_visuals(m)
    -- fix everything once each mario's been processed
    if m.playerIndex == MAX_PLAYERS-1 then
        for i=0, MAX_PLAYERS-1 do
            local m = gMarioStates[i]
            if m.action == ACT_3DW_GRABBED then
                local g = get_grabber_mario_state(m)

                -- fix grabbed player's visuals
                local mGfx = GFX(m.marioObj)
                local gGfx = GFX(g.marioObj)
                vec3f_copy(mGfx.pos, gGfx.pos)
                mGfx.pos.y = mGfx.pos.y + g.marioObj.hitboxHeight
                mGfx.angle.y = gGfx.angle.y

                -- adjust grabber's animations
                local anim = animOverride[gGfx.animInfo.animID]
                if anim then set_character_animation(g, anim) end
            end
        end
    end
end
hook_event(HOOK_MARIO_UPDATE, fix_mario_visuals)