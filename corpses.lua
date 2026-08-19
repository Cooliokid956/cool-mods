-- name: Corpses

-----------------------------------------------

local np = gNetworkPlayers[0]

local sCorpseStates = {}
local sRestoreBodyStates = {}

-----------------------------------------------

local function bhv_corpse_init(obj)
    -- obj.header.gfx.shadowInvisible = true
end

local function get_corpse_state(obj)
    return sCorpseStates[np.currLevelNum][np.currAreaIndex][np.currActNum][obj.oBehParams]
end

local function bhv_corpse_loop(obj)
    local c = get_corpse_state(obj)
    if not c then return end

    local gfx = obj.header.gfx
    local animInfo = gfx.animInfo
    if type(c.anim) == "string" then
        smlua_anim_util_set_animation(obj, c.anim)
    else animInfo.curAnim = get_mario_vanilla_animation(c.anim) end
    -- animInfo.prevAnimPtr = c.prevAnim
    -- animInfo.animID = c.animID
    animInfo.animYTrans = c.animYTrans
    animInfo.animFrameAccelAssist = c.animFrameAccelAssist
    animInfo.animFrame = c.animFrame
    gfx.node.flags = c.gfxFlags
    -- gfx.node.extraFlags = c.gfxExtraFlags

    vec3f_copy(gfx.pos, c.pos)
    -- gfx.pos.x = gfx.pos.x + 20 * obj.oBehParams
    -- gfx.pos.x = gfx.pos.x + 60 * obj.oBehParams
    vec3s_copy(gfx.angle, c.angle)
    vec3f_copy(gfx.scale, c.scale)
end

id_bhvCorpse = hook_behavior(
    nil,
    OBJ_LIST_DEFAULT,
    true,
    bhv_corpse_init,
    bhv_corpse_loop
)

-----------------------------------------------
function duplicate_vec3(src) return { x = src.x, y = src.y, z = src.z } end

hook_event(HOOK_ON_OBJECT_RENDER, function (obj)
    local m = gMarioStates[network_local_index_from_global(obj.globalPlayerIndex)]
    if obj_has_behavior_id(obj, id_bhvCorpse) == 0 then return end
    local body = m.marioBodyState

    if not sRestoreBodyStates[m.playerIndex] then
        sRestoreBodyStates[m.playerIndex] = {
            -- action = body.action,
            cap = body.capState,
            eye = body.eyeState,
            hand = body.handState,
            -- punch = body.punchState,
            modelState = body.modelState,
            -- torso = duplicate_vec3(body.torsoAngle),
            -- head = duplicate_vec3(body.headAngle),
            -- head2 = duplicate_vec3(m.statusForCamera.headRotation),
        }
    end

    local c = get_corpse_state(obj)
    if c then
        -- body.action = c.action
        body.capState = c.cap
        body.eyeState = c.eye
        body.handState = c.hand
        -- body.punchState = c.punch
        body.modelState = c.modelState
        -- vec3s_copy(body.torsoAngle, c.torso)
        -- vec3s_copy(body.headAngle, c.head)
        -- vec3s_copy(m.statusForCamera.headRotation, c.head2)
    end
end)

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if is_player_active(m) == 0 then return end

    local r = sRestoreBodyStates[m.playerIndex]
    if r then
        local body = m.marioBodyState
        -- body.action = r.action
        body.capState = r.cap
        body.eyeState = r.eye
        body.handState = r.hand
        -- body.punchState = r.punch
        body.modelState = r.modelState
        -- vec3s_copy(body.torsoAngle, r.torso)
        -- vec3s_copy(body.headAngle, r.head)
        -- vec3s_copy(m.statusForCamera.headRotation, r.head2)
        sRestoreBodyStates[m.playerIndex] = nil
    end
end)

local function spawn_corpse(i, c)
    spawn_non_sync_object(id_bhvCorpse, c.model, c.pos.x, c.pos.y, c.pos.z, function (obj)
        obj.oBehParams = i
        obj.globalPlayerIndex = c.index
        obj.hookRender = 1
    end)
end

local function add_corpse(c)
    if not sCorpseStates[c.level] then
        sCorpseStates[c.level] = {}
    end
    local lvl = sCorpseStates[c.level]
    if not lvl[c.area] then
        lvl[c.area] = {}
    end
    lvl = lvl[c.area]
    if not lvl[c.act] then
        lvl[c.act] = {}
    end
    lvl = lvl[c.act]
    c.level, c.area, c.act = nil

    lvl[#lvl+1] = c
    spawn_corpse(#lvl, c)
end

hook_event(HOOK_ON_DEATH, function (m)
    local gfx = m.marioObj.header.gfx
    local animInfo = gfx.animInfo
    local body = m.marioBodyState
    local corpse = {
        level = np.currLevelNum,
        area = np.currAreaIndex,
        act = np.currActNum,
        index = network_global_index_from_local(0),

        model = obj_get_model_id_extended(m.marioObj),
        anim = smlua_anim_util_get_current_animation_name(m.marioObj) or animInfo.animID,
        -- prevAnim = animInfo.prevAnimPtr,
        animYTrans = animInfo.animYTrans,
        animFrameAccelAssist = animInfo.animFrameAccelAssist,
        animFrame = animInfo.animFrame,
        gfxFlags = gfx.node.flags,
        -- gfxExtraFlags = gfx.node.extraFlags,

        pos = duplicate_vec3(gfx.pos),
        angle = duplicate_vec3(gfx.angle),
        scale = duplicate_vec3(gfx.scale),

        -- action = body.action,
        cap = body.capState,
        eye = body.eyeState,
        hand = body.handState,
        -- punch = body.punchState,
        modelState = body.modelState,
        -- torso = duplicate_vec3(body.torsoAngle),
        -- head = duplicate_vec3(body.headAngle),
        -- head2 = duplicate_vec3(m.statusForCamera.headRotation)
    }
    if corpse.eye == MARIO_EYES_BLINK then
        local blinkFrame = ((get_area_update_counter() + m.playerIndex * 32) >> 1) & 0x1F
        corpse.eye = ({ 2, 3, 2, 1, 2, 3, 2 })[blinkFrame] or 1
        corpse.blink = true
    end
    network_send(true, corpse)
    add_corpse(corpse)
end)

hook_event(HOOK_ON_PACKET_RECEIVE, function (c)
    add_corpse(c)
end)

hook_event(HOOK_ON_SYNC_VALID, function ()
    local corpses = sCorpseStates[np.currLevelNum]
    if not corpses then return end
    corpses = corpses[np.currAreaIndex]
    if not corpses then return end
    corpses = corpses[np.currActNum]
    if not corpses then return end
    for i, c in ipairs(corpses) do
        spawn_corpse(i, c)
    end
end)