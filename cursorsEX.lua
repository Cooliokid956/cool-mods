local hand = get_texture_info("texture_menu_idle_hand")
local handgrab = get_texture_info("texture_menu_grabbing_hand")

local sound = true

local mouse = {}

for i=0, MAX_PLAYERS-1 do
    mouse[i] = {
        x = 0,
        y = 0,
        prev = {
            x = 0,
            y = 0
        }
    }
end

for i=0, #gPlayerSyncTable+1, 1 do
    gPlayerSyncTable[i].mouse = {}
    gPlayerSyncTable[i].mouse.x = djui_hud_get_mouse_x()/djui_hud_get_screen_width()
    gPlayerSyncTable[i].mouse.y = djui_hud_get_mouse_y()/djui_hud_get_screen_height()
    gPlayerSyncTable[i].mouse.prev = {}
    gPlayerSyncTable[i].mouse.prev.x = djui_hud_get_mouse_x()/djui_hud_get_screen_width()
    gPlayerSyncTable[i].mouse.prev.y = djui_hud_get_mouse_y()/djui_hud_get_screen_height()
end
function unit()
    return math.min(w,h)
end
function rendercursors()
    w = djui_hud_get_screen_width()
    h = djui_hud_get_screen_height()

    gPlayerSyncTable[0].mouse.prev.x = gPlayerSyncTable[0].mouse.x
    gPlayerSyncTable[0].mouse.prev.y = gPlayerSyncTable[0].mouse.y
    gPlayerSyncTable[0].mouse.x = djui_hud_get_mouse_x()/w
    gPlayerSyncTable[0].mouse.y = djui_hud_get_mouse_y()/h

    if gMarioStates[0].controller.buttonDown & (B_BUTTON | A_BUTTON) ~= 0 then
        djui_hud_render_texture_interpolated(handgrab,gPlayerSyncTable[0].mouse.prev.x*w,gPlayerSyncTable[0].mouse.prev.y*h,unit()/400,unit()/400,gPlayerSyncTable[0].mouse.x*w,gPlayerSyncTable[0].mouse.y*h,unit()/400,unit()/400)
        if gMarioStates[0].controller.buttonPressed & (B_BUTTON | A_BUTTON) ~= 0 and sound then
            play_sound(SOUND_MENU_CLICK_FILE_SELECT,gMarioStates[0].marioObj.header.gfx.cameraToObject)
        end
    else
        djui_hud_render_texture_interpolated(hand,gPlayerSyncTable[0].mouse.prev.x*w,gPlayerSyncTable[0].mouse.prev.y*h,unit()/400,unit()/400,gPlayerSyncTable[0].mouse.x*w,gPlayerSyncTable[0].mouse.y*h,unit()/400,unit()/400)
    end
    for i=1, #gNetworkPlayers, 1 do
        if gNetworkPlayers[i].connected and gPlayerSyncTable[i].mouse ~= nil then
            if gMarioStates[i].controller.buttonDown & (B_BUTTON | A_BUTTON) ~= 0 then
                djui_hud_render_texture_interpolated(handgrab,gPlayerSyncTable[i].mouse.prev.x*w,gPlayerSyncTable[i].mouse.prev.y*h,unit()/400,unit()/400,gPlayerSyncTable[i].mouse.x*w,gPlayerSyncTable[i].mouse.y*h,unit()/400,unit()/400)
                if gMarioStates[i].controller.buttonPressed & (B_BUTTON | A_BUTTON) ~= 0 and sound then
                    play_sound(SOUND_MENU_CLICK_FILE_SELECT,gMarioStates[0].marioObj.header.gfx.cameraToObject)
                end
            else
                djui_hud_render_texture_interpolated(hand,gPlayerSyncTable[i].mouse.prev.x*w,gPlayerSyncTable[i].mouse.prev.y*h,unit()/400,unit()/400,gPlayerSyncTable[i].mouse.x*w,gPlayerSyncTable[i].mouse.y*h,unit()/400,unit()/400)
            end
        end
    end
end
function togglesound()
    sound = not sound
    if sound then
        djui_chat_message_create("Cursor sounds enabled.")
    else
        djui_chat_message_create("Cursor sounds disabled.")
    end
end
hook_chat_command("click","to toggle cursor click sounds",togglesound)
hook_event(HOOK_ON_HUD_RENDER,rendercursors)