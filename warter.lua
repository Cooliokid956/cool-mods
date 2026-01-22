-- name: .water!

local truewater = {}
local waters = 10

local trueY = {}

hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m)
    if m.playerIndex == 0 then
        for i = 0, waters do
            truewater[i] = get_environment_region(i)
        end
    end
    for i = 0, waters do
        set_environment_region(i, m.pos.y + (m.controller.buttonDown & Y_BUTTON ~= 0 and 1000 or -1000))
    end
    trueY[m.playerIndex] = m.pos.y
end)
hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex == MAX_PLAYERS-1 then
        for i = 0, waters do
            set_environment_region(i, truewater[i])
        end
    end
end)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function (m, action)
    if (action & ACT_GROUP_MASK == ACT_GROUP_SUBMERGED and m.action & ACT_GROUP_MASK ~= ACT_GROUP_SUBMERGED) -- enter water
    or (action & ACT_GROUP_MASK ~= ACT_GROUP_SUBMERGED and m.action & ACT_GROUP_MASK == ACT_GROUP_SUBMERGED) then -- exit water
        m.pos.y = trueY[m.playerIndex]
        print(((action & ACT_GROUP_MASK == ACT_GROUP_SUBMERGED and m.action & ACT_GROUP_MASK ~= ACT_GROUP_SUBMERGED) and "entered" or "exited")..math.random(4))
        print(action)
        if (action & ACT_GROUP_MASK ~= ACT_GROUP_SUBMERGED and m.action & ACT_GROUP_MASK == ACT_GROUP_SUBMERGED) then
            return ACT_FREEFALL
        end
    end
end)