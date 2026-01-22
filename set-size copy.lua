-- name: Set Size
-- description: This mod adds 2 commands.\n\n/size: Changes the size of your character by using 3 numbers or less.\n\n/max-size: A host only command that limits the size of players.\n(DEFAULT IS 10)\n\nThe host is unaffected by max-size.\n\n\nThis mod DOES update player hitboxes.
gGlobalSyncTable.hostMaxSize = 10
gGlobalSyncTable.gSize = {}
gGlobalSyncTable.gSize.x = "off"
gPlayerSyncTable[0].multMov = true
prevY = 0
local camtoggle = false
local hostIndex = network_global_index_from_local(0)
function on_player_connected(m)
    gPlayerSyncTable[m.playerIndex].sizeX = 1
    gPlayerSyncTable[m.playerIndex].sizeY = 1
    gPlayerSyncTable[m.playerIndex].sizeZ = 1
end
prevPos = {}

for i=0, MAX_PLAYERS, 1 do
    prevPos[i] = {x=0,y=0,z=0}
    vec3f_set(prevPos[i],0,0,0)
end
---@param m MarioState
function mario_update(m)
    if gNetworkPlayers[m.playerIndex].connected and (gGlobalSyncTable.gSize.x == "off" or gGlobalSyncTable.gSize == nil) then
        vec3f_set(m.marioObj.header.gfx.scale,
            m.marioObj.header.gfx.scale.x * gPlayerSyncTable[m.playerIndex].sizeX,
            m.marioObj.header.gfx.scale.y * gPlayerSyncTable[m.playerIndex].sizeY,
            m.marioObj.header.gfx.scale.z * gPlayerSyncTable[m.playerIndex].sizeZ
        )
        --print(m.marioObj.hitboxHeight .. ", " .. m.marioObj.hitboxRadius)
        m.marioObj.hitboxHeight = 160.0 * gPlayerSyncTable[m.playerIndex].sizeY
        m.marioObj.hitboxRadius = 37.0 * math.max(gPlayerSyncTable[m.playerIndex].sizeX,gPlayerSyncTable[m.playerIndex].sizeZ)
        --print(m.marioObj.oWallHitboxRadius)
        --print(m.marioObj.oGravity)
        if m.playerIndex ~= hostIndex then
            if gPlayerSyncTable[m.playerIndex].sizeX > gGlobalSyncTable.hostMaxSize then
                gPlayerSyncTable[m.playerIndex].sizeX = gGlobalSyncTable.hostMaxSize
            elseif gPlayerSyncTable[m.playerIndex].sizeY > gGlobalSyncTable.hostMaxSize then
                gPlayerSyncTable[m.playerIndex].sizeY = gGlobalSyncTable.hostMaxSize
            elseif gPlayerSyncTable[m.playerIndex].sizeZ > gGlobalSyncTable.hostMaxSize then
                gPlayerSyncTable[m.playerIndex].sizeZ = gGlobalSyncTable.hostMaxSize
            end
        end
        -- movement multiplier
        if gPlayerSyncTable[m.playerIndex].multMov and prevPos[m.playerIndex].x ~= "skip" or not m.action == ACT_LEDGE_GRAB or not m.action == ACT_LEDGE_CLIMB_DOWN then
            m.pos.x = m.pos.x + (m.pos.x-prevPos[m.playerIndex].x)*(math.max(gPlayerSyncTable[m.playerIndex].sizeX,gPlayerSyncTable[m.playerIndex].sizeZ)-1)
            m.pos.z = m.pos.z + (m.pos.z-prevPos[m.playerIndex].z)*(math.max(gPlayerSyncTable[m.playerIndex].sizeX,gPlayerSyncTable[m.playerIndex].sizeZ)-1)
            if m.pos.y + (m.pos.y-prevPos[m.playerIndex].y)*(gPlayerSyncTable[m.playerIndex].sizeY-1)<m.floorHeight then
                m.pos.y = m.floorHeight
                prevPos[m.playerIndex].y = m.pos.y
            else
                m.pos.y = m.pos.y + (m.pos.y-prevPos[m.playerIndex].y)*(gPlayerSyncTable[m.playerIndex].sizeY-1)
            end
        elseif prevPos[m.playerIndex].x == "skip" then
            prevPos[m.playerIndex].x = 0
            print("skipped")
        end
    elseif gNetworkPlayers[m.playerIndex].connected and gGlobalSyncTable.gSize ~= "off"  then
        vec3f_set(m.marioObj.header.gfx.scale,
            m.marioObj.header.gfx.scale.x * gGlobalSyncTable.gSize.x,
            m.marioObj.header.gfx.scale.y * gGlobalSyncTable.gSize.y,
            m.marioObj.header.gfx.scale.z * gGlobalSyncTable.gSize.z
        )
        --print(m.marioObj.hitboxHeight .. ", " .. m.marioObj.hitboxRadius)
        m.marioObj.hitboxHeight = 160.0 * gGlobalSyncTable.gSize.y
        m.marioObj.hitboxRadius = 37.0 * math.max(gGlobalSyncTable.gSize.x,gGlobalSyncTable.gSize.z)
        --print(m.marioObj.oWallHitboxRadius)
        --print(m.marioObj.oGravity)
        -- movement multiplier
        if gPlayerSyncTable[m.playerIndex].multMov and prevPos[m.playerIndex].x ~= "skip" then
            m.pos.x = m.pos.x + (m.pos.x-prevPos[m.playerIndex].x)*(math.max(gGlobalSyncTable.gSize.x,gGlobalSyncTable.gSize.z)-1)
            m.pos.z = m.pos.z + (m.pos.z-prevPos[m.playerIndex].z)*(math.max(gGlobalSyncTable.gSize.x,gGlobalSyncTable.gSize.z)-1)
            if m.pos.y + (m.pos.y-prevPos[m.playerIndex].y)*(gGlobalSyncTable.gSize.y-1)<m.floorHeight then
                m.pos.y = m.floorHeight
                prevPos[m.playerIndex].y = m.pos.y
            else
                m.pos.y = m.pos.y + (m.pos.y-prevPos[m.playerIndex].y)*(gGlobalSyncTable.gSize.y-1)
            end
        elseif prevPos[m.playerIndex].x == "skip" then
            prevPos[m.playerIndex].x = 0
        end
    end

    if m.playerIndex == 0 and camtoggle then
        local camera = {x=0,y=0,z=0}
        local focus = {x=0,y=0,z=0}
        local size = math.max(gPlayerSyncTable[m.playerIndex].sizeX,gPlayerSyncTable[m.playerIndex].sizeY,gPlayerSyncTable[m.playerIndex].sizeZ)
        -- vec3f_dif(camera,gLakituState.pos,m.pos)
        -- vec3f_mul(camera,size)
        -- vec3f_add(camera,m.pos)
        vec3f_dif(focus,gLakituState.focus,m.pos)
        if size > 1 then
            focus.x = focus.x * size
            focus.z = focus.z * size
            focus.y = focus.y - 160 + 160 * size
            vec3f_add(focus,m.pos)
            gLakituState.pos.y = gLakituState.pos.y - 160 + 160 * size
            m.area.camera.pos.y = gLakituState.pos.y
        elseif size <= 1 then
            vec3f_dif(focus,gLakituState.focus,m.pos)
            vec3f_mul(focus,size)
            -- focus.y = (focus.y-m.pos.y)*size+m.pos.y
            -- vec3f_mul(focus,size)
            vec3f_add(focus, m.pos)
        end
        -- gLakituState.mode =
        -- gLakituState.roll = gLakituState.roll + 32
        --print(gLakituState.roll)
        vec3f_copy(m.area.camera.focus,focus)
        vec3f_copy(gLakituState.curFocus,focus)
        set_override_fov(50*size)
        
        --print(size)
        -- vec3f_copy(m.area.camera.pos, camera)
        -- vec3f_copy(gLakituState.curPos, camera)
        -- vec3f_copy(gLakituState.goalPos, camera)
    elseif not camtoggle then
        set_override_fov(0)
    end
end

function set_size(msg)
    if string.find(msg, " ") == nil then
        gPlayerSyncTable[0].sizeX = tonumber(msg)
        gPlayerSyncTable[0].sizeY = tonumber(msg)
        gPlayerSyncTable[0].sizeZ = tonumber(msg)
        return true
    end
    local xyz = {"", "", ""}
    local index = 1
    for i = 1, #msg do
        local currentLetter = msg:sub(i, i)
        if tonumber(currentLetter) ~= nil or currentLetter == "." or currentLetter == "-" then
            xyz[index] = xyz[index].. currentLetter
        else
            index = index + 1
        end
    end
    if index > 3 then
        return false
    end

    if tonumber(xyz[1]) ~= nil then
        gPlayerSyncTable[0].sizeX = tonumber(xyz[1])
    else
        djui_chat_message_create("Size X not found.")
    end

    if tonumber(xyz[2]) ~= nil then
        gPlayerSyncTable[0].sizeY = tonumber(xyz[2])
    else
        djui_chat_message_create("Size Y not found.")
    end

    if tonumber(xyz[3]) ~= nil then
        gPlayerSyncTable[0].sizeZ = tonumber(xyz[3])
    else
        djui_chat_message_create("Size Z not found.")
    end
    return true
end

function max_size_command(msg)
    if tonumber(msg) ~= nil then
        gGlobalSyncTable.hostMaxSize = tonumber(msg)
        djui_chat_message_create("Max Size has been set to "..msg)
        return true
    end
end
---@param m MarioState
function get_prev_pos(m)
if gNetworkPlayers[m.playerIndex].connected then
    if gGlobalSyncTable.gSize.x ~= "off" and m.pos.y + (m.pos.y-prevPos[m.playerIndex].y)*(gGlobalSyncTable.gSize.y-1)<m.floorHeight then
        m.peakHeight = (m.peakHeight-m.floorHeight)/gGlobalSyncTable.gSize.y+m.floorHeight
    elseif m.pos.y + (m.pos.y-prevPos[m.playerIndex].y)*(gPlayerSyncTable[m.playerIndex].sizeY)<m.floorHeight then
        m.peakHeight = (m.peakHeight-m.floorHeight)/gPlayerSyncTable[m.playerIndex].sizeY+m.floorHeight
    end
    vec3f_copy(prevPos[m.playerIndex],m.pos)
    -- if prevY == 0 and m.vel.y ~= 0 then
    --     m.vel.y = m.vel.y*gPlayerSyncTable[m.playerIndex].sizeY
    -- end
    -- prevY = m.vel.y
    -- m.vel.y = m.vel.y - (gPlayerSyncTable[m.playerIndex].sizeY-1)

--[[m.pos.x = m.pos.x + (gPlayerSyncTable[m.playerIndex].sizeX-1)*m.vel.x
    m.pos.z = m.pos.z + (gPlayerSyncTable[m.playerIndex].sizeZ-1)*m.vel.z]]

    --get

--[[if m.pos.y + (gPlayerSyncTable[m.playerIndex].sizeY-1)*m.vel.y < m.floorHeight or m.action & ACT_FLAG_AIR == 0 and m.action & ACT_FLAG_HANGING == 0 and m.action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
        m.pos.y = m.floorHeight
        m.peakHeight = m.peakHeight / gPlayerSyncTable[m.playerIndex].sizeY
        --print("NAAA")
        --print("NAAA")
        --print("NAAA")
    else
        m.pos.y = m.pos.y + (gPlayerSyncTable[m.playerIndex].sizeY-1)*m.vel.y
    end
    --print(m.floorHeight)
    m.marioObj.oWallHitboxRadius = 1]]
end
end
function forcesize(msg)
    if msg == "off" then
        gGlobalSyncTable.gSize.x = "off"
        return true
    end
    gGlobalSyncTable.gSize.x=0
    gGlobalSyncTable.gSize.y=0
    gGlobalSyncTable.gSize.z=0
    if string.find(msg, " ") == nil then
        gGlobalSyncTable.gSize.x = tonumber(msg)
        gGlobalSyncTable.gSize.y = tonumber(msg)
        gGlobalSyncTable.gSize.z = tonumber(msg)
        return true
    end
    local xyz = {"", "", ""}
    local index = 1
    for i = 1, #msg do
        local currentLetter = msg:sub(i, i)
        if tonumber(currentLetter) ~= nil or currentLetter == "." or currentLetter == "-" then
            xyz[index] = xyz[index].. currentLetter
        else
            index = index + 1
        end
    end
    if index > 3 then
        return false
    end
    if tonumber(xyz[1]) ~= nil then
        gGlobalSyncTable.gSize.x = tonumber(xyz[1])
    else
        gGlobalSyncTable.gSize.x = 0
        djui_chat_message_create("Size X not found.")
    end

    if tonumber(xyz[2]) ~= nil then
        gGlobalSyncTable.gSize.y = tonumber(xyz[2])
    else
        gGlobalSyncTable.gSize.y = 0
        djui_chat_message_create("Size Y not found.")
    end

    if tonumber(xyz[3]) ~= nil then
        gGlobalSyncTable.gSize.z = tonumber(xyz[3])
    else
        gGlobalSyncTable.gSize.z = 0
        djui_chat_message_create("Size Z not found.")
    end
    return true
end
function toggle_mult(msg)
    gPlayerSyncTable[0].multMov = not gPlayerSyncTable[0].multMov
    return true
end
function fix_respawn(m)
    prevPos[m.playerIndex].x = "skip"
end
function toggle_cam()
    camtoggle = not camtoggle
    djui_chat_message_create("Toggled: "..(camtoggle and "ON" or "OFF"))
    return true
end
function act_fix(m,action)
    if action == ACT_LEDGE_GRAB or action == ACT_LEDGE_CLIMB_DOWN or m.action & ACT_FLAG_ON_POLE ~= 0 or action & ACT_FLAG_HANGING ~= 0 or m.action == ACT_PULLING_DOOR or m.action == m.action == ACT_PUSHING_DOOR then
        prevPos[m.playerIndex].x = "skip"
    end
end
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, get_prev_pos)
hook_event(HOOK_ON_DEATH,fix_respawn)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION,act_fix)
hook_chat_command("size", "[number (number number)]", set_size)
hook_chat_command("mult","to toggle size-speed multiplier",toggle_mult)
hook_chat_command("sizecam","to toggle camera effects when resizing.",toggle_cam)
if network_is_server() then
    hook_chat_command("forcesize", "[number (number number)] to force a size on all players. \"off\" to turn off.",forcesize)
    hook_chat_command("max-size", "[number]", max_size_command)
end