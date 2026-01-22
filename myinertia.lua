local oldPos = {x=0,y=0,z=0}
local inertia = {x=0,z=0}
local queryInertia = false
local actionTimer = 0

---@param m MarioState
function getPos(m)
    if m.playerIndex ~= 0 then return end
    print(m.floor.modifiedTimestamp)
    if m.floor.object ~= nil then
        print(m.floor.object)
        print(m.floor.object.oFaceAngleYaw)
        print(m.floor.object.oPosY)
        print(m.floor.object.oPosX)
        print(m.floor.object.oPosZ)
        print(m.floor.object.oVelY)
        print(m.floor.object.oVelX)
        print(m.floor.object.oVelZ)
    else
        oldPos.x = 0
        oldPos.y = 0
        oldPos.z = 0
    end
    print("oldPos Get!")
end

---@param m MarioState
function applyInertia(m)
    if m.playerIndex ~= 0 then return end
    print(m.floor.modifiedTimestamp)
    if m.floor.object ~= nil then
        print(m.floor.object)
        print(m.floor.object.oFaceAngleYaw)
        print(m.floor.object.oPosY)
        print(m.floor.object.oPosX)
        print(m.floor.object.oPosZ)
        print(m.floor.object.oVelY)
        print(m.floor.object.oVelX)
        print(m.floor.object.oVelZ)
    end
    if queryInertia then
        --[[m.vel.y = m.vel.y + m.floor.object.oVelY
        inertia.x = m.floor.object.oVelX
        inertia.z = m.floor.object.oVelZ
        queryInertia = false]]
    end
    if m.action & ACT_FLAG_AIR ~= 0 then
        m.pos.x = m.pos.x + inertia.x
        m.pos.z = m.pos.z + inertia.z
    end
    print("inertia x: "..tostring(inertia.x)..", z: "..inertia.z)
    --print("oldPos x: "..oldPos.x..", y: "..oldPos.y..", z: "..oldPos.z)
    print("applyInertia Get!")
end

---@param m MarioState
---@param action integer
function setInertia(m, action)
    if m.playerIndex ~= 0 then return end
    print(m.floorHeight..", "..m.pos.y)
    if not (m.action & ACT_FLAG_AIR ~= 0) and action & ACT_FLAG_AIR ~= 0 and m.floor.object ~= nil then
        --queryInertia = true
        m.pos.y = m.pos.y + m.floor.object.oVelY
        m.vel.y = m.vel.y + m.floor.object.oVelY
        inertia.x = m.floor.object.oVelX
        inertia.z = m.floor.object.oVelZ
        actionTimer = 0
    elseif (action & ACT_FLAG_ATTACKING and m.pos.y > m.floorHeight + 320) or not (action & ACT_FLAG_AIR ~= 0) and m.action & ACT_FLAG_AIR ~= 0 then
        clearInertia()
    end
    print("setInertia Get!")
end
function clearInertia()
    inertia.x = 0
    inertia.z = 0
end
function unit()
    return math.min(djui_hud_get_screen_width(),djui_hud_get_screen_height())
end
function renderstats()
    local mousex = djui_hud_get_mouse_x()
    local mousey = djui_hud_get_mouse_y()
    local m = gMarioStates[0]
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_color(255,255,255,255)
    djui_hud_set_font(FONT_MENU)
    local scale = unit()/800
    djui_hud_print_text("inertia",mousex,mousey,scale)
    djui_hud_print_text("x: "..inertia.x..", z: "..inertia.z,mousex,mousey+36*scale,scale)
    if m.floorHeight == m.pos.y then
        djui_hud_print_text("yes!",mousex,mousey+36*2*scale,scale)
    end
    djui_hud_set_color(255,255,255,math.max(0,255-actionTimer))
    print("actionTimer: "..actionTimer)
    djui_hud_print_text("inertia set!",mousex,mousey+36*3*scale,scale)
    actionTimer = actionTimer+3

end
hook_event(HOOK_ON_HUD_RENDER,renderstats)
hook_event(HOOK_MARIO_UPDATE,applyInertia)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,setInertia)
hook_event(HOOK_BEFORE_MARIO_UPDATE,getPos)
hook_event(HOOK_ON_WARP, clearInertia)