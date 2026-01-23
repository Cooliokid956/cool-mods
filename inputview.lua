-- name: Input Display
-- description: see your inputs!\n\n\\#555555\\made by \\#5173e8\\radi\\#DE6034\\cati\n\\#dcdcdc\\opacity fix and saving:\\#ff0000\\JairoThePlumber\n\\#dcdcdc\\position/resizing: Coolio

InputDisplay = mod_storage_load("InputDisplay") == nil or mod_storage_load("InputDisplay") == "true"

if mod_storage_load("firstsetup") == nil then
	firstsetup = true
	DisplayX = .5
	DisplayY = .5
	DisplayZ = 1
	mod_storage_save("InputDisplay", "true")
	djui_popup_create("Press A when done", 1)
	djui_popup_create("Use the mouse to scale the display", 1)
	djui_popup_create("Input Viewer: first time setup", 2)
else
	DisplayX = tonumber(mod_storage_load("DisplayX"))
	DisplayY = tonumber(mod_storage_load("DisplayY"))
	DisplayZ = tonumber(mod_storage_load("DisplayZ"))
end
function on_hud_render()
	djui_hud_set_font(FONT_MENU)
	djui_hud_set_resolution(RESOLUTION_DJUI)

	if not InputDisplay then return end
	local m = gMarioStates[0]
	local x = DisplayX*djui_hud_get_screen_width()
	local y = DisplayY*djui_hud_get_screen_height()
	local z = DisplayZ
	if firstsetup then
		DisplayZ = math.sqrt((djui_hud_get_mouse_x()/djui_hud_get_screen_width()-.5)*(djui_hud_get_mouse_x()/djui_hud_get_screen_width()-.5)+(djui_hud_get_mouse_y()/djui_hud_get_screen_height()-.5)*(djui_hud_get_mouse_y()/djui_hud_get_screen_height()-.5))*4
		if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
			mod_storage_save("DisplayZ", tostring(DisplayZ))
			firstsetup = false
			djui_popup_create("Press A when done",1)
			djui_popup_create("Move mouse to position the display",1)
		end
	elseif firstsetup == false then
		DisplayX = djui_hud_get_mouse_x()/djui_hud_get_screen_width()
		DisplayY = djui_hud_get_mouse_y()/djui_hud_get_screen_height()
		if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
			mod_storage_save("DisplayX", tostring(DisplayX))
			mod_storage_save("DisplayY", tostring(DisplayY))
			firstsetup = nil
			mod_storage_save("firstsetup", "clear")
			djui_popup_create("Use /input-set to redo",1)
			djui_popup_create("Setup complete.",1)
		end
	end
-- Buttons
-- A Button
	if (m.controller.buttonDown & A_BUTTON) ~= 0 then
	djui_hud_set_color(34,100,178,255)
	else
	djui_hud_set_color(0,50,80,190)
	end
	djui_hud_print_text("A", x + 50*z, y, 1*z)

-- B Button
	if (m.controller.buttonDown & B_BUTTON) ~= 0 then
	djui_hud_set_color(34,178,28,255)
	else
	djui_hud_set_color(0,80,0,190)
	end
	djui_hud_print_text("B", x, y + 50*z, 1*z)

-- Z Trigger
	if (m.controller.buttonDown & Z_TRIG) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("Z", x + 50*z, y - 100*z, 1*z)

-- X Button
	if (m.controller.buttonDown & X_BUTTON) ~= 0 then
	djui_hud_set_color(255,34,28,255)
	else
	djui_hud_set_color(100,0,0,190)
	end
	djui_hud_print_text("X", x, y - 50*z, 1*z)

-- Y Button
	if (m.controller.buttonDown & Y_BUTTON) ~= 0 then
	djui_hud_set_color(178,178,0,255)
	else
	djui_hud_set_color(80,80,0,190)
	end
	djui_hud_print_text("Y", x - 50*z, y, 1*z)

-- R Trigger
	if (m.controller.buttonDown & R_TRIG) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("R", x, y - 100*z, 1*z)

-- L Trigger
	if (m.controller.buttonDown & L_TRIG) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("L", x - 50*z, y - 100*z, 1*z)

-- Start Button
	if (m.controller.buttonDown & START_BUTTON) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("START", x - 25*z, y + 100*z, 0.5*z)

-- D-Pad Down
	if (m.controller.buttonDown & D_JPAD) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("v", x + 150*z, y - 2*z, 1*z)

-- D-Pad Up
	if (m.controller.buttonDown & U_JPAD) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("^", x + 150*z, y - 30*z, 1*z)

-- D-Pad Left
	if (m.controller.buttonDown & L_JPAD) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text("<", x + 120*z, y - 20*z, 1*z)

-- D-Pad Right
	if (m.controller.buttonDown & R_JPAD) ~= 0 then
	djui_hud_set_color(150,150,150,255)
	else
	djui_hud_set_color(50,50,50,190)
	end
	djui_hud_print_text(">", x + 180*z, y - 20*z, 1*z)

-- Down C-Buttons
	if (m.controller.buttonDown & D_CBUTTONS) ~= 0 then
	djui_hud_set_color(250,250,0,255)
	else
	djui_hud_set_color(100,100,0,190)
	end
	djui_hud_print_text("v", x + 150*z, y + 78*z, 1*z)

-- Up C-Buttons
	if (m.controller.buttonDown & U_CBUTTONS) ~= 0 then
	djui_hud_set_color(250,250,0,255)
	else
	djui_hud_set_color(100,100,0,190)
	end
	djui_hud_print_text("^", x + 150*z, y + 50*z, 1*z)

-- Left C-Buttons
	if (m.controller.buttonDown & L_CBUTTONS) ~= 0 then
	djui_hud_set_color(250,250,0,255)
	else
	djui_hud_set_color(100,100,0,190)
	end
	djui_hud_print_text("<", x + 120*z, y + 60*z, 1*z)

-- Right C-Buttons
	if (m.controller.buttonDown & R_CBUTTONS) ~= 0 then
	djui_hud_set_color(250,250,0,255)
	else
	djui_hud_set_color(100,100,0,190)
	end
	djui_hud_print_text(">", x + 180*z, y + 60*z, 1*z)

-- Area for Joy-Stick and C-Stick
	djui_hud_set_color(0,0,0,100)
	djui_hud_print_text("o", x - 205*z, y - 70*z, 4*z)

-- Joy-Stick
	textx = (m.controller.stickX - 150)*z
	texty = (50 - m.controller.stickY)*z
	djui_hud_set_color(100,100,100,255)
	djui_hud_print_text("O", x + textx, y + texty, 1*z)

-- C-Stick
	textx2 = (m.controller.extStickX - 137)*z
	texty2 = (63 - m.controller.extStickY)*z
	djui_hud_set_color(100,60,60,120)
	djui_hud_print_text("o", x + textx2, y + texty2, 0.5*z)
end

-- stuffs about to get crazy and im scared - 4:30 pm
-- HOLY CRAP - 4:57 pm
-- sunk told me we need more buttons so im on it - 5:15 pm
-- done, unfortunately couldnt add opacity command :( cope - 6:49
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

hook_chat_command("input-display", "to toggle",
function (msg)
	InputDisplay = not InputDisplay
	mod_storage_save("InputDisplay", tostring(InputDisplay))
	if InputDisplay then
		djui_popup_create("Input Display is on", 1)
	else
		djui_popup_create("Input Display is off", 1)
	end
	return true
end)

hook_chat_command("input-set", "to set viewer position and scale",
function (msg)
	InputDisplay = true
	mod_storage_save("InputDisplay", "true")
	firstsetup = true
	DisplayX = .5
	DisplayY = .5
	djui_popup_create("Press A when done",1)
	djui_popup_create("Use the mouse to scale the display",1)
	return true
end)