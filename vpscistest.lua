-- name: Viewport/Scissor tester

local idx = 2
local cn = { {0, 0}, {0, 0} }
local pcn = { {0, 0}, {0, 0} }
hook_event(HOOK_ON_HUD_RENDER, function ()
    local res = (get_global_timer()//30) % 2
    djui_chat_message_create('res '..((res==0) and 'djui' or 'n64'))

    djui_hud_set_resolution(res)
    djui_hud_set_color(20, 20, 20, 200)
    djui_hud_render_rect(0, 0, 1000, 1000)

    if gControllers[0].buttonPressed & U_JPAD ~= 0 then
        idx = idx % 3 + 1
    end

    pcn = table.deepcopy(cn)
    local corner = cn[idx]
    if corner then
        corner[1] = djui_hud_get_mouse_x()
        corner[2] = djui_hud_get_mouse_y()
    end

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_rect(cn[1][1], cn[1][2], 10, 10)
    djui_hud_render_rect(cn[2][1], cn[2][2], 10, 10)

    local c = gControllers[0].buttonDown
    local pulx, puly, plrx, plry = pcn[1][1], pcn[1][2], pcn[2][1], pcn[2][2]
    local ulx, uly, lrx, lry = cn[1][1], cn[1][2], cn[2][1], cn[2][2]
    if c & L_JPAD ~= 0 then
        djui_hud_set_color(200, 20, 20, 80)
        djui_chat_message_create('red scissor')
        -- djui_hud_set_scissor(ulx, uly, lrx, lry)
        djui_hud_set_scissor_interpolated(pulx, puly, plrx, plry, ulx, uly, lrx, lry)
        djui_hud_render_rect(0, 0, 1000, 1000)
        djui_hud_set_color(255, 255, 255, 255)
        -- djui_hud_print_text("Scissor\ntext", ulx, uly, 1)
        djui_hud_print_text_interpolated("Scissor\ntext", pulx, puly, 1, ulx, uly, 1)
        djui_hud_reset_scissor()
    end

    if c & D_JPAD ~= 0 then
        djui_hud_set_color(20, 200, 20, 80)
        djui_chat_message_create('green viewport')
        -- djui_hud_set_viewport(ulx, uly, lrx, lry)
        djui_hud_set_viewport_interpolated(pulx, puly, plrx, plry, ulx, uly, lrx, lry)
        djui_hud_render_rect(0, 0, djui_hud_get_screen_width(), djui_hud_get_screen_height())
        djui_hud_set_color(255, 255, 255, 255)
        -- djui_hud_print_text("Viewport\ntext", 0, 0, 1)
        djui_hud_print_text_interpolated("Viewport\ntext", 0, 0, 1, 0, 0, 1)
        djui_hud_reset_viewport()
    end

    if c & R_JPAD ~= 0 then
        djui_hud_set_color(20, 20, 200, 80)
        djui_chat_message_create('blue rect')
        -- djui_hud_render_rect(ulx, uly, lrx-ulx, lry-uly)
        djui_hud_render_rect_interpolated(pulx, puly, plrx-pulx, plry-puly, ulx, uly, lrx-ulx, lry-uly)
        djui_hud_set_color(255, 255, 255, 255)
        -- djui_hud_print_text("Normal\ntext", ulx, uly, 1)
        djui_hud_print_text_interpolated("Normal\ntext", pulx, puly, 1, ulx, uly, 1)
    end
end)