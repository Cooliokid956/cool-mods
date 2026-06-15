-- name: Paintings Editor
local field = "size"
local painting = gPaintingValues.cotmc_painting
hook_chat_command("pt", "set painting", function (p)
    painting = gPaintingValues[p]
    return true
end)
hook_chat_command("pf", "set field", function (f)
    field = f
    return true
end)
hook_chat_command("ps", "set value", function (i)
    value = tonumber(i)
    painting[field] = value
    return true
end)
hook_chat_command("pg", "get value", function ()
    djui_chat_message_create(""..painting[field])
    return true
end)

-- id
-- imageCount
-- textureType
-- lastFloor
-- currFloor
-- floorEntered
-- state
-- pitch
-- yaw
-- posX
-- posY
-- posZ
-- currRippleMag
-- passiveRippleMag
-- entryRippleMag
-- rippleDecay
-- passiveRippleDecay
-- entryRippleDecay
-- currRippleRate
-- passiveRippleRate
-- entryRippleRate
-- dispersionFactor
-- passiveDispersionFactor
-- entryDispersionFactor
-- rippleTimer
-- rippleX
-- rippleY
-- textureWidth
-- textureHeight
-- rippleTrigger
-- alpha
-- marioWasUnder
-- marioIsUnder
-- marioWentUnder
-- size