-- name: Wario Fucking Dies

local event
local deathTimer = 0
local powerHidden

---@param m MarioState
hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex == 0 then
        local sequence = {
            init = m.character.type == CT_WARIO and m.action == ACT_TOP_OF_POLE, -- comment for death on plunge
            -- init = m.character.type == CT_WARIO and m.action == ACT_WATER_PLUNGE, -- uncomment for death on plunge

            { pass = m.action == ACT_TOP_OF_POLE_JUMP, abort = m.action ~= ACT_TOP_OF_POLE }, -- comment for death on plunge
            {
                pass = m.action == ACT_WATER_PLUNGE, abort = m.action ~= ACT_TOP_OF_POLE_JUMP,
                onPass =
                function (m)
                    local wedges = math.min(m.health >> 8, 8)
                    if wedges > 7 then
                        hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~HUD_DISPLAY_FLAG_POWER)
                        powerHidden = 1
                    end

                    m.action = ACT_WATER_DEATH
                end
            },
            -- nil, -- uncomment for death on plunge
            nil,
            {
                pass = m.action == ACT_WATER_DEATH, abort = m.action ~= ACT_WATER_DEATH,
                onPass =
                function (m)
                    event = event - 1
                    deathTimer = deathTimer + 1
                    if deathTimer > 50 then
                        deathTimer = 0
                        level_trigger_warp(m, WARP_OP_DEATH)
                    end
                end
            },

            close = function (m)
                if powerHidden then
                    hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) | HUD_DISPLAY_FLAG_POWER)
                    powerHidden = nil
                end
            end
        }
        if not event and sequence.init then event = 1 end
        if event then
            local ev = sequence[event]
            if ev then
                if ev.pass then
                    event = event + 1
                    if ev.onPass then ev.onPass(m) end
                elseif ev.abort then
                    event = nil
                    return sequence.close(m)
                end
            end
        end
    end
end)

hook_event(HOOK_ON_DEATH, function (m)
    if m.playerIndex == 0 and event then
        event = 4
        return false
    end
end)
hook_event(HOOK_CHARACTER_SOUND, function (m, sound)
    if m.playerIndex == 0 and event and sound == CHAR_SOUND_HAHA_2 then
        local SOUND_WARIO_WAAAOOOW = SOUND_ARG_LOAD(SOUND_BANK_WARIO_VOICE, 0x10, 0xC0, SOUND_NO_PRIORITY_LOSS | SOUND_DISCRETE)
        stop_sound(SOUND_WARIO_WAAAOOOW, m.marioObj.header.gfx.cameraToObject)
    return 0 end
end)