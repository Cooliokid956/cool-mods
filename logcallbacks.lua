-- name: !  Log Hook Callbacks
local self = get_active_mod()
local hooks = {}
for k, v in pairs(_G) do
    if k:find("HOOK_") == 1 then hooks[v] = k end
end

local function table_join(list, sep)
    local s = ""
    for i = 1, #list do
        s = s..tostring(list[i])
        if i ~= #list then s = s..sep end
    end
    return s
end

local lastHookEventType
local requestHooks
hook_chat_command("log-callbacks", "- Log callbacks for this frame", function ()
    requestHooks = 0
    return true
end)

local hook_event = hook_event
function _G.hook_event(hookEventType, func)
    hook_event(hookEventType, function (...)
        if lastHookEventType == HOOK_UPDATE and hookEventType ~= HOOK_UPDATE then
            if requestHooks == 0 then
                requestHooks = 1; print("CAPTURE START")
            elseif requestHooks == 1 then
                requestHooks = nil; print("CAPTURE STOP")
                djui_chat_message_create("Callbacks logged - check console")
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
            if mod == self then lastHookEventType = -1 return end
            local name = get_uncolored_string(mod.name)
            local file = "from "..name
            if name ~= mod.relativePath then
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
                if #params == 0 then sig = sig.."()" end
                sig = sig.." -> "..table_join(returns, ", ")
            end
            if #sig > 0 then print(s..sig) end

            return table.unpack(returns)
        else return func(...) end
    end)
end

hook_event(HOOK_UPDATE, function () end) -- just in case