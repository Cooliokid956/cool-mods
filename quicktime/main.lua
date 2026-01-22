-- name: Quick Time Events
-- description: Relive the game as if it were more interactive than it already is!

local qtscenario = "none"
local qtimer = 0
local qtbuttons = "none"
local qtbuttonstimer = 0
local torad = math.pi / 32768

local a = {[0]=get_texture_info("a1"),get_texture_info("a2"),get_texture_info("a3")}
function rendertexture(tex,x,y,z)
    djui_hud_render_texture(tex,x-tex.width/2*z,y-tex.height/2*z,z,z)
end
function resetqtevent()
    qtscenario = "none"
    qtbuttons = "none"
    qtimer = -15
end

function suppressaction(m,action)
--    if qtscenario == "ledge grab" and m.actionTimer ~= 1 and action ~= ACT_FREEFALL then
--        return 1
--    end
    if action == ACT_FREEFALL and m.action == ACT_LEDGE_GRAB then
        return 1
    end
end
function update(m)
    if m.playerIndex ~= 0 then return end
    if m.action == ACT_LEDGE_GRAB and m.prevAction ~= ACT_LEDGE_CLIMB_DOWN then
        qtscenario = "ledge grab"
        qtbuttons = "mashA"
        print("esafiujh")
    else
        qtscenario = "none"
        qtbuttons = "none"
        qtimer = -15
    end

    if qtscenario == "ledge grab" then
        if m.actionTimer == 0 then
            qtimer = 30
        else qtimer = qtimer - math.min(math.sqrt(m.actionTimer/16),4) end
        if m.controller.buttonPressed & A_BUTTON ~= 0 then
            qtimer = qtimer + 15
        end
        if qtimer > 80 then
            resetqtevent()
            m.controller.buttonPressed = A_BUTTON
            return
        elseif qtimer <= 0 then
            resetqtevent()
            m.controller.buttonPressed = Z_TRIG
            return
        end
        if m.actionTimer > 1 then
            gLakituState.pos.x = m.pos.x-math.sin(m.faceAngle.y*torad + math.rad(45))*200
            gLakituState.pos.y = m.pos.y-300
            gLakituState.pos.z = m.pos.z-math.cos(m.faceAngle.y*torad + math.rad(45))*200
            vec3f_copy(m.area.camera.pos, gLakituState.pos)
            vec3f_copy(gLakituState.curPos, gLakituState.pos)
            vec3f_copy(gLakituState.goalPos, gLakituState.pos)
        end
    end

    if qtbuttons == "mashA" then
        m.controller.buttonPressed = 0
        m.controller.stickMag = 0
    end
    print(qtimer)
end

function renderbuttons()
    if gMarioStates[0].actionTimer < 2 then return end
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local screenwidth = djui_hud_get_screen_width()
    local screenheight = djui_hud_get_screen_height()
    -- show button sequences
    if qtbuttons == "mashA" then
        print("MASH A NOW")
        rendertexture(a[math.abs(qtbuttonstimer)],screenwidth/2,screenheight*0.7,7)
        qtbuttonstimer = qtbuttonstimer + 1
        if qtbuttonstimer > 2 then
            qtbuttonstimer = -1
        end
        print(qtbuttonstimer)
    end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,suppressaction)
hook_event(HOOK_ON_HUD_RENDER,renderbuttons)
hook_event(HOOK_BEFORE_MARIO_UPDATE,update)