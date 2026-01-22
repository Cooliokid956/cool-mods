local function djui_chat_message_create_global(message)
    djui_chat_message_create(message)
    network_send(true, { msg = message })
end
_G.djui_chat_message_create_global = djui_chat_message_create_global

hook_event(HOOK_ON_PACKET_RECEIVE, function (data)
    djui_chat_message_create(data.msg)
end)

hook_chat_command("send", "everyone a text", function (msg)
    djui_chat_message_create_global(msg)
    return true
end)