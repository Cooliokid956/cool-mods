E_MODEL_HAND1 = smlua_model_util_get_id("hand1_geo")
---@param o Object
function hand_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_scale(1.0)
    network_init_object(o,true,nil)
end
---@param o Object
function hand_loop(o)
    local ray = collision_find_surface_on_ray()
    if o.oAction == 0 then -- general movement
        
    elseif o.oAction == 1 then
        
    elseif o.oAction == 2 then
        
    elseif o.oAction == 3 then
        
    end
end

id_bhvGMHand = hook_behavior(nil, OBJ_LIST_DEFAULT,true,hand_init,hand_loop)
HOOK_ONP