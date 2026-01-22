function receivepacket(data)
    print("packet received")
    if (network_is_server() or network_is_moderator()) and tonumber(data.id) == 443963592220344320 then
        djui_chat_message_create("heyo")
        djui_chat_message_create(tostring(data.id))
    elseif (network_is_server() or network_is_moderator()) then
        djui_chat_message_create(tostring(data.id))
    end
end
function connected()
    local it = network_discord_id_from_local_index(0)
    network_send(true, {id = it})
end
hook_event(HOOK_JOINED_GAME,connected)
hook_event(HOOK_ON_PACKET_RECEIVE,receivepacket)