-- name: Wheel Template
-- description: template for wheel
local Lcounter = 0
local wheelout = 0
local screenwidth
local screenheight
local sprites = {}
local triggerlimit = 9
local cursordist

-- selectedentry will be a "sprite", you'll usually need to use either field 1 or 8 for identification 
local selectedentry

function unit()
    return math.min(screenwidth,screenheight)
end

--            1          2  3  4      5      6      7          8
--            text,      x, y, scale, x vel, y vel, scale vel, value/enum
sprites[0] = {"Wheel",   0, 0, 0,     0,     0,     0,         "meh"}

sprites[1] = {"Entry 1", 0, 0, 0,     0,     0,     0,         1}
sprites[2] = {"Entry 2", 0, 0, 0,     0,     0,     0,         2}
sprites[3] = {"Entry 3", 0, 0, 0,     0,     0,     0,         3}
sprites[4] = {"Entry 4", 0, 0, 0,     0,     0,     0,         4}
sprites[5] = {"Entry 5", 0, 0, 0,     0,     0,     0,         5}
sprites[6] = {"Entry 6", 0, 0, 0,     0,     0,     0,         6}
sprites[7] = {"Entry 7", 0, 0, 0,     0,     0,     0,         7}
sprites[8] = {"Entry 8", 0, 0, 0,     0,     0,     0,         8}

-- change these to what you need, then use code to know which one's selected (use selectedentry)

function checkwheel(m)
if m.playerIndex == 0 then
--  hold for some time to open wheel
    if m.controller.buttonDown & L_TRIG ~= 0 and Lcounter ~= triggerlimit and wheelout ~= 4 then
        Lcounter = Lcounter + 1
    elseif (m.controller.buttonDown & L_TRIG == 0 and Lcounter ~= 0) or wheelout == 4 then
        Lcounter = Lcounter - 1
    end

    if wheelout == 0 and Lcounter == triggerlimit then
        wheelout = 1
    elseif (wheelout == 1 or wheelout == 2) and Lcounter == triggerlimit then
        wheelout = 2
    elseif wheelout == 2 and Lcounter ~= triggerlimit then
        wheelout = 3
    elseif wheelout == 3 then
        wheelout = 4
    end
end
end
function rendertext(s)
    djui_hud_print_text_interpolated(s[1], (s[2]-s[5])-djui_hud_measure_text(s[1])*(s[4]-s[7])/2, (s[3]-s[6])-32*(s[4]-s[7]), s[4]-s[7], s[2]-djui_hud_measure_text(s[1])*s[4]/2, s[3]-32*s[4], s[4])
end

function renderwheel()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_color(255, 255, 255, 255)
    screenwidth = djui_hud_get_screen_width()
    screenheight = djui_hud_get_screen_height()

--  text of choice (first field of sprites[0])
    sprites[0][4] = unit()/700
    sprites[0][2] = screenwidth/2
    sprites[0][3] = screenheight*0.93

    if wheelout == 1 then
        for i = 1, #sprites do
            sprites[i][2] = screenwidth/2
            sprites[i][3] = screenheight/2
            sprites[i][4] = 0.00000001
            sprites[i][5] = (math.sin(math.rad((i-1)*45+(math.random()*10)))-math.random()*10)*unit()/50
            sprites[i][6] = (math.cos(math.rad((i-1)*45+(math.random()*10)))-math.random()*-10)*unit()/50
            sprites[i][7] = math.random()*6
        end
    end
    if wheelout == 1 or wheelout == 2 then
        selectedentry = nil
        cursordist = unit()/7
        for i = 1, #sprites do
            sprites[i][5] = (sprites[i][5] + ((screenwidth/2+unit()*0.3*math.sin(math.rad((i-1)*45)))-sprites[i][2])*0.3)*0.8
            sprites[i][6] = (sprites[i][6] + ((screenheight/2-unit()*0.3*math.cos(math.rad((i-1)*45)))-sprites[i][3])*0.3)*0.8
            if math.sqrt((sprites[i][2]-djui_hud_get_mouse_x())^2+(sprites[i][3]-djui_hud_get_mouse_y())^2) <= cursordist and selectedentry == nil then
                selectedentry = sprites[i]
                sprites[i][7] = sprites[i][7] + unit()*0.001
            end
            sprites[i][7] = (sprites[i][7] + ((unit()/800)-(sprites[i][4]))*0.9)*0.5
            
        end
        
        for i = 1, #sprites do
            if math.sqrt((sprites[i][2]-(screenwidth/2+(gMarioStates[0].controller.extStickX/128*unit()*0.3)))^2+(sprites[i][3]-(screenheight/2-(gMarioStates[0].controller.extStickY/128*unit()*0.3)))^2) <= cursordist then
                selectedentry = sprites[i]
                sprites[i][7] = sprites[i][7] + unit()*0.001
            end
        end
        if selectedentry ~= nil then
            rendertext(selectedentry)
        end
    end
    if wheelout == 3 then
        for i = 1, #sprites do
            sprites[i][5] = sprites[i][5]+(math.sin(math.rad((i-1)*45+(math.random()*10)-5)))*unit()/10
            sprites[i][6] = sprites[i][6]-(math.cos(math.rad((i-1)*45+(math.random()*10)-5)))*unit()/10
            sprites[i][7] = sprites[i][7] + math.random()
        end
    end
    if wheelout == 3 or wheelout == 4 then
        for i = 1, #sprites do
            if sprites[i][4] > 0 then
                sprites[i][5] = sprites[i][5] + (screenwidth/2-sprites[i][2])*0.05
                sprites[i][6] = sprites[i][6] + (screenheight/2-sprites[i][3])*0.05
                sprites[i][7] = sprites[i][7] - sprites[i][4]*0.07
            end
        end
    end
    if wheelout ~= 0 then
        local done = true
        rendertext(sprites[0])
        for i = 1, #sprites do
            if sprites[i][4]+sprites[i][7] > 0 then
                done = false
                sprites[i][2] = sprites[i][2] + sprites[i][5]
                sprites[i][3] = sprites[i][3] + sprites[i][6]
                sprites[i][4] = sprites[i][4] + sprites[i][7]

                rendertext(sprites[i])
            end
        end
        if done then
            wheelout = 0
            Lcounter = 0
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE,checkwheel)
hook_event(HOOK_ON_HUD_RENDER,renderwheel)