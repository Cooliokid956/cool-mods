-- name: ! Trace HUD Functions

local get_mouse, get_scroll = djui_hud_get_mouse_buttons_down, djui_hud_get_mouse_scroll_y

local maxCalls = -1
local numCalls = 0
local reportAfter = 0

for name, func in pairs(_G) do
    name = tostring(name)
    if type(func) == "function" and name:find("djui_hud_") == 1 then
        print("Found HUD function " .. name)
        local count = not (name:find("_get_") or name:find("_set_") or name:find("_measure_") or name:find("_is_"))
        _G[name] = function (...)
            if count then
                if numCalls == maxCalls then return end
                numCalls = numCalls + 1
            end
            if count and numCalls > reportAfter or maxCalls < 0 then
                print(get_active_mod().relativePath .. ": " ..name .. " is running")
            end
            return func(...)
        end
    end
end

local changeDir = 0
local changeTimer = 0
local c = gControllers[0]
hook_event(HOOK_UPDATE, function ()
    print("calls: "..numCalls)
    numCalls = 0

    if get_mouse() & M_MOUSE_BUTTON ~= 0 then
        reportAfter = maxCalls
    end

    local scroll = get_scroll()
    if scroll ~= 0 then
        maxCalls = math.max(-1, maxCalls + scroll) | 0
        djui_chat_message_create("max calls: ".. maxCalls)
    elseif c.buttonDown & (L_JPAD | R_JPAD) ~= 0 then
        if c.buttonPressed & (L_JPAD | R_JPAD) ~= 0 then
            changeDir = c.buttonPressed & L_JPAD ~= 0 and -7 or 7
            changeTimer = 0
        end

        local dec = signum_positive(changeDir)
        if changeTimer % changeDir == 0 then
            if changeDir - dec ~= 0 then
                changeDir = changeDir - dec
            end
            maxCalls = math.max(-1, maxCalls + dec)
            changeTimer = 0
            djui_chat_message_create("max calls: ".. maxCalls)
        end
        changeTimer = changeTimer + dec
        -- djui_chat_message_create("timer: ".. changeTimer)
        -- djui_chat_message_create("dir: ".. changeDir)
    end
end)