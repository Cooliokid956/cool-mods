E_MODEL_EFFECT = smlua_model_util_get_id("effect_geo")
local size = {
    x = 1,
    y = 1,
    z = 1
}
---@param o Object
function bhv_effect_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end
---@param o Object
function bhv_effect_loop(o)
    o.oFaceAngleYaw = calculate_yaw(gLakituState.pos, gLakituState.focus)-32768
    obj_copy_pos(o, gMarioStates[0].marioObj)
    obj_scale_xyz(o, size.x, size.y, size.z)
end
id_bhvEffect = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhv_effect_init, bhv_effect_loop, "bhvEffect")

hook_chat_command("spawneffect", "to spawn effect", function ()
    if obj_get_first_with_behavior_id(id_bhvEffect) then
        djui_chat_message_create("ALREADY SPAWNED")
    return true end
    spawn_non_sync_object(id_bhvEffect, E_MODEL_EFFECT, 0,0,0, nil)
    return true
end)

hook_chat_command("offset", " ", function (msg)
    local o = obj_get_first_with_behavior_id(id_bhvEffect)
    if o and tonumber(msg) then
        o.oGraphYOffset = tonumber(msg)
    return true end
end)

function set_size(msg)
    if not string.find(msg, " ") then
        size.x = tonumber(msg)
        size.y = tonumber(msg)
        size.z = tonumber(msg)
        return true
    end
    local xyz = {"", "", ""}
    local index = 1
    for i = 1, #msg do
        local currentLetter = msg:sub(i, i)
        if tonumber(currentLetter) or currentLetter == "." or currentLetter == "-" then
            xyz[index] = xyz[index].. currentLetter
        else
            index = index + 1
        end
    end
    if index > 3 then
        return false
    end

    if tonumber(xyz[1]) then
        size.x = tonumber(xyz[1])
    else
        djui_chat_message_create("Size X not found.")
    end

    if tonumber(xyz[2]) then
        size.y = tonumber(xyz[2])
    else
        djui_chat_message_create("Size Y not found.")
    end

    if tonumber(xyz[3]) ~= nil then
        size.z = tonumber(xyz[3])
    else
        djui_chat_message_create("Size Z not found.")
    end
    return true
end
hook_chat_command("size", "[number (number number)]", set_size)