-- name: .Trigger Hooks
hookfuncs = {}
_ = hook_event
--- @param hookEventType LuaHookedEventType When a function should run
--- @param func fun(...: any): any The function to run
--- Different hooks can pass in different parameters and have different return values. Be sure to read the hooks guide for more information.
_G.hook_event = function (hookEventType, func)
    if not hookfuncs[hookEventType] then hookfuncs[hookEventType] = {} end
    table.insert(hookfuncs[hookEventType], func)
    _(hookEventType, func)
end

_G.trigger_hook = function (hookEventType, ...)
    if not hookfuncs[hookEventType] then print("no functions!") return end
    for _, func in ipairs(hookfuncs[hookEventType]) do
        func(...)
    end
end

hook_chat_command("hook", "trigger", function (msg)
    trigger_hook(tonumber(msg))
    return true
end)