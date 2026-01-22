-- name: sm64ex-coop Theme Guide
-- description: A guide to unlocking all of sm64coopdx's secrets

local guide = {
    "How to enable sm64ex-coop theme:",
    "",
    "1. Close the game",
    "2. Locate your sm64config.txt",
    "3. Add a new line (IMPORTANT: the line must be inserted below \"compress_on_startup\" and not any of the mod/moderator/save name options), inside it type:",
    "ex_coop_theme true",
    "3. Save sm64config.txt",
    "4. Open the game",
    "",
    "Enjoy!"
}

local msg
hook_event(HOOK_UPDATE, function ()
    if not msg then
        msg = 1
        for _, s in ipairs(guide) do
            djui_chat_message_create(s)
        end
    end
end)