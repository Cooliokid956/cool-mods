hook_event(HOOK_ON_HUD_RENDER, function ()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local pos = gMarioStates[0].pos
    djui_hud_render_texture(gTextures.mario_head, djui_hud_get_screen_width()/2+(pos.x*djui_hud_get_screen_height()/32767/2), djui_hud_get_screen_height()/2+(pos.z*djui_hud_get_screen_height()/32767/2), 3, 3)
end)