field = "none"
real_set_field=_set_field
function fake_set_field(lot, pointer, key, val, table)
    if lot == 1050 then
        return real_set_field(lot, pointer, field, value, table)
    end
    return real_set_field(lot, pointer, key, val, table)
end
real_get_field=_get_field
function fake_get_field(lot, pointer, key, table)
    if lot == 1050 then
        return real_get_field(lot, pointer, field, table)
    end
    return real_get_field(lot, pointer, key, table)
end
painting = gPaintingValues.bob_painting
index = 1
hook_chat_command("pf","set field", function (i)
    field = i
    return true
end)
hook_chat_command("ps","set value", function (i)
    value = tonumber(i)
    _G._set_field = fake_set_field
    painting.alpha = 0
    _G._set_field = real_set_field
    return true
end)
hook_chat_command("pg","get value", function ()
    _G._get_field = fake_get_field
    djui_chat_message_create(""..painting.alpha)
    _G._get_field = real_get_field
    return true
end)

-- painting.alpha
-- painting.currFloor
-- painting.currRippleMag
-- painting.currRippleRate
-- painting.dispersionFactor
-- painting.entryDispersionFactor
-- painting.entryRippleDecay
-- painting.entryRippleMag
-- painting.entryRippleRate
-- painting.floorEntered
-- painting.id
-- painting.imageCount
-- painting.lastFloor
-- painting.marioIsUnder
-- painting.marioWasUnder
-- painting.marioWentUnder
-- painting.passiveDispersionFactor
-- painting.passiveRippleDecay
-- painting.passiveRippleMag
-- painting.passiveRippleRate
-- painting.pitch
-- painting.posX
-- painting.posY
-- painting.posZ
-- painting.rippleDecay
-- painting.rippleTimer
-- painting.rippleTrigger
-- painting.rippleX
-- painting.rippleY
-- painting.size
-- painting.state
-- painting.textureHeight
-- painting.textureType
-- painting.textureWidth
-- painting.yaw