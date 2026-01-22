local djui = false
local v3f = {x=0,y=0,z=0}
function loop(m)
    if gMarioStates[0].controller.buttonDown & U_JPAD ~= 0 then
        djui_hud_set_resolution(RESOLUTION_DJUI)
    else
        djui_hud_set_resolution(RESOLUTION_N64)
    end
    object_pos_to_vec3f(v3f,obj_get_nearest_object_with_behavior_id(m.marioObj,id_bhvChainChomp))
    local yn = djui_hud_world_pos_to_screen_pos(v3f,v3f)
    if yn then
       -- print("yes.")
    else
        --print("no.")
    end
end
function hud()
    if gMarioStates[0].controller.buttonDown & U_JPAD ~= 0 then
        djui_hud_set_resolution(RESOLUTION_DJUI)
    else
        djui_hud_set_resolution(RESOLUTION_N64)
    end
    djui_hud_render_rect(v3f.x,v3f.y,10,10)
    djui_hud_print_text(v3f.x.." "..v3f.y.." "..v3f.z,djui_hud_get_mouse_x(),djui_hud_get_mouse_y(),.5)
end
hook_event(HOOK_MARIO_UPDATE,loop)
hook_event(HOOK_ON_HUD_RENDER,hud)