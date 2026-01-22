local m = gMarioStates[0]
bhv = "bhvSmallPenguin"
hook_chat_command("setbhv", "to set bhv", function (msg)
    if get_id_from_behavior_name(bhv) ~= id_bhv_max_count then
        bhv = msg
    else
        djui_chat_message_create("There's no such behavior!")
    end
    return true
end)
hook_chat_command("setp", " ", function (msg)
    local o = obj_get_nearest_object_with_behavior_id(m.marioObj, get_id_from_behavior_name(bhv))

    if o then
        if dist_between_objects(m.marioObj, o) < 900 then
            o.oAction = tonumber(msg)
        else
            djui_chat_message_create("Get closer!")
        end
    else
        djui_chat_message_create("There's nothing here.")
    end
    return true
end)
hook_event(HOOK_UPDATE, function()
    local o = obj_get_nearest_object_with_behavior_id(m.marioObj, get_id_from_behavior_name(bhv))

    if o and dist_between_objects(m.marioObj, o) < 900 then
        djui_chat_message_create(""..o.oAction)
    end
end)