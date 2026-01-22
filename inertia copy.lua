local oldPos = {x=0,y=0,z=0}
local inertia = {x=0,z=0}
local queryInertia = false

---@param m MarioState
function getPos(m)
    if m.playerIndex ~= 0 then return end
    if not (m.action & ACT_FLAG_AIR ~= 0) then
        oldPos.x = m.pos.x
        oldPos.y = m.pos.y
        oldPos.z = m.pos.z
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
    end
    if queryInertia then
        m.vel.y = m.vel.y + m.pos.y - oldPos.y
        inertia.x = m.pos.x - oldPos.x
        inertia.z = m.pos.z - oldPos.z
        queryInertia = false
    end
    if m.action & ACT_FLAG_AIR ~= 0 then
        m.pos.x = m.pos.x + inertia.x
        m.pos.z = m.pos.z + inertia.z
    end
    print("inertia x: "..tostring(inertia.x)..", z: "..inertia.z)
    print("oldPos x: "..oldPos.x..", y: "..oldPos.y..", z: "..oldPos.z)
    print("applyInertia Get!")
end

---@param m MarioState
---@param action integer
function setInertia(m, action)
    if m.playerIndex ~= 0 then return end
    if m.floorHeight == m.pos.y and action & ACT_FLAG_AIR ~= 0 then
        queryInertia = true
    --[[
        m.vel.y = m.vel.y * 2 - oldPos.y
        inertia.x = m.pos.x - oldPos.x
        inertia.z = m.pos.z - oldPos.z
    ]]
    end
    print("setInertia Get!")
end
function clearInertia()
    inertia.x = 0
    inertia.z = 0
end

hook_event(HOOK_MARIO_UPDATE,applyInertia)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,setInertia)
hook_event(HOOK_BEFORE_MARIO_UPDATE,getPos)
hook_event(HOOK_ON_WARP, clearInertia)