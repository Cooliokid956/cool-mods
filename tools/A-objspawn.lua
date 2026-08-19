-- name: ! Object Spawner ! 

local menuActive = false

local models = {}
local bhvs = {}
for name, value in pairs(_G) do
    if type(value) == "number" then
        if name:sub(1,7) == "E_MODEL" then
            models[name:sub(9)] = value
            print(name:sub(9))
        elseif name:sub(1,6) == "id_bhv" then
            bhvs[name:sub(7)] = value
            print(name:sub(7))
        end
    end
end

local model
local bhv
hook_chat_command("setmodel", "to set model", function (msg)
    if models[msg] then
        model = models[msg]
        djui_chat_message_create("Model ID: "..model)
    else
        djui_chat_message_create("...there's no such model.")
    end
    return true
end)
hook_chat_command("setbhv", "to set behavior", function (msg)
    if bhvs[msg] then
        bhv = bhvs[msg]
        djui_chat_message_create("Behavior ID: "..bhv)
    else
        djui_chat_message_create("...there's no such behavior.")
    end
    return true
end)
hook_chat_command("spawn", "the object", function ()
    local m = gMarioStates[0]
    spawn_sync_object(bhv, model, m.pos.x, m.pos.y, m.pos.z, nil)
    return true
end)