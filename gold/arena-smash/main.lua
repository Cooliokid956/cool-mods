-- name: Smash Arena
-- description: Super Smash Arena!!\nREQUIRES ARENA
COURSE_HYRULE = 249
-- register the level(s) here
LEVEL_HYRULE = level_register('level_hyrule_entry', COURSE_HYRULE, 'Hyrule Castle', 'Hyrule Castle', 28000, 0x28, 0x28, 0x28)

-- make sure we don't add the level(s) twice
local sAddedLevels = false

function on_level_init()
    -- make sure we don't add the level(s) twice
    if sAddedLevels then return end
    sAddedLevels = true

    -- make sure Arena was loaded
    if not _G.Arena then
        djui_popup_create("Error: the Arena gamemode wasn't loaded!", 2)
        return
    end

    -- add the level(s) to arena
    _G.Arena.add_level(LEVEL_HYRULE, 'Hyrule Castle')
end

hook_event(HOOK_ON_LEVEL_INIT, on_level_init)

-- 2D CAM CODE START ---------------------------------------
-- 2D CAM CODE START ---------------------------------------
-- 2D CAM CODE START ---------------------------------------

local p = gNetworkPlayers[0]
local levels = {
    [LEVEL_HYRULE] = { 0,  false,  0 },
}
-- prevents players from using camera buttons (left/right) and stick up/down, unless in c-up mode
---@param m MarioState
function lockbuttons(m)
    if m.playerIndex ~= 0 then return end
    if not levels[p.currLevelNum] or gLakituState.mode == CAMERA_MODE_C_UP then return end

    m.controller.buttonPressed = m.controller.buttonPressed & ~L_CBUTTONS
    m.controller.buttonPressed = m.controller.buttonPressed & ~R_CBUTTONS

    --local curYaw = gLakituState.yaw
    --if curYaw < levels[p.currLevelNum][1] then
    --    m.controller.buttonPressed = m.controller.buttonPressed + L_CBUTTONS
    --elseif curYaw > levels[p.currLevelNum][1] then
    --    m.controller.buttonPressed = m.controller.buttonPressed + R_CBUTTONS
    --end
    gLakituState.yaw = levels[p.currLevelNum][1]
    gLakituState.nextYaw = levels[p.currLevelNum][1]
    m.area.camera.yaw = levels[p.currLevelNum][1]
    m.area.camera.nextYaw = levels[p.currLevelNum][1]
    m.controller.stickY = 0
    if m.controller.stickX == 0 then m.controller.stickMag = 0 end
end

function twodee(m)
    if levels[p.currLevelNum] then
        if levels[p.currLevelNum][2] then       -- if x is true,
            m.pos.x = levels[p.currLevelNum][3] -- lock x coordinate to the magic value
        else                                    -- if not,
            m.pos.z = levels[p.currLevelNum][3] -- lock z coordinate instead 
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, lockbuttons)
hook_event(HOOK_MARIO_UPDATE, twodee)