---@param m MarioState
---@param o Object
---@param int integer
hook_event(HOOK_ON_ATTACK_OBJECT, function (m, o, int)
    obj_spawn_loot_yellow_coins(o, o.oNumLootCoins, 2)
end)