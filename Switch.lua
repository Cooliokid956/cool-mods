local _break = {}
local default = {}

local SCAN = 0
local SEEK = 1
local SUCC = 2

function switch(exp)
    return setmetatable({}, {
        __call = function (_, cases)
            local state = SCAN
            for _, entry in ipairs(cases) do
                if state == SUCC then
                    if entry == _break then return end
                    state = SCAN
                end
                if entry == default then state = SEEK end

                local t = type(entry)
                if t ~= "function" then
                    if state == SCAN and exp == entry then
                        state = SEEK
                    end
                elseif state == SEEK then
                    entry()
                    state = SUCC
                end
            end
        end
    })
end
function case(comp) return comp end


hook_chat_command("switch", "case", function (msg)
    switch (tonumber(msg)) {
        case (1),
        case (2),                                                                                                 function ()
            djui_chat_message_create("so it's either 1 or 2")                                                     end,
            _break,

        case (3),
        case (5),                                                                                                 function ()
            djui_chat_message_create("this may be a 3 or 5")                                                      end,
            _break,

        default,                                                                                                  function ()
            djui_chat_message_create("Not a 1, 2, 3 or 5")                                                        end,
            _break,
    }

    return true
end)