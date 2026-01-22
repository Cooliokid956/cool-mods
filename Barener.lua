local gHammerTime = {}
for i = 0, MAX_PLAYERS-1 do
    gHammerTime[i] = {
        timer = -2,
        rot = 0
    }
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    local h = gHammerTime[m.playerIndex]
    if m.playerIndex == 0 then print(h.timer) end
    if h.timer < -2 then
        h.timer = h.timer - 1
        -- h.rot = (h.rot - math.sqrt(sqrf(m.vel.x) + sqrf(m.vel.z))*64 + 0x8000) % 0x10000 - 0x8000
        m.faceAngle.x = m.faceAngle.x - math.sqrt(sqrf(m.vel.x) + sqrf(m.vel.z))*64
        m.marioObj.header.gfx.angle.x = m.faceAngle.x
    elseif h.timer == -1 then
        h.timer = 90 - math.floor(75 * (m.health - 255) / (2176 - 255))
    elseif h.timer > 0 then
        h.timer = h.timer - 1
    elseif h.timer == 0 and m.input & (INPUT_Z_PRESSED|INPUT_A_PRESSED) ~= 0 and (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_FORWARD_AIR_KB) then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end
end)
hook_event(HOOK_ALLOW_PVP_ATTACK,function ()
    print("That hurt!")
    
end) -- TO DO: apparently hammer hits are registered by the above hook, so maybe we should use it instead
     -- tomorrow time!!
     -- 
     -- err... maybe not- we'll see
hook_event(HOOK_ON_DEATH, function ()
    gHammerTime[0] = {
        timer = 0,
        rot = 0
    }
end)
--hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function(m, action)
--    local h = gHammerTime[m.playerIndex]
--    if action == m.action then
--        print("repeated action: skipping") return
--    end
--    if m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_FORWARD_AIR_KB then
--        h.timer = -2 return
--    end
--    local attacker = nearest_mario_state_to_object(m.marioObj)
--    if attacker == nil then return end
--    local item = obj_get_nearest_object_with_behavior_id(attacker.marioObj, bhvArenaCustom002)
--    if item == nil then return end
--    
--    if vec3f_dist(m.pos, {
--        x = item.oPosX + 100 * coss(0x4000 + -item.oFaceAnglePitch) * sins(item.oFaceAngleYaw),
--        y = item.oPosY + 100 * sins(0x4000 + -item.oFaceAnglePitch),
--        z = item.oPosZ + 100 * coss(0x4000 + -item.oFaceAnglePitch) * coss(item.oFaceAngleYaw),
--    }) > 200 then return end
--    if item.oArenaItemHeldType == 0 then
--        print("item is NONE")
--    elseif item.oArenaItemHeldType == 1 then
--        print("item is METAL_CAP")
--    elseif item.oArenaItemHeldType == 2 then
--        print("item is HAMMER")
--    elseif item.oArenaItemHeldType == 3 then
--        print("item is FIRE_FLOWER")
--    elseif item.oArenaItemHeldType == 4 then
--        print("item is CANNON_BOX")
--    elseif item.oArenaItemHeldType == 5 then
--        print("item is BOBOMB")
--    end
--    --print(item.oArenaItemHeldType)
--    local hammered = action == ACT_BACKWARD_AIR_KB and item.oArenaItemHeldType == 2
--    local kicked = (action == ACT_FORWARD_AIR_KB or action == ACT_BACKWARD_AIR_KB) and attacker.action == ACT_JUMP_KICK
--    local attacked = attacker.action & ACT_FLAG_ATTACKING ~= 0
--    if hammered then
--        print("i was hammered")
--    end
--    if kicked then
--        print("i was jump kicked")
--    end
--    if attacked then
--        print("i was attacked...")
--    end
--    if (hammered or kicked) and attacked then--passes_pvp_interaction_checks(attacker, m) then
--        if m.health - ((attacker.action == ACT_JUMP_KICK or attacker.action == ACT_DIVE) and 640 or 960) < 256 then
--           h.timer = -3
--           h.rot = 0
--           set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)
--           play_character_sound(m, CHAR_SOUND_WAAAOOOW) return
--        end
--        h.timer = -1 return
--    end
--end)

hook_chat_command("htime", "STOP", function (msg)
    gHammerTime[0].timer = tonumber(msg)
    return true
end)

hook_on_sync_table_change(gGlobalSyncTable, "map", 0, function (_, _, warp)
    warp_to_level(warp, 1, 0)
end)