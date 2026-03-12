-- name: !Log Hook Callbacks
local hooks = {
[0]="HOOK_UPDATE",
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

local function table_join(list, sep)
    list = table.copy(list)
    for i = 1, #list do
        list[i] = tostring(list[i])
    end
    return table.concat(list, sep)
end

local lastHookEventType
local requestHooks
hook_chat_command("queue", "hooks", function ()
    lastHookEventType = nil
    requestHooks = 0
    return true
end)

local og_hook_event = hook_event
--- @param hookEventType LuaHookedEventType When a function should run
--- @param func fun(...: any): any The function to run
--- Different hooks can pass in different parameters and have different return values. Be sure to read the hooks guide for more information.
function _G.hook_event(hookEventType, func)
    og_hook_event(hookEventType, function (...)
        if lastHookEventType == HOOK_UPDATE and hookEventType ~= HOOK_UPDATE then
            if requestHooks == 0 then
                requestHooks = 1
                print("CAPTURE START")
            elseif requestHooks == 1 then
                requestHooks = nil
                print("CAPTURE STOP")
            end
        end

        local s
        if requestHooks == 1 then
            if lastHookEventType ~= hookEventType then
                s = "\n"..hooks[hookEventType]
            else
                s = (" "):rep(#hooks[hookEventType])
            end
        end

        lastHookEventType = hookEventType

        if requestHooks == 1 then
            s = s.." | "
            local mod = get_active_mod()
            local file = "from "..mod.name
            if mod.name ~= mod.relativePath then
                file = file.." ("..mod.relativePath..")"
            end
            print(s..file)

            s = (" "):rep(#hooks[hookEventType]).." | > "
            local sig = ""
            local params = { ... }
            if #params > 0 then
                sig = sig.."("..table_join(params, ", ")..")"
            end
            local returns = { func(...) }
            if #returns > 0 then
                sig = sig.." -> "..table_join(returns, ", ")
            end
            if #sig > 0 then print(s..sig) end

            return table.unpack(returns)
        else return func(...) end
    end)
end

hook_event(HOOK_UPDATE, function () end) -- just in case