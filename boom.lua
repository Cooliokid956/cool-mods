-- name: mod
-- description: you're never gonna see this so why

function onpvp(me, you)
    if you.playerIndex ~= 0 then
        die()
    end
    local victimColor = network_get_player_text_color_string(npVictim.localIndex)
    local attackerColor = network_get_player_text_color_string(npAttacker.localIndex)
    djui_popup_create(attackerColor .. npAttacker.name .. normalColor .. " killed " .. victimColor .. npVictim.name .. normalColor .. "!", 2)

end
function die()
    die()
end

hook_event(HOOK_ON_PVP_ATTACK, onpvp)