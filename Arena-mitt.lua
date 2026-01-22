-- name: .Arena Mitt

-- real_get_field=_get_field
-- function fake_get_field(lot, pointer, key, table)
--     local get = real_get_field(lot, pointer, key, table)
--     print("get:", lot, pointer, key, get)
--     return get
-- end

-- _G._get_field = fake_get_field
-- -- _G._get_field = real_get_field

-- real_set_field=_set_field
-- function fake_set_field(lot, pointer, key, val, table)
--     print("set:", lot, pointer, key, val)
--     return real_set_field(lot, pointer, key, val, table)
-- end
-- _G._set_field = fake_set_field
-- -- _G._set_field = real_set_field

real_rawset = rawset
function fake_rawset(table, index, value)
    print("rawset:", table, index, value)
    return real_rawset(table, index, value)
end
_G.rawset = fake_rawset

real_rawget = rawget
function fake_rawget(table, index)
    local get = real_rawget(table, index)
    print("rawget:", table, index, get)
    return get
end
_G.rawget = fake_rawget

GAME_STATE_ACTIVE   = 1
GAME_STATE_INACTIVE = 2

_G.GAME_MODE_DM    = 1
_G.GAME_MODE_TDM   = 2
_G.GAME_MODE_CTF   = 3
_G.GAME_MODE_FT    = 4
_G.GAME_MODE_TFT   = 5
_G.GAME_MODE_KOTH  = 6
_G.GAME_MODE_TKOTH = 7

_G.gGameModes = {
    [GAME_MODE_DM]    = { shortName = 'DM',    name = 'match',            teams = false, teamSpawns = false, useScore = false, scoreCap = 10,  minPlayers = 0, maxPlayers = 99 },
    [GAME_MODE_TDM]   = { shortName = 'TDM',   name = 'Deathmatch',       teams = true,  teamSpawns = false, useScore = false, scoreCap = 20,  minPlayers = 4, maxPlayers = 99 },
    [GAME_MODE_CTF]   = { shortName = 'CTF',   name = 're the Flag',      teams = true,  teamSpawns = true,  useScore = false, scoreCap =  3,  minPlayers = 4, maxPlayers = 99 },
    [GAME_MODE_FT]    = { shortName = 'FT',    name = 'Tag',              teams = false, teamSpawns = false, useScore = true,  scoreCap = 60,  minPlayers = 0, maxPlayers = 99 },
    [GAME_MODE_TFT]   = { shortName = 'TFT',   name = 'Flag Tag',         teams = true,  teamSpawns = false, useScore = true,  scoreCap = 120, minPlayers = 4, maxPlayers = 99 },
    [GAME_MODE_KOTH]  = { shortName = 'KOTH',  name = 'of the Hill',      teams = false, teamSpawns = false, useScore = true,  scoreCap = 45,  minPlayers = 0, maxPlayers = 6  },
    [GAME_MODE_TKOTH] = { shortName = 'TKOTH', name = 'King of the Hill', teams = true,  teamSpawns = false, useScore = true,  scoreCap = 90,  minPlayers = 4, maxPlayers = 99 }
}

_G.LEVEL_ARENA_ORIGIN    = level_register('level_arena_origin_entry',    COURSE_NONE, 'Origin',    'origin',    28000, 0x28, 0x28, 0x28)
_G.LEVEL_ARENA_SKY_BEACH = level_register('level_arena_sky_beach_entry', COURSE_NONE, 'Sky Beach', 'beach',     28000, 0x28, 0x28, 0x28)
_G.LEVEL_ARENA_PILLARS   = level_register('level_arena_pillars_entry',   COURSE_NONE, 'Pillars',   'pillars',   28000, 0x28, 0x28, 0x28)
_G.LEVEL_ARENA_FORTS     = level_register('level_arena_forts_entry',     COURSE_NONE, 'Forts',     'forts',     28000, 0x28, 0x28, 0x28)
_G.LEVEL_ARENA_CITADEL   = level_register('level_arena_citadel_entry',   COURSE_NONE, 'Citadel',   'citadel',   28000, 0x28, 0x28, 0x28)
_G.LEVEL_ARENA_SPIRE     = level_register('level_arena_spire_entry',     COURSE_NONE, 'Spire',     'spire',     28000, 0x28, 0x28, 0x28)
_G.LEVEL_ARENA_RAINBOW   = level_register('level_arena_rainbow_entry',   COURSE_NONE, 'Rainbow',   'rainbow',   28000, 0x28, 0x28, 0x28)

function names()
    print(_G.gGameModes[1].name)
    print(_G.gGameModes[2].name)
    print(_G.gGameModes[3].name)
    print(_G.gGameModes[4].name)
    print(_G.gGameModes[5].name)
    print(_G.gGameModes[6].name)
    print(_G.gGameModes[7].name)
end
names()

hook_chat_command("names", "out", names)
_G.rawget = real_rawget
_G.rawset = real_rawset