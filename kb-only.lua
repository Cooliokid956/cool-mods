-- name: Knockback Only

gServerSettings.playerInteractions = PLAYER_INTERACTIONS_SOLID

hook_event(HOOK_ON_PVP_ATTACK, function (attacker, victim)
    set_mario_action(victim, victim.prevAction, 0)
end)
local descStr = "to change strength (currently at %i)"
if network_is_server() then
    hook_chat_command(
        "kb-strength",
        descStr:format(gServerSettings.playerKnockbackStrength),
        function (str)
            update_chat_command_description("kb-strength", descStr:format(gServerSettings.playerKnockbackStrength))
            gServerSettings.playerKnockbackStrength = tonumber(str) or 25
            network_send(true, {gServerSettings.playerKnockbackStrength})
            return true
        end
    )
end

hook_event(HOOK_ON_PACKET_RECEIVE, function (p)
    gServerSettings.playerKnockbackStrength = p[1]
end)