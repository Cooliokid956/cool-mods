gLevelValues.entryLevel = LEVEL_BOB
gLevelValues.fixCollisionBugs = true
gServerSettings.stayInLevelAfterStar = 0
gLevelValues.disableActs = true

-- Give names
smlua_text_utils_course_acts_replace(COURSE_BOB, "   Super Kaizo Drownio Road",
    "Towards The Blissful Blue Sky", -- easy
    "To The Top Of The Hill", -- kotq
    "Hard Kicks For Red Bliss", -- hard
    "Red Coins In The Wet World", -- reds
    "Secrets Of The Walls", -- secret
    "Sliding Around The Wall" -- bonus
)
-- "Final Countdown" boss level

-- Replace sequences
smlua_audio_utils_replace_sequence(SEQ_LEVEL_SLIDE, 0x2A, 122, "rainbow")

-- Disable various HUD elements
hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~(HUD_DISPLAY_FLAG_LIVES | HUD_DISPLAY_FLAG_COIN_COUNT))
end)

-- hook_event(HOOK_MARIO_UPDATE, function (m)
--     m.numLives = 5
-- end)

-- Animate 1uicksand
local quicksand_frame = {
    get_texture_info("quicksand1"),
    get_texture_info("quicksand2"),
    get_texture_info("quicksand3"),
    get_texture_info("quicksand2")
}

function animate_quicksand()
    texture_override_set("sky_09008000", quicksand_frame[(get_global_timer() // 6) % #quicksand_frame + 1])
end
hook_event(HOOK_UPDATE, animate_quicksand)