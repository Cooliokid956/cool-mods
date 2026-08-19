-- TODO: get these set up for multiple marios
--       see what I can do with hook order

-----------------------------------------------

------------------
-- CLONE CONFIG --
------------------
-- local MAX_CLONES = 30*10
-- local CLONE_SPACING = 1
local MAX_CLONES = 30
local CLONE_SPACING = 1
local MAX_CLONE_CACHE = MAX_CLONES * CLONE_SPACING + 1

local sCloneTimestamp = {}
local sTimeStopCounter = 0
local sCloneStates = {}
local sRestoreBodyStates = {}
local MAX_PLAYERS = gServerSettings.maxPlayers
for i=0, MAX_PLAYERS-1 do
    sCloneTimestamp[i] = 0
    sCloneStates[i] = {}
end

-----------------------------------------------

local function bhv_clone_init(obj)
    -- obj.header.gfx.shadowInvisible = true
end

local function get_clone_cache(obj)
    return sCloneStates[obj.globalPlayerIndex][((get_area_update_counter() - sTimeStopCounter) - obj.oBehParams) % MAX_CLONE_CACHE]
end

local function bhv_clone_loop(obj)
    local c = get_clone_cache(obj)
    if not c then return end

    sCloneTimestamp[network_local_index_from_global(obj.globalPlayerIndex)] = get_area_update_counter()
    local gfx = obj.header.gfx
    local animInfo = gfx.animInfo
    animInfo.curAnim = c.anim
    animInfo.prevAnimPtr = c.prevAnim
    animInfo.animID = c.animID
    animInfo.animYTrans = c.animYTrans
    animInfo.animFrameAccelAssist = c.animFrameAccelAssist
    animInfo.animFrame = c.animFrame
    gfx.node.flags = c.gfxFlags
    gfx.node.extraFlags = c.gfxExtraFlags

    vec3f_copy(gfx.pos, c.pos)
    -- gfx.pos.x = gfx.pos.x + 20 * obj.oBehParams
    -- gfx.pos.x = gfx.pos.x + 60 * obj.oBehParams
    vec3s_copy(gfx.angle, c.angle)
    vec3f_copy(gfx.scale, c.scale)
end

id_bhvClone = hook_behavior(
    nil,
    OBJ_LIST_DEFAULT,
    true,
    bhv_clone_init,
    bhv_clone_loop
)

-----------------------------------------------
function duplicate_vec3(src) return { x = src.x, y = src.y, z = src.z } end

hook_event(HOOK_ON_OBJECT_RENDER, function (obj)
    local m = gMarioStates[network_local_index_from_global(obj.globalPlayerIndex)]
    if obj_has_behavior_id(obj, id_bhvClone) == 0
    or is_player_active(m) == 0 then return end
    local body = m.marioBodyState

    if not sRestoreBodyStates[m.playerIndex] then
        sRestoreBodyStates[m.playerIndex] = {
            action = body.action,
            cap = body.capState,
            eye = body.eyeState,
            hand = body.handState,
            punch = body.punchState,
            modelState = body.modelState,
            torso = duplicate_vec3(body.torsoAngle),
            head = duplicate_vec3(body.headAngle),
            head2 = duplicate_vec3(m.statusForCamera.headRotation),
        }
    end

    local c = get_clone_cache(obj)
    if c then
        body.action = c.action
        body.capState = c.cap
        body.eyeState = c.eye
        body.handState = c.hand
        body.punchState = c.punch
        body.modelState = c.modelState
        vec3s_copy(body.torsoAngle, c.torso)
        vec3s_copy(body.headAngle, c.head)
        vec3s_copy(m.statusForCamera.headRotation, c.head2)
    end
end)

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if is_player_active(m) == 0 then return end
    if sCloneTimestamp[m.playerIndex] < get_area_update_counter() - 1 then
        sCloneTimestamp[m.playerIndex] = get_area_update_counter()
        local model = obj_get_model_id_extended(m.marioObj)
        for i = 1, MAX_CLONES do
            spawn_non_sync_object(id_bhvClone, model, m.pos.x, m.pos.y, m.pos.z, function (obj)
                obj.oBehParams = i * CLONE_SPACING
                obj.globalPlayerIndex = network_global_index_from_local(m.playerIndex)
                obj.hookRender = 1
                obj_set_hitbox_radius_and_height(obj, m.marioObj.hitboxRadius, m.marioObj.hitboxHeight)
            end)
        end
    end

    local r = sRestoreBodyStates[m.playerIndex]
    if r then
        local body = m.marioBodyState
        body.action = r.action
        body.capState = r.cap
        body.eyeState = r.eye
        body.handState = r.hand
        body.punchState = r.punch
        body.modelState = r.modelState
        vec3s_copy(body.torsoAngle, r.torso)
        vec3s_copy(body.headAngle, r.head)
        vec3s_copy(m.statusForCamera.headRotation, r.head2)
        sRestoreBodyStates[m.playerIndex] = nil
    end
end)

hook_event(HOOK_MARIO_UPDATE, function (m)
    if is_player_active(m) == 0 then return end
    local gfx = m.marioObj.header.gfx
    local animInfo = gfx.animInfo
    local body = m.marioBodyState
    local cache = {
        animID = animInfo.animID,
        anim = animInfo.curAnim,
        prevAnim = animInfo.prevAnimPtr,
        animYTrans = animInfo.animYTrans,
        animFrameAccelAssist = animInfo.animFrameAccelAssist,
        animFrame = animInfo.animFrame,
        gfxFlags = gfx.node.flags,
        gfxExtraFlags = gfx.node.extraFlags,

        pos = duplicate_vec3(gfx.pos),
        angle = duplicate_vec3(gfx.angle),
        scale = duplicate_vec3(gfx.scale),

        action = body.action,
        cap = body.capState,
        eye = body.eyeState,
        hand = body.handState,
        punch = body.punchState,
        modelState = body.modelState,
        torso = duplicate_vec3(body.torsoAngle),
        head = duplicate_vec3(body.headAngle),
        head2 = duplicate_vec3(m.statusForCamera.headRotation)
    }
    if cache.eye == MARIO_EYES_BLINK then
        local blinkFrame = ((get_area_update_counter() + m.playerIndex * 32) >> 1) & 0x1F
        cache.eye = ({ 2, 3, 2, 1, 2, 3, 2 })[blinkFrame] or 1
        cache.blink = true
    end
    sCloneStates[m.playerIndex][(get_area_update_counter() - sTimeStopCounter) % MAX_CLONE_CACHE] = cache
end)

-- hook_event(HOOK_ON_SYNC_VALID, function ()
--     for i = 0, MAX_PLAYERS-1 do
--         local m = gMarioStates[i]
--         local model = obj_get_model_id_extended(m.marioObj)
--         for j = 1, 16 do
--             spawn_non_sync_object(id_bhvClone, model, m.pos.x, m.pos.y, m.pos.z, function (obj)
--                 obj.oBehParams = j * 3
--                 obj.globalPlayerIndex = network_global_index_from_local(i)
--                 obj.hookRender = 1
--             end)
--         end
--     end
-- end)

-- hook_event(HOOK_ON_LEVEL_INIT, function ()
--     for i = 0, MAX_PLAYERS-1 do
--         sCloneTimestamp[i] = false
--     end
-- end)

hook_event(HOOK_UPDATE, function ()
    -- if get_time_stop_flags() & TIME_STOP_ENABLED ~= 0 then
    --     sTimeStopCounter = sTimeStopCounter + 1
    -- end
end)