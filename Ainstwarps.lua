local m = gMarioStates[0]
local np = gNetworkPlayers[0]
function SEQUENCE_ARGS(priority, seqId)
    return ((priority << 8) | seqId)
end

hook_event(HOOK_ON_INTERACT, function (m, o, type)
    if m.playerIndex == 0 and type == INTERACT_WARP and o.oInteractionSubtype ~= INT_SUBTYPE_FADING_WARP then
        local warp = area_get_warp_node_from_params(o).node
        print("warping to "..warp.destLevel, warp.destArea, np.currActNum, warp.destNode)
        warp_to_warpnode(warp.destLevel, warp.destArea, np.currActNum, warp.destNode)
    end
end)
hook_event(HOOK_ON_LEVEL_INIT, function()
    if m.flags & MARIO_METAL_CAP ~= 0 then
        play_cap_music(SEQUENCE_ARGS(4, SEQ_EVENT_METAL_CAP))
    end

    if m.flags & (MARIO_VANISH_CAP | MARIO_WING_CAP) ~= 0 then
        play_cap_music(SEQUENCE_ARGS(4, SEQ_EVENT_POWERUP))
    end
end)
play_transition(WARP_TRANSITION_FADE_INTO_CIRCLE)