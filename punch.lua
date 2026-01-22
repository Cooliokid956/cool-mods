local values = {
    INTERACT_BOUNCE_TOP,
    INTERACT_BOUNCE_TOP2,
    INTERACT_DAMAGE,
    INTERACT_SHOCK,
    INTERACT_GRABBABLE,
    INTERACT_BREAKABLE,
    INTERACT_BULLY
}

local types = {}
for _, value in ipairs(values) do
    types[value] = true
end
---@param m MarioState
---@param o Object
---@param type InteractionType
function interact(m,o,type)
    print("mhm... "..type)
    if types[type] then
        print("goomba'd")
        spawn_sync_object(id_bhvGoomba,E_MODEL_NONE,o.oPosX,o.oPosY,o.oPosZ,function (obj)
            obj.header.gfx.sharedChild = o.header.gfx.sharedChild
        end)
        obj_set_behavior(o,get_behavior_from_id(id_bhvGoomba))
        print(o.behavior)
    end
    return true
end
hook_event(HOOK_ALLOW_INTERACT,interact)