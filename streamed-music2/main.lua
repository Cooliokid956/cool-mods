--- @class BGM
--- @field audio     string
--- @field loopStart integer?
--- @field loopEnd   integer?
--- @field volume    number?
--- @field name      string
--- @field stream    ModAudio

local process = {
    SEQ_PLAYER_LEVEL,
    SEQ_PLAYER_ENV
}

local function correct_volume(vol, player)
    return vol * (is_game_paused() and .31 or 1) * sequence_player_get_fade_volume(player)
end

--[[
    Notable sequences:
    SEQ_EVENT_CUTSCENE_COLLECT_STAR - self explanatory
    SEQ_EVENT_PIRANHA_PLANT - lullaby music when approaching a piranha plant
]]

local NONE
local bgms = {
    [SEQ_SOUND_PLAYER]                = NONE,
    [SEQ_EVENT_CUTSCENE_COLLECT_STAR] = { audio = "S1MMU 13.mp3", noloop = true },
    [SEQ_MENU_TITLE_SCREEN]           = { audio = "S1MMU 05.mp3" },
    [SEQ_LEVEL_GRASS]                 = { audio = "S1MMU 07.mp3" },
    [SEQ_LEVEL_INSIDE_CASTLE]         = { audio = "S1MMU 08.mp3" },
    [SEQ_LEVEL_WATER]                 = { audio = "S1MMU 10.mp3" },
    [SEQ_LEVEL_HOT]                   = { audio = "S1MMU 11.mp3" },
    [SEQ_LEVEL_BOSS_KOOPA]            = { audio = "S1MMU 12.mp3" },
    [SEQ_LEVEL_SNOW]                  = { audio = "S1MMU 13.mp3" },
    [SEQ_LEVEL_SLIDE]                 = { audio = "S1MMU 14.mp3" },
    [SEQ_LEVEL_SPOOKY]                = { audio = "S1MMU 15.mp3" },
    [SEQ_EVENT_PIRANHA_PLANT]         = { audio = "S1MMU 16.mp3" },
    [SEQ_LEVEL_UNDERGROUND]           = { audio = "S1MMU 25.mp3" },
    [SEQ_MENU_STAR_SELECT]            = { audio = "S1MMU 19.mp3", noloop = true },
    [SEQ_EVENT_POWERUP]               = { audio = "S1MMU 16.mp3" },
    [SEQ_EVENT_METAL_CAP]             = { audio = "S1MMU 25.mp3" },
    [SEQ_EVENT_KOOPA_MESSAGE]         = { audio = "S1MMU 25.mp3" },
    [SEQ_LEVEL_KOOPA_ROAD]            = { audio = "S1MMU 25.mp3" },
    [SEQ_EVENT_HIGH_SCORE]            = { audio = "S1MMU 25.mp3" },
    [SEQ_EVENT_MERRY_GO_ROUND]        = { audio = "S1MMU 25.mp3" },
    [SEQ_EVENT_RACE]                  = { audio = "S1MMU 16.mp3" },
    [SEQ_EVENT_CUTSCENE_STAR_SPAWN]   = { audio = "S1MMU 25.mp3", noloop = true },
    [SEQ_EVENT_BOSS]                  = { audio = "S1MMU 08.mp3" },
    [SEQ_EVENT_CUTSCENE_COLLECT_KEY]  = NONE,
    [SEQ_EVENT_ENDLESS_STAIRS]        = NONE,
    [SEQ_LEVEL_BOSS_KOOPA_FINAL]      = NONE,
    [SEQ_EVENT_CUTSCENE_CREDITS]      = NONE,
    [SEQ_EVENT_SOLVE_PUZZLE]          = NONE,
    [SEQ_EVENT_TOAD_MESSAGE]          = NONE,
    [SEQ_EVENT_PEACH_MESSAGE]         = NONE,
    [SEQ_EVENT_CUTSCENE_INTRO]        = NONE,
    [SEQ_EVENT_CUTSCENE_VICTORY]      = NONE,
    [SEQ_EVENT_CUTSCENE_ENDING]       = NONE,
    [SEQ_MENU_FILE_SELECT]            = NONE,
    [SEQ_EVENT_CUTSCENE_LAKITU]       = NONE,
    -- from now on, sequences 35-127 are fair game
}
local noLoop = {
    SEQ_EVENT_CUTSCENE_COLLECT_STAR,
    SEQ_MENU_STAR_SELECT,
    SEQ_EVENT_KOOPA_MESSAGE,
    SEQ_EVENT_CUTSCENE_STAR_SPAWN
}
for _, SEQ in pairs(noLoop) do
    noLoop[bgms[SEQ]] = 1
end

local names = {
    [SEQ_SOUND_PLAYER] = "SEQ_SOUND_PLAYER",
    [SEQ_EVENT_CUTSCENE_COLLECT_STAR] = "SEQ_EVENT_CUTSCENE_COLLECT_STAR",
    [SEQ_MENU_TITLE_SCREEN] = "SEQ_MENU_TITLE_SCREEN",
    [SEQ_LEVEL_GRASS] = "SEQ_LEVEL_GRASS",
    [SEQ_LEVEL_INSIDE_CASTLE] = "SEQ_LEVEL_INSIDE_CASTLE",
    [SEQ_LEVEL_WATER] = "SEQ_LEVEL_WATER",
    [SEQ_LEVEL_HOT] = "SEQ_LEVEL_HOT",
    [SEQ_LEVEL_BOSS_KOOPA] = "SEQ_LEVEL_BOSS_KOOPA",
    [SEQ_LEVEL_SNOW] = "SEQ_LEVEL_SNOW",
    [SEQ_LEVEL_SLIDE] = "SEQ_LEVEL_SLIDE",
    [SEQ_LEVEL_SPOOKY] = "SEQ_LEVEL_SPOOKY",
    [SEQ_EVENT_PIRANHA_PLANT] = "SEQ_EVENT_PIRANHA_PLANT",
    [SEQ_LEVEL_UNDERGROUND] = "SEQ_LEVEL_UNDERGROUND",
    [SEQ_MENU_STAR_SELECT] = "SEQ_MENU_STAR_SELECT",
    [SEQ_EVENT_POWERUP] = "SEQ_EVENT_POWERUP",
    [SEQ_EVENT_METAL_CAP] = "SEQ_EVENT_METAL_CAP",
    [SEQ_EVENT_KOOPA_MESSAGE] = "SEQ_EVENT_KOOPA_MESSAGE",
    [SEQ_LEVEL_KOOPA_ROAD] = "SEQ_LEVEL_KOOPA_ROAD",
    [SEQ_EVENT_HIGH_SCORE] = "SEQ_EVENT_HIGH_SCORE",
    [SEQ_EVENT_MERRY_GO_ROUND] = "SEQ_EVENT_MERRY_GO_ROUND",
    [SEQ_EVENT_RACE] = "SEQ_EVENT_RACE",
    [SEQ_EVENT_CUTSCENE_STAR_SPAWN] = "SEQ_EVENT_CUTSCENE_STAR_SPAWN",
    [SEQ_EVENT_BOSS] = "SEQ_EVENT_BOSS",
    [SEQ_EVENT_CUTSCENE_COLLECT_KEY] = "SEQ_EVENT_CUTSCENE_COLLECT_KEY",
    [SEQ_EVENT_ENDLESS_STAIRS] = "SEQ_EVENT_ENDLESS_STAIRS",
    [SEQ_LEVEL_BOSS_KOOPA_FINAL] = "SEQ_LEVEL_BOSS_KOOPA_FINAL",
    [SEQ_EVENT_CUTSCENE_CREDITS] = "SEQ_EVENT_CUTSCENE_CREDITS",
    [SEQ_EVENT_SOLVE_PUZZLE] = "SEQ_EVENT_SOLVE_PUZZLE",
    [SEQ_EVENT_TOAD_MESSAGE] = "SEQ_EVENT_TOAD_MESSAGE",
    [SEQ_EVENT_PEACH_MESSAGE] = "SEQ_EVENT_PEACH_MESSAGE",
    [SEQ_EVENT_CUTSCENE_INTRO] = "SEQ_EVENT_CUTSCENE_INTRO",
    [SEQ_EVENT_CUTSCENE_VICTORY] = "SEQ_EVENT_CUTSCENE_VICTORY",
    [SEQ_EVENT_CUTSCENE_ENDING] = "SEQ_EVENT_CUTSCENE_ENDING",
    [SEQ_MENU_FILE_SELECT] = "SEQ_MENU_FILE_SELECT",
    [SEQ_EVENT_CUTSCENE_LAKITU] = "SEQ_EVENT_CUTSCENE_LAKITU",
}

--- @type (BGM?)[]
local curBGMs = {}
--- @type (BGM?)[]
local targetBGMs = {}

local function handle(player)
    local bgm = targetBGMs[player]
    local curBGM = curBGMs[player]

    if bgm ~= curBGM then
        if curBGM and curBGM.stream then
            audio_stream_stop(curBGM.stream)
        end
        curBGMs[player] = bgm

        if bgm and bgm.audio then
            bgm.volume = bgm.volume or 1
            bgm.stream = audio_stream_load(bgm.audio)
            if bgm.stream then
                audio_stream_set_looping(bgm.stream, not noLoop[bgm])
                if bgm.loopStart and bgm.loopEnd then
                    audio_stream_set_loop_points(bgm.stream, bgm.loopStart, bgm.loopEnd)
                end
                audio_stream_play(bgm.stream, true, correct_volume(bgm.volume, player))
            else
                log_to_console('File not found: ' .. bgm.audio, CONSOLE_MESSAGE_ERROR)
                print("File not found: " .. bgm.audio)
            end
        end
    end

    if bgm and bgm.stream then
        audio_stream_set_volume(bgm.stream, correct_volume(bgm.volume, player))
    end
end

function handle_players()
    for _, player in pairs(process) do
        handle(player)
    end
end

local function override_music(player, seqID)
    if player ~= SEQ_PLAYER_SFX then
        log_to_console("player "..player..": "..(names[seqID] or ""))
        if bgms[seqID] then
            targetBGMs[player] = bgms[seqID]
            return 0
        else targetBGMs[player] = nil end
    end
end

hook_event(HOOK_UPDATE, handle_players)
hook_event(HOOK_ON_SEQ_LOAD, override_music)

local scroll = 0
hook_event(HOOK_ON_HUD_RENDER, function ()
    local click = djui_hud_get_mouse_buttons_pressed()
    local down = djui_hud_get_mouse_buttons_down()
    local release = djui_hud_get_mouse_buttons_released()
    local scrolled = djui_hud_get_mouse_scroll_y()
    scroll = scroll + scrolled
    if scrolled ~= 0 then
        log_to_console("Scrolled!")
    end
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)
    local s = 4
    local x = djui_hud_get_mouse_x() + scroll*12
    local y = djui_hud_get_mouse_y()-60*s

    djui_hud_print_text(""..click, x, y, s)
    djui_hud_print_text(""..down, x, y+16*s, s)
    djui_hud_print_text(""..release, x, y+32*s, s)
end)