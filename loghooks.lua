local hooks = {
    "HOOK_UPDATE",
    "HOOK_MARIO_UPDATE",
    "HOOK_BEFORE_MARIO_UPDATE",
    "HOOK_ON_SET_MARIO_ACTION",
    "HOOK_BEFORE_PHYS_STEP",
    "HOOK_ALLOW_PVP_ATTACK",
    "HOOK_ON_PVP_ATTACK",
    "HOOK_ON_PLAYER_CONNECTED",
    "HOOK_ON_PLAYER_DISCONNECTED",
    "HOOK_ON_HUD_RENDER",
    "HOOK_ALLOW_INTERACT",
    "HOOK_ON_INTERACT",
    "HOOK_ON_LEVEL_INIT",
    "HOOK_ON_WARP",
    "HOOK_ON_SYNC_VALID",
    "HOOK_ON_OBJECT_UNLOAD",
    "HOOK_ON_SYNC_OBJECT_UNLOAD",
    "HOOK_ON_PAUSE_EXIT",
    "HOOK_GET_STAR_COLLECTION_DIALOG",
    "HOOK_ON_SET_CAMERA_MODE",
    "HOOK_ON_OBJECT_RENDER",
    "HOOK_ON_DEATH",
    "HOOK_ON_PACKET_RECEIVE",
    "HOOK_USE_ACT_SELECT",
    "HOOK_ON_CHANGE_CAMERA_ANGLE",
    "HOOK_ON_SCREEN_TRANSITION",
    "HOOK_ALLOW_HAZARD_SURFACE",
    "HOOK_ON_CHAT_MESSAGE",
    "HOOK_OBJECT_SET_MODEL",
    "HOOK_CHARACTER_SOUND",
    "HOOK_BEFORE_SET_MARIO_ACTION",
    "HOOK_JOINED_GAME",
    "HOOK_ON_OBJECT_ANIM_UPDATE",
    "HOOK_ON_DIALOG",
    "HOOK_ON_EXIT",
    "HOOK_DIALOG_SOUND",
    "HOOK_ON_HUD_RENDER_BEHIND",
    "HOOK_ON_COLLIDE_LEVEL_BOUNDS",
    "HOOK_MIRROR_MARIO_RENDER",
    "HOOK_MARIO_OVERRIDE_PHYS_STEP_DEFACTO_SPEED",
    "HOOK_ON_OBJECT_LOAD",
    "HOOK_ON_PLAY_SOUND",
    "HOOK_ON_SEQ_LOAD",
    "HOOK_ON_ATTACK_OBJECT",
    "HOOK_ON_LANGUAGE_CHANGED",
    "HOOK_ON_MODS_LOADED",
    "HOOK_ON_NAMETAGS_RENDER",
    "HOOK_ON_DJUI_THEME_CHANGED",
    "HOOK_ON_GEO_PROCESS",
    "HOOK_BEFORE_GEO_PROCESS",
    "HOOK_ON_GEO_PROCESS_CHILDREN",
    "HOOK_MARIO_OVERRIDE_GEOMETRY_INPUTS",
    "HOOK_ON_INTERACTIONS",
    "HOOK_ALLOW_FORCE_WATER_ACTION",
    "HOOK_BEFORE_WARP",
    "HOOK_ON_INSTANT_WARP",
    "HOOK_MARIO_OVERRIDE_FLOOR_CLASS",
    "HOOK_ON_ADD_SURFACE",
    "HOOK_ON_CLEAR_AREAS",
    "HOOK_ON_PACKET_BYTESTRING_RECEIVE",
}

local requestHooks
local hooksRan
hook_chat_command("queue", "hooks", function ()
    hooksRan = {}
    requestHooks = 0
    return true
end)
function LOG_HOOK(HOOK)
    return function (...)
        if requestHooks == 1 then
            print(HOOK, ...)
        end
        if HOOK == "HOOK_UPDATE" then
            if requestHooks == 0 then
                requestHooks = 1
            elseif requestHooks == 1 then
                requestHooks = nil
            end
            return
        end
    end
end
for index, hook in ipairs(hooks) do
    hook_event(_ENV[hook], LOG_HOOK(hook))
end