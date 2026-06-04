-- name: OOB Shenaniganry
-- description: 

function ia(m) return m.playerIndex == 0 end
function pt(m) return gPlayerSyncTable[m.playerIndex] end

-- :p
local charLUT = {
    ["!"] = "exclamation",
    ["#"] = "hashtag",
    ["?"] = "question",
    ["&"] = "ampersand",
    ["%"] = "percent",
    ["@"] = "multiply",
    ["$"] = "coin",
    [","] = "comma",
    ["*"] = "star",
    ["."] = "period",
    ["^"] = "key",
    ["'"] = "apostrophe",
    ['"'] = "double_quote",
    ["/"] = "slash",
    ["-"] = "dash",
    ["~"] = "divide",
    ["+"] = "plus"
}

local function get_life_icon(m)
    local headtex = charSelect and charSelect.character_get_life_icon(m.playerIndex) or m.character.hudHeadTexture
    if type(headtex) == "string" then -- support strings
        headtex = get_texture_info("texture_hud_char_"..headtex) or get_texture_info("texture_hud_char_"..(charLUT[headtex] or "multiply"))
    end
    return headtex
end

---@type MarioState
local lm = gMarioStates[0]
for i = 0, MAX_PLAYERS-1 do
    gPlayerSyncTable[i].curMode = 3
end

function out_of_bounds(m)
    return m.floor and m.floor.object and obj_has_behavior_id(m.floor.object, id_bhvFloor) ~= 0
end

local ACT_DRIFT_OFF = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_AIR|ACT_FLAG_INTANGIBLE|ACT_FLAG_INVULNERABLE|ACT_FLAG_MOVING)

local TIMER_START_DEATH_SEQ = 20
---@param m MarioState
function act_drift_off(m)
    play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED)
    set_mario_animation(m, MARIO_ANIM_BEING_GRABBED)

    local step = perform_air_step(m, AIR_STEP_NONE)
    m.faceAngle.x, m.faceAngle.y = m.faceAngle.x + 1000, m.faceAngle.y + 100
    obj_set_gfx_angle(m.marioObj, m.faceAngle.x, m.faceAngle.y, 0)

    local shouldDie = m.actionTimer >= TIMER_START_DEATH_SEQ
    if out_of_bounds(m) or shouldDie then
        m.actionTimer = m.actionTimer + 1
    else -- no takesies backsies !!!!
        m.actionTimer = 0
    end

    if step == AIR_STEP_LANDED and (not out_of_bounds(m) or (m.playerIndex == 0 and pt(m).curMode == 1)) and not shouldDie then
        set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
    end

    if shouldDie then
        local timer = m.actionTimer - TIMER_START_DEATH_SEQ

        play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED)

        if ia(m) then
            gLakituState.posHSpeed = timer < 160 and gLakituState.posHSpeed*.07 or 1
            gLakituState.posVSpeed = timer < 160 and gLakituState.posVSpeed*.07 or 1

            if timer > 160 then
                vec3f_copy(gLakituState.goalPos, m.pos)
                vec3f_add(gLakituState.goalPos, m.vel)
            end

            if timer == 210 then
                play_character_sound(lm, CHAR_SOUND_OOOF)
            end

            if timer == 1 then
                stop_secondary_music(50)
                set_background_music(SEQ_PLAYER_LEVEL, SEQ_MENU_TITLE_SCREEN | SEQ_VARIATION, 0)
            end
            if timer == 100 then
                play_transition(WARP_TRANSITION_FADE_INTO_CIRCLE, 30, 0,0,0)
            end
            if timer == 170 then
                play_transition(WARP_TRANSITION_FADE_FROM_CIRCLE, 30, 0,0,0)
                stop_background_music(SEQ_MENU_TITLE_SCREEN | SEQ_VARIATION)
                disable_background_sound()
            end
        end
        if timer == 260 then
            level_trigger_warp(m, WARP_OP_WARP_FLOOR)
        end
    end

end
---@param m MarioState
function act_drift_gravity(m)
    if (m.actionArg == 0 or not out_of_bounds(m)) and not (m.actionTimer >= TIMER_START_DEATH_SEQ) then
        m.vel.y = m.vel.y - 4
        if m.vel.y < -75 then
            m.vel.y = -75
        end
    end
end
hook_mario_action(ACT_DRIFT_OFF, { every_frame = act_drift_off, gravity = act_drift_gravity })

local x, y, prevY

hook_event(HOOK_ON_HUD_RENDER, function ()
    if lm.action == ACT_DRIFT_OFF then

        djui_hud_set_resolution(RESOLUTION_N64)
        local timer = lm.actionTimer - TIMER_START_DEATH_SEQ
        if timer > 130 then
            djui_hud_set_color(0,0,0,255)
            djui_hud_render_rect(0, 0, 65535, 240)
        end
        x = djui_hud_get_screen_width()/2
        prevY = y
        y = (djui_hud_get_screen_height()/2) - 20 / (timer-160) + (timer > 210 and 80 / (timer-200) or 0)
        djui_hud_set_color(255, timer > 210 and math.min(16*(timer-210), 255) or 255, timer > 210 and math.min(16*(timer-210), 255) or 255, math.max(math.min(255, 16*(timer-160), -16*(timer-260)), 0))
        if timer > 160 then
            local headtex = get_life_icon(lm)
            djui_hud_set_font(FONT_HUD)

            djui_hud_render_texture_interpolated(headtex, x-20, prevY, 1/(headtex.width/16),1/(headtex.width/16), x-20, y, 1/(headtex.width/16),1/(headtex.width/16))
            djui_hud_print_text_interpolated("@", x-3, prevY, 1, x-3, y, 1)
            djui_hud_print_text_interpolated(tostring(lm.numLives - ((210 < timer and timer < 260) and 1 or 0)), x+13, prevY, 1, x+13, y, 1)
        end
        -- if timer == 210 then
        -- 	play_character_sound(lm, CHAR_SOUND_OOOF)
             --play_sound(lm.character.soundOoof, {x=0,y=0,z=0})
        -- end
    end
end)

function free_roam() return end
---@param m MarioState
function freefall_death_plane(m)
    if m.pos.y < m.floorHeight + 2048 then
        if level_trigger_warp(m, WARP_OP_WARP_FLOOR) == 20 and (m.flags & MARIO_UNKNOWN_18 == 0) then
            play_character_sound(m, CHAR_SOUND_WAAAOOOW)
        end
    end
end
---@param m MarioState
function zero_g_drift_off_death(m)
    if m.action ~= ACT_DRIFT_OFF then
        set_mario_action(m, ACT_DRIFT_OFF, 1)
    end
end
---@param m MarioState
function freefall_drift_off_death(m)
    if m.action ~= ACT_DRIFT_OFF then
        set_mario_action(m, ACT_DRIFT_OFF, 0)
    end
end

local mode = {
 -- id = {
 --     FREE_ROAM = 1,
 --     FREEFALL_DEATH_PLANE = 2,
 --     ZERO_G_DRIFT_OFF_DEATH = 3,
 --     FREEFALL_DRIFT_OFF_DEATH = 4
 -- },
    func = {
        free_roam,
        freefall_death_plane,
        zero_g_drift_off_death,
        freefall_drift_off_death
    },
    name = {
        "Free Roam",
        "Freefall (Death Plane)",
        "Zero-G (Drift-off Death)",
        "Freefall (Drift-off Death)"
    }
}

local COL_FLOOR = smlua_collision_util_get("limit_collision")

---@param o Object
function bhv_floor_init(o)
    o.collisionData = COL_FLOOR
end

col = nil
function bhv_floor_loop(o)
    o.oPosY = gLevelValues.floorLowerLimit + 1
    o.oPosX, o.oPosZ = 0,0
    obj_set_angle(o, 0,0,0)
    cur_obj_scale(1)
    if not col or ~col then
        col = load_static_object_collision()
    end
end

id_bhvFloor = hook_behavior(nil, OBJ_LIST_SURFACE, false, bhv_floor_init, bhv_floor_loop)

local outsidelevel = false
hook_event(HOOK_UPDATE, function ()
    if not obj_get_first_with_behavior_id(id_bhvFloor) then
        spawn_non_sync_object(id_bhvFloor, E_MODEL_NONE, 0,0,0,nil)
    end
    if out_of_bounds(lm) and not outsidelevel then
        play_secondary_music(0, 0, 0, 20)
        outsidelevel = true
    elseif not out_of_bounds(lm) and outsidelevel then
        stop_secondary_music(50)
        outsidelevel = false
    end
end)

hook_event(HOOK_MARIO_UPDATE, function (m)
    if out_of_bounds(m) then
        mode.func[pt(m).curMode](m)
    end
end)

hook_chat_command("oob-mode", "| Current mode: Zero-G (Drift-off Death)", function (msg)
    if mode.name[tonumber(msg)] then -- mode ID given
        pt(lm).curMode = tonumber(msg)
        djui_chat_message_create("Selected: "..mode.name[pt(lm).curMode])
        if lm.action == ACT_DRIFT_OFF then
            lm.actionArg = pt(lm).curMode == 3 and 1 or 0
        end
    return true end

    for i, name in ipairs(mode.name) do
        if msg == name then
            pt(lm).curMode = i
        return true end
    end

    local modeList = ""
    for i = 1, #mode.name do
        modeList = modeList.."\n"..mode.name[i]
    end
    djui_chat_message_create("Please provide a valid mode!\nAvailable modes:"..modeList)
    return true
end)