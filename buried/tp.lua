local lnp = gNetworkPlayers[0]
local lm = gMarioStates[0]

---@param s string
function split(s)
    local result = {}
    for match in s:gmatch(string.format("[^%s]+", " ")) do
        table.insert(result, match)
    end
    return result
end

function get_local_pos_data()
    return {
        id = lnp.globalIndex,
        x = lm.pos.x,
        y = lm.pos.y,
        z = lm.pos.z
    }
end
function on_packet(data)
    if data.op then
        isop = data.op
    return end
    if data.proxy then
        if data.id < 0 then
            return network_send(true, get_local_pos_data())
        end
        return network_send_to(data.id, true, get_local_pos_data())
    end
    warp_to_pos(network_player_from_global_index(data.id), data.x, data.y, data.z)
end

function get_id_name(s)
    local id = tonumber(s)
    local name = s
    if id then
        name = gNetworkPlayers[id].name
    else
        for i = 0, MAX_PLAYERS do
            if gNetworkPlayers[i].name == s then
                id = i
            end
        end
    end
    return (id or name) and { id = id, name = name } or nil
end

function warp_to_pos(np, x,y,z)
    if is_player_active(gMarioStates[np.localIndex]) == 0 then
        warp_to_level(np.currLevelNum, np.currAreaIndex, np.currActNum)
    end
    vec3f_copy(lm.pos, {x=x,y=y,z=z})
end
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet)

local teleporting
local targetpos = {x=0,y=0,z=0}
hook_chat_command("tp", "<@a/e/p/r/s|id/name> <@p/r/s|id/name>", function (msg)
    if not (network_is_server() or isop) then
        djui_chat_message_create("You do not have permission to use this command.")
    return true end
    local arg = split(msg)

    local data = get_local_pos_data()

    local p1 = get_id_name(arg[1])
    local p2 = get_id_name(arg[2])
    if #arg < 2 then
    elseif #arg == 2 then
        if not (arg[1]:find("@") or arg[1]:find("@")) then
            
        end
        if arg[1] == "@a" then
            if arg[2] == "@p" or arg[2] == "@s" then
                network_send(true, data)
            elseif arg[2] == "@r" then
                local i = network_player_connected_count()-1
                data.proxy = 1
                data.id = -1
            end
        end
    end
    return true
end)

if not network_is_server() then return end

function update_op(id, status)
    network_send_to(id, true, { op = status })
end
hook_chat_command("op", "<id/name>", function (msg)
    local id = tonumber(msg)
    local name = msg
    if id then
        name = gNetworkPlayers[id].name
    else
        for i = 0, MAX_PLAYERS do
            if gNetworkPlayers[i].name == msg then
                id = i
            end
        end
    end

    if not (id or name) then
        djui_chat_message_create("Unknown player!")
    return true end

    if mod_storage_load(name) ~= "1" then
        update_op(id, true)
    end
    return true
end)

hook_chat_command("deop", "<id/name>", function (msg)
    local id = tonumber(msg)
    local name = msg
    if id then
        name = gNetworkPlayers[id].name
    else
        for i = 0, MAX_PLAYERS do
            if gNetworkPlayers[i].name == msg then
                id = i
            end
        end
    end

    if not (id or name) then
        djui_chat_message_create("Unknown player!")
    return true end

    if mod_storage_load(name) == "1" then
        update_op(id, false)
    end
    return true
end)

hook_event(HOOK_ON_PLAYER_CONNECTED, function (m)
    local name = gNetworkPlayers[m.playerIndex].name
    if mod_storage_load(name) == "1" then
        update_op(m.playerIndex, true)
    end
end)

hook_event(HOOK_ON_PAUSE_EXIT, function (exit)
    -- djui_chat_message_create("This is a "..(exit and "castle" or "level").." exit")
    if gMarioStates[0].action & ACT_FLAG_AIR ~= 0 then
        djui_chat_message_create("...not gonna let you cheese that LOL")
        return false
    end
end)