local smashmode = true
pause = {}
for i = 0, MAX_PLAYERS-1, 1 do
    pause[i] = {
        timer = nil,
        anim = nil,
        animFrame = nil,
        actionTimer = nil,
        pos = {x=0,y=0,z=0},
        vel = {x=0,y=0,z=0},
        forwardVel = 0
    }
end
local nothing = {x=0,y=0,z=0}
local values = {
    ACT_BACKWARD_GROUND_KB,
    ACT_SOFT_BACKWARD_GROUND_KB,
    ACT_BACKWARD_AIR_KB,
    ACT_HARD_BACKWARD_GROUND_KB,
    ACT_HARD_BACKWARD_AIR_KB,
    ACT_FORWARD_GROUND_KB,
    ACT_SOFT_FORWARD_GROUND_KB,
    ACT_FORWARD_AIR_KB,
    ACT_HARD_FORWARD_GROUND_KB,
    ACT_HARD_FORWARD_AIR_KB,
    16910512,
    ACT_THROWN_FORWARD,
    ACT_SHOCKED
}

local kb = {}
for _, value in ipairs(values) do
    kb[value] = true
end

--ACT_SMASH_KB = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_AIR)
--ACT_SMASH_PAUSE = allocate_mario_action(ACT_GROUP_STATIONARY|ACT_FLAG_INVULNERABLE)
--
--function act_smash_kb(m)
--    common_air_knockback_step(m, ACT_HARD_FORWARD_GROUND_KB,ACT_HARD_FORWARD_GROUND_KB,MARIO_ANIM_GENERAL_FALL,1)
--end
--function act_smash_pause(m)
--    print(m.actionTimer)
--    if m.actionArg ~= 0 then
--        set_mario_animation(m,MARIO_ANIM_SLOW_LONGJUMP)
--        set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.curAnim.loopEnd)
--    end
--    if m.actionTimer == 30 then
--        if m.actionArg == 1 then
--            return set_mario_action(m, m.prevAction, 0)
--        end
--        if m.vel.y > vec3f_length({x=m.vel.x,y=0,z=m.vel.z}) then
--            vec3f_mul(m.vel,gPlayerSyncTable[m.playerIndex].kbMult)
--            return set_mario_action(m, ACT_SMASH_KB,0)
--        else
--            return set_mario_action(m, m.prevAction, 0)
--        end
--    end
--    m.actionTimer = m.actionTimer + 1
--end
--hook_mario_action(ACT_SMASH_KB, act_smash_kb)
--hook_mario_action(ACT_SMASH_PAUSE, act_smash_pause)

local p = gPlayerSyncTable[0]
p.kbMult = 0
---@param m MarioState
function pausetime(m)
    m.health = 0x880
    local PI = m.playerIndex
    if vec3f_dist(nothing, pause[PI].vel) ~= 0 and pause[PI].timer == nil then
        if vec3f_length(pause[PI].vel) > 50 and m.vel.y > 0 then
            m.particleFlags = PARTICLE_DUST
        else
            vec3f_copy(pause[PI].vel, nothing)
        end
    end
    if pause[PI].timer == nil then return end
    print(pause[PI].timer)
    if pause[PI].timer > 0 then
        set_mario_animation(m,MARIO_ANIM_SLOW_LONGJUMP)
        set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.curAnim.loopEnd)
        m.actionTimer = pause[PI].actionTimer
        vec3f_copy(m.pos, pause[PI].pos)
        vec3f_copy(m.vel, nothing)
        m.forwardVel = 0
        pause[PI].timer = pause[PI].timer - 1
    elseif pause[PI].timer < 0 then
        set_mario_animation(m,pause[PI].anim)
        set_anim_to_frame(m, pause[PI].animFrame)
        m.actionTimer = pause[PI].actionTimer
        vec3f_copy(m.pos, pause[PI].pos)
        vec3f_copy(m.vel, nothing)
        m.forwardVel = 0
        pause[PI].timer = pause[PI].timer + 1
    elseif pause[PI].timer == 0 then
        vec3f_copy(m.pos, pause[PI].pos)
        vec3f_copy(m.vel, pause[PI].vel)
        m.actionTimer = pause[PI].actionTimer
        --vec3f_add(m.pos,m.vel)
        m.forwardVel = pause[PI].forwardVel
        if (m.action & ACT_FLAG_AIR) ~= 0 then
            local kbMult = gPlayerSyncTable[PI].kbMult or 0
            m.vel.x = m.vel.x * kbMult
            m.vel.z = m.vel.z * kbMult
            m.vel.y = m.vel.y * kbMult*2
            if vec3f_length(m.vel)>50 then
                m.particleFlags = PARTICLE_DUST
            end
        end
        pause[PI].timer = nil
    end
end

---@param attacker MarioState
---@param victim MarioState
---@return boolean
function onpvp(attacker,victim)
    if smashmode then
--        set_mario_action(attacker, ACT_SMASH_PAUSE, 1)
        local v = victim.playerIndex
        if pause[v].timer ~= nil then return false end
        pause[v].timer = 7
        print(victim.vel.y)
        if victim.vel.y > 0 then
            perform_air_step(victim,0)
        end
        vec3f_copy(pause[v].pos, victim.pos)
        vec3f_copy(pause[v].vel, victim.vel)
        pause[v].actionTimer = victim.actionTimer
        pause[v].forwardVel = victim.forwardVel
        
        local a = attacker.playerIndex
        pause[a].timer = -7
        vec3f_copy(pause[a].pos, attacker.pos)
        vec3f_copy(pause[a].vel, attacker.vel)
        pause[a].actionTimer = attacker.actionTimer
        pause[a].forwardVel = attacker.forwardVel
        pause[a].anim = attacker.marioObj.header.gfx.animInfo.animID
        pause[a].animFrame = attacker.marioObj.header.gfx.animInfo.animFrame
    end
    return true
end
function onhit(m,action)
    local n = nearest_mario_state_to_object(m.marioObj)
    if n ~= nil then
        if smashmode and kb[action] and (n.action & ACT_FLAG_ATTACKING) ~= 0 and dist_between_objects(m.marioObj,n.marioObj) < 200 then
            p.kbMult = p.kbMult + .04
            --      m.prevAction = action
            --      return ACT_SMASH_PAUSE
        end
    end
    if (action & ACT_FLAG_AIR) == 0 and m.vel.y > 0 then
        return 1
    end
    return true
end
hook_event(HOOK_ON_DEATH,function (m)
    p.kbMult = 0
end)
hook_event(HOOK_MARIO_UPDATE,pausetime)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,onhit)
hook_event(HOOK_ON_PVP_ATTACK,onpvp)
hook_event(HOOK_JOINED_GAME,function ()
    p.kbMult = 0
end)
hook_event(HOOK_ON_CHAT_MESSAGE,function (m,msg)
    if (msg:find("errormobile") or msg:find("error mobile") or msg:find("error")) and m.riddenObj ~= nil then
        obj_set_model_extended(m.riddenObj,E_MODEL_ERROR_MODEL)
    end
end)