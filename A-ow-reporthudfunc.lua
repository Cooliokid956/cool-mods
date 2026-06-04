-- name: ! Trace HUD Functions

for name, func in pairs(_G) do
    if type(func) == "function" and tostring(name):find("djui_hud_") == 1 then
        print("Found HUD function " .. name)
        _G[name] = function (...)
            print(get_active_mod().relativePath .. ": " ..name .. " is running")
            return func(...)
        end
    end
end