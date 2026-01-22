-- name: OMM but silly
if network_is_server() then return end

local timer = 30*30
function hud()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_color(0,0,0,255)
    djui_hud_render_rect(0,0,djui_hud_get_screen_width(),djui_hud_get_screen_height())
    djui_hud_set_color(255,255,255,255)
    local w = djui_hud_get_screen_width()
    local h = djui_hud_get_screen_height()
    djui_hud_print_text("Sorry! OMM but silly's being hosted at:",w/2-djui_hud_measure_text("Sorry! OMM but silly's being hosted at:")*w/600/2,h/10,w/600)
    djui_hud_print_text("184.92.21.4",w/2-djui_hud_measure_text("184.92.21.4")*w/240/2,h/3,w/240)
    djui_hud_print_text("(Direct Connection)",w/2-djui_hud_measure_text("(Direct Connection)")*w/1200/2,h*.6,w/1200)
    djui_hud_print_text("See you there!",w/2-djui_hud_measure_text("See you there!")*w/700/2,h*.7,w/700)
    if timer < 30*10 then
        djui_hud_print_text("(game crash in ".. math.floor(timer/30) .." seconds)",w/2-djui_hud_measure_text("(game crash in ".. math.floor(timer/30) .." seconds)")*w/700/2,h*.8,w/700)
        if math.floor(timer/30) == timer/30 then
            play_sound(SOUND_MENU_CLICK_FILE_SELECT,gMarioStates[0].marioObj.header.gfx.cameraToObject)
        end
    end
    timer = timer - 1
    while timer == 0 do end
end
hook_event(HOOK_ON_HUD_RENDER,hud)