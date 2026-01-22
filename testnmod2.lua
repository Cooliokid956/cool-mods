-- name: ..A text test

hook_event(HOOK_ON_CHAT_MESSAGE, function (m, msg)
    djui_chat_message_create("Bro's id is "..network_discord_id_from_local_index(m.playerIndex).." btw")
end)