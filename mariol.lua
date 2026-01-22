---@param m MarioState
function mark(m)
    if gNetworkPlayers[m.playerIndex].connected then
    m.marioObj.hookRender = 1
    end
end

---@param o Object
function lightsobj(o)
    set_lighting_dir(0,math.sin(o.oFaceAngleYaw * math.pi / 32768))
    set_lighting_dir(1,0)
    set_lighting_dir(2,math.cos(o.oFaceAngleYaw * math.pi / 32768))
    print(o.oFaceAngleYaw)
end
hook_event(HOOK_MARIO_UPDATE,mark)
hook_event(HOOK_ON_OBJECT_RENDER,lightsobj)