-- name: Sling

local E_MODEL_SLING_END = smlua_model_util_get_id("sling_end_geo")
local E_MODEL_SLING_LINE = smlua_model_util_get_id("sling_line_geo")

--- @param o Object
function bhv_sling_end_loop(o)
    local scale = o.header.gfx.scale.x
    cur_obj_scale(scale + (o.oHealth/200 - scale)*.4)
    if scale < 0 then
        obj_mark_for_deletion(o)
        obj_mark_for_deletion(o.prevObj)
    end
end

--- @param o Object
function bhv_sling_line_loop(o)
    local mObj = o.usingObj
    obj_turn_toward_object(o, mObj, 0x12, 32767)
    obj_turn_toward_object(o, mObj, 0x13, 32767)
    o.oFaceAngleRoll = o.oFaceAngleRoll + 0x2000

    local scale = o.header.gfx.scale.x
    scale = scale + (o.oHealth/600 - scale)*.4
    obj_scale_xyz(o, scale, scale, dist_between_objects(o, mObj)/100)
end

---

_G.ACT_CM_SLING = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
hook_mario_action(ACT_CM_SLING, function (m)
    local mObj = m.marioObj
    if not m.riddenObj then
        local pos = m.pos
        m.riddenObj = spawn_non_sync_object(bhvSlingEnd, E_MODEL_SLING_END, pos.x, pos.y, pos.z, function (o)
            o.parentObj = spawn_non_sync_object(bhvSlingLine, E_MODEL_SLING_LINE, pos.x, pos.y, pos.z, function (l)
                l.parentObj = o
                l.usingObj = mObj
                -- o.p
            end)
        end)
    end

    common_air_action_step(m, ACT_BUTT_SLIDE, CHAR_ANIM_IDLE_ON_POLE, 0)
    mObj.header.gfx.angle.x = obj_pitch_to_object(mObj, m.riddenObj) + 0x4000
    mObj.header.gfx.angle.y = obj_angle_to_object(mObj, m.riddenObj)
end)

hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.controller.buttonDown & Y_BUTTON ~= 0 then
        set_mario_action(m, ACT_CM_SLING, 0)
    end
end)

