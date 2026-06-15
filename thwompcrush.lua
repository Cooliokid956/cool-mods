-- name: Thwomp Crusher
-- description: Crush them under the weight of your countless servings of spaghetti!\n\n(Hold Z)

local id_bhvBlueCoinBlast = hook_behavior(nil, OBJ_LIST_LEVEL, true,
function (o)
    o.oInteractType = INTERACT_COIN
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(o)
    o.oIntangibleTimer = 0

    o.oWallHitboxRadius = 30
    o.oGravity = -4
    o.oBounciness = -.7
    o.oDragStrength = 10
    o.oFriction = 10
    o.oBuoyancy = 2
    o.oDamageOrCoinValue = 5

    local bhv = o.behavior
    bhv_coin_init()
    cur_obj_set_behavior(bhv)

    obj_translate_xyz_random(o, 300)
    o.oPosY = o.oPosY + 150
    o.oMoveAngleYaw = random_u16()
    o.oMoveAnglePitch = -random_u16()/4
    obj_compute_vel_from_move_pitch(math.random(20, 400))
end,
function (o)
    bhv_coin_loop()
    o.oAnimState = o.oAnimState + 1
end, "bhvBlueCoinBlast")

local function boom(o)
    create_sound_spawner(SOUND_GENERAL_BREAK_BOX)
    o.oNumLootCoins = 100
    spawn_mist_particles_variable(30, 0, 80)
    spawn_triangle_break_particles(30, 138, 3, 4)
    for i = 1, 100 do
        spawn_non_sync_object(id_bhvBlueCoinBlast, E_MODEL_BLUE_COIN, o.oPosX, o.oPosY, o.oPosZ, nil)
    end
end

-- hook_event(HOOK_MARIO_UPDATE, function (m)
--     if m.controller.buttonPressed & Y_BUTTON ~= 0 then
--         boom(m.marioObj)
--     end
-- end)
warp_to_level(LEVEL_WF, 1, 1)

hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function (m)
    if not m.floor then return end
    if m.input & INPUT_Z_DOWN == 0 then return end
    if m.action == ACT_GROUND_POUND
    or m.action == ACT_GROUND_POUND_LAND then
        local thwomp = m.floor.object
        if thwomp and (
            obj_has_behavior_id(thwomp, id_bhvThwomp) ~= 0
         or obj_has_behavior_id(thwomp, id_bhvThwomp2) ~= 0
        ) then
            if thwomp.oAction ~= 3 then
                if thwomp.oAction == 4 then
                    play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
                    set_mario_particle_flags(m, (PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR), 0)
                    thwomp.oHealth = math.min(thwomp.oHealth - 1, 3)
                end
                thwomp.oAction = 2
            end
            if m.action == ACT_GROUND_POUND_LAND then
                if thwomp.oHealth == 0 then
                    boom(thwomp)
                    obj_mark_for_deletion(thwomp)
                else return 1 end
            end
        end
    end
end)