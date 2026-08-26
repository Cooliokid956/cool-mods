hook_event(HOOK_ON_HUD_RENDER, function ()
    local t1 = get_global_timer()
    local t1p = t1-1
    local t2, t2p = t1-30, t1-31

    local x, y =  10, 10
    djui_hud_print_text("this is text with \\#daa\\colors\n\\#\\and a multiline!", x, y, 1)
    y = y + 10

    local rot = t1*0x200
    local rotP = t1p*0x200
    local size = 20
    for i = 0, 2 do
        for j = 0, 2 do
            djui_hud_set_rotation_interpolated(rotP, i/2, j/2, rot, i/2, j/2)
            djui_hud_render_rect_interpolated(
                x+i*size, y+j*size, size*.9, size*.9,
                x+i*size, y+j*size, size*.9, size*.9
            )
        end
    end
end)