-- name: Super Kaizo Drownio Road (0 Star Edition)
-- incompatible: romhack

gLevelValues.entryLevel = LEVEL_BOB
gLevelValues.fixCollisionBugs = true
gServerSettings.stayInLevelAfterStar = 0
gLevelValues.disableActs = true

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

smlua_audio_utils_replace_sequence(SEQ_LEVEL_SLIDE, 0x2A, 122, "rainbow")

local E_MODEL_KOTQ = smlua_model_util_get_id("kotq_geo")
local COL_KOTQ = smlua_collision_util_get("kotq_collision")

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~(HUD_DISPLAY_FLAG_LIVES | HUD_DISPLAY_FLAG_COIN_COUNT))
end)

hook_event(HOOK_MARIO_UPDATE, function (m)
    m.numLives = 5
end)

---@param o Object
function bhv_kotq_endpoint_loop(o)
    local koop = obj_get_nearest_object_with_behavior_id(o, id_bhvKoopOfTheQuick)
    local player = gMarioStates[0].marioObj
    local distanceToPlayer = player and dist_between_objects(o, player) or 10000
    if o.oAction == 1 then
        if koop.oAction == KOTQ_ACT_RACE and distanceToPlayer < 400 then
            play_race_fanfare()
            o.oAction = 2
        end
    end
end
id_bhvKoopRaceEndpoint = hook_behavior(nil, OBJ_LIST_LEVEL, false, nil, bhv_kotq_endpoint_loop, "bhvKoopRaceEndpoint")

---@param o Object
function bhv_koop_of_the_quick_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO
    o.collisionData = COL_KOTQ
    obj_set_model_extended(o, E_MODEL_KOTQ)
    cur_obj_set_home_once()
end

KOTQ_ACT_WAIT_RACE = 0
KOTQ_ACT_TALK = 1
KOTQ_ACT_WIND_UP = 2
KOTQ_ACT_RACE = 3
KOTQ_ACT_WAIT_FINISH = 4
KOTQ_ACT_FINISH_RACE = 5
KOTQ_ACT_END = 6

---@param o Object
function bhv_koop_of_the_quick_loop(o)
    -- local m = gMarioStates[0]
    local m = nearest_mario_state_to_object(o)
    local flag = obj_get_nearest_object_with_behavior_id(o, id_bhvKoopRaceEndpoint)
    if o.oAction == KOTQ_ACT_WAIT_RACE then
        -- obj_turn_toward_object(o, m.marioObj, 0x13, 0x800)
        if m.playerIndex == 0 and cur_obj_can_mario_activate_textbox_2(m, 400, 400) ~= 0 then
            o.oAction = KOTQ_ACT_TALK
        end
    elseif o.oAction == KOTQ_ACT_TALK then
        local updateDialog = should_start_or_continue_dialog(m, o) ~= 0
        if updateDialog and cutscene_object_with_dialog(CUTSCENE_DIALOG, o, DIALOG_005) ~= 0 then
            o.oAction = KOTQ_ACT_WIND_UP
        end
    elseif o.oAction == KOTQ_ACT_WIND_UP then
        if o.oTimer == 50 then
            cur_obj_play_sound_2(SOUND_GENERAL_RACE_GUN_SHOT)
            play_music(SEQ_PLAYER_LEVEL, SEQUENCE_ARGS(4, SEQ_LEVEL_SLIDE), 0)

            hud_set_value(HUD_DISPLAY_TIMER, 0)
            hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) | HUD_DISPLAY_FLAG_TIMER)

            if flag then flag.oAction = 1 end
            o.oAction = KOTQ_ACT_RACE
        end
    elseif o.oAction == KOTQ_ACT_RACE then
        local homePos = vec3f(o.oHomeX, o.oHomeY, o.oHomeZ)
        local endPos = vec3f()
        object_pos_to_vec3f(endPos, flag)

        local target = vec3f_lerp(homePos, endPos, easeOutSine(o.oTimer/(30*30)))
        vec3f_to_object_pos(o, target)

        local vel = target
        vec3f_sub(vel, vec3f_lerp(homePos, endPos, easeOutSine((o.oTimer-1)/(30*30))))
        obj_set_vel(o, vel.x, vel.y, vel.z)

        if flag and flag.oAction == 1 then
            hud_set_value(HUD_DISPLAY_TIMER, o.oTimer)
        end

        if o.oTimer == 30*30 then
            obj_set_vel(o, 0, 0, 0)
            o.oAction = KOTQ_ACT_WAIT_FINISH
        end
    elseif o.oAction == KOTQ_ACT_WAIT_FINISH then
        if m.playerIndex == 0 and cur_obj_can_mario_activate_textbox_2(m, 400, 400) ~= 0 then
            o.oAction = KOTQ_ACT_FINISH_RACE
        end
    elseif o.oAction == KOTQ_ACT_FINISH_RACE then
        local lost = flag.oAction == 1

        local updateDialog = should_start_or_continue_dialog(m, o) ~= 0
        if updateDialog and cutscene_object_with_dialog(CUTSCENE_DIALOG, o, lost and DIALOG_041 or DIALOG_007) ~= 0 then
            if not lost then
                spawn_default_star(o.oPosX, o.oPosY + 300, o.oPosZ)
            end
            o.oAction = KOTQ_ACT_END
        end
    end

    load_object_collision_model()
end
id_bhvKoopOfTheQuick = hook_behavior(nil, OBJ_LIST_SURFACE, false, bhv_koop_of_the_quick_init, bhv_koop_of_the_quick_loop, "bhvKoopOfTheQuick")

local quicksand_frame = {
    get_texture_info("quicksand1"),
    get_texture_info("quicksand2"),
    get_texture_info("quicksand3"),
    get_texture_info("quicksand2")
}
function animate_quicksand()
    texture_override_set("sky_09008000", quicksand_frame[(get_global_timer() // 6) % #quicksand_frame + 1])
end
hook_event(HOOK_UPDATE, animate_quicksand)