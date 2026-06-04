-- name: Report Character Sound

local soundNames = {}

for k, v in pairs(_G) do
    if k:find("CHAR_SOUND_") == 1 then soundNames[v] = k end
end

hook_event(HOOK_CHARACTER_SOUND, function (m, sound)
    djui_chat_message_create("Played sound " .. soundNames[sound])
end)