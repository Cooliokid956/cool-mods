local function update()
    local chomp = obj_get_nearest_object_with_behavior_id(gMarioStates[0].marioObj, id_bhvChainChomp)
    if chomp and chomp.oChainChompReleaseStatus == CHAIN_CHOMP_RELEASED_LUNGE_AROUND then
        cutscene_object(0, nil)
        djui_chat_message_create("Trigger")
    end
    if gCamera.cutscene == CUTSCENE_STAR_SPAWN or gCamera.cutscene == CUTSCENE_RED_COIN_STAR_SPAWN then
        gCamera.cutscene = 0
        play_cutscene(gCamera)
        gMarioStates[0].freeze = 0
        disable_time_stop_including_mario()
    end
end
hook_event(HOOK_UPDATE, update)