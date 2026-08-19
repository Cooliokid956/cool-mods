gGlobalSyncTable.CapThrow = true

local WING_CAP = (1 << 3)
local METAL_CAP = (1 << 4)
local VANISH_CAP = (1 << 5)

local turn = {
  [ACT_TURNING_AROUND] = true,
  [ACT_FINISH_TURNING_AROUND] = true,
  [ACT_SIDE_FLIP] = true,
  [ACT_SIDE_FLIP_LAND] = true,
  [ACT_SIDE_FLIP_LAND_STOP] = true,
}
---@param o Object
function capinit(o)
  print("Cap Manager v1.14")
  print("it's a:")
  if o.oBehParams & (WING_CAP|METAL_CAP|VANISH_CAP) ~= 0 then
    if o.oBehParams & WING_CAP ~= 0 then
      print("wing cap")
    end
    if o.oBehParams & METAL_CAP ~= 0 then
      print("metal cap")
    end
    if o.oBehParams & VANISH_CAP ~= 0 then
      print("vanish cap")
    end
  else
    print("regular cap")
  end
  network_init_object(o,true,nil)
end
---@param o Object
function caploop(o)
  local obj = o.parentObj
  local m = gMarioStates[network_local_index_from_global(obj.globalPlayerIndex)]
  if obj == nil then
    print("my cap's gone! byebye")
    obj_mark_for_deletion(o)
    return
  end
  if obj.activeFlags == ACTIVE_FLAG_DEACTIVATED then
    print("my cap was collected, let's see...")
    local m = nearest_mario_state_to_object(obj)
    if obj.oTimer < 0 then
      if o.oBehParams & WING_CAP ~= 0 then
        m.flags = m.flags | MARIO_WING_CAP
        print("a wing cap!")
      end
      if o.oBehParams & METAL_CAP ~= 0 then
        m.flags = m.flags | MARIO_METAL_CAP
        print("a metal cap!")
      end
      if o.oBehParams & VANISH_CAP ~= 0 then
        m.flags = m.flags | MARIO_VANISH_CAP
        print("a vanish cap!")
      end
      m.flags = m.flags | MARIO_NORMAL_CAP
      m.capTimer = -obj.oTimer
    else
      print("no power-ups, i guess")
    end
    print("alr imma go")
    obj_mark_for_deletion(o)
    return
--  elseif obj_has_behavior_id(m.interactObj, id_bhvWingCap) + obj_has_behavior_id(m.interactObj, id_bhvMetalCap) + obj_has_behavior_id(m.interactObj, id_bhvVanishCap) ~= 0 then
  elseif m.flags & (MARIO_WING_CAP|MARIO_METAL_CAP|MARIO_VANISH_CAP) ~= 0 and obj_has_behavior_id(m.interactObj.parentObj, id_bhvCapManager) == 0 then
    print("???")
    print("it seems you've left us behind, so we'll just")
    cur_obj_set_pos_relative_to_parent(0,0,0)
    spawn_mist_particles()
    --m.interactObj = nil
    obj_mark_for_deletion(obj)
    obj_mark_for_deletion(o)
    return
  end
  if o.oBehParams & VANISH_CAP ~= 0 then
    obj.oOpacity = 150
  else
    obj.oOpacity = 255
  end
  if obj.oTimer >= 0 then
    o.oBehParams = o.oBehParams & ~(WING_CAP|METAL_CAP|VANISH_CAP)
    obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
    if o.oBehParams == 0 then
      obj_set_model_extended(obj,E_MODEL_MARIOS_CAP)
    else
      obj_set_model_extended(obj,E_MODEL_LUIGIS_CAP + (o.oBehParams-1)*5 - ((o.oBehParams > 2) and 1 or 0))
      --print(E_MODEL_LUIGIS_CAP + (o.oBehParams-1)*5)
    end
  elseif obj.oTimer > -40 then
    obj_flicker_and_disappear(obj,-40)
  end

  if m.controller.buttonDown & X_BUTTON ~= 0 and m.action & ACT_FLAG_THROWING == 0 then
    local v = {x=obj.oPosX,y=obj.oPosY-120,z=obj.oPosZ}
    obj.oMoveAngleYaw = obj_angle_to_object(obj, m.marioObj)
    obj.oMoveAnglePitch = calculate_pitch(v, m.pos)
    obj.oForwardVel = 50 * coss(obj.oMoveAnglePitch)
    obj.oVelY = 50 * sins(obj.oMoveAnglePitch)
  end
  if obj.oForwardVel > 30 then
    -- find a way for it to hurt more than just other marios *cry&
    obj.oAngleVelPitch = -100
    obj_set_face_angle(obj,-100,obj.oFaceAngleYaw,0)
    local hurt = obj_get_collided_object(obj,0)
    if hurt ~= nil then
      if hurt ~= m.marioObj then
        print(get_behavior_name_from_id(get_id_from_behavior(hurt.behavior)))
        hurt.oInteractStatus = ATTACK_FROM_ABOVE | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
      end
    end
    spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
  end
end
--id_bhvCapManager = hook_behavior(nil, OBJ_LIST_LEVEL,true, function(o) network_init_object(o,true,nil) end, caploop)
id_bhvCapManager = hook_behavior(nil, OBJ_LIST_LEVEL,true, capinit, caploop)
---@param m MarioState
function capthrow(m)
  if m.playerIndex ~= 0 or not gGlobalSyncTable.CapThrow then return end
  if m.health - 0x40*m.hurtCounter < 0x100 and m.flags & MARIO_CAP_ON_HEAD ~= 0 then
    local c = m.character
    local capmodel = E_MODEL_MARIOS_CAP
    if c.type ~= CT_MARIO then
      capmodel = E_MODEL_LUIGIS_CAP + (c.type-1)*5
    end
    if c.type > 2 then
      capmodel = capmodel - 1
    end
    m.flags = m.flags & ~MARIO_CAP_ON_HEAD

    spawn_sync_object(id_bhvNormalCap, capmodel, m.pos.x, m.pos.y+120, m.pos.z, function (o)
      o.oForwardVel = m.forwardVel*.5
      o.oVelY = 10 + m.vel.y*.9
      o.globalPlayerIndex = gNetworkPlayers[m.playerIndex].globalIndex
      o.oBehParams = m.playerIndex + 1
    end)
    return
  end

  if m.controller.buttonPressed & X_BUTTON ~= 0 and m.flags & (MARIO_CAP_ON_HEAD|MARIO_CAP_IN_HAND) ~= 0 and not (disallow[m.action] or m.action & ACT_GROUP_MASK == ACT_GROUP_CUTSCENE) then
    if m.action & ACT_FLAG_AIR ~= 0 then
      set_mario_action(m,ACT_AIR_THROW,0)
    elseif m.action & ACT_FLAG_SWIMMING ~= 0 then
      set_mario_action(m,ACT_WATER_THROW,0)
    else
      set_mario_action(m,ACT_THROWING,0)
    end

    local c = m.character
    local capmodel = E_MODEL_MARIOS_CAP
    local capflags = c.type
    if c.type ~= CT_MARIO then
      capmodel = E_MODEL_LUIGIS_CAP + (c.type-1)*5
    end
    m.flags = m.flags & ~(MARIO_CAP_ON_HEAD|MARIO_CAP_IN_HAND)
    if m.flags & MARIO_WING_CAP ~= 0 then
      if c.type == CT_MARIO then
        capmodel = E_MODEL_MARIOS_WING_CAP
      else
        capmodel = capmodel + 2
      end
      capflags = capflags | WING_CAP
      m.flags = m.flags & ~MARIO_WING_CAP
    end
    if m.flags & MARIO_VANISH_CAP ~= 0 then
      capflags = capflags | VANISH_CAP
      m.flags = m.flags & ~MARIO_VANISH_CAP
    end
    if m.flags & MARIO_METAL_CAP ~= 0 then
      if c.type == CT_MARIO then
        if capmodel == E_MODEL_MARIOS_WING_CAP then
          capmodel = E_MODEL_MARIOS_WINGED_METAL_CAP
        else
          capmodel = E_MODEL_MARIOS_METAL_CAP
        end
      elseif capmodel ~= E_MODEL_TOADS_WING_CAP then
        capmodel = capmodel + 1
      end
      capflags = capflags | METAL_CAP
      m.flags = m.flags & ~MARIO_METAL_CAP
    end
    if c.type > 2 then
      capmodel = capmodel - 1
    end
    m.flags = m.flags & ~MARIO_NORMAL_CAP
    local cap = spawn_sync_object(id_bhvNormalCap, capmodel, m.pos.x, m.pos.y+120, m.pos.z, function (o)
      o.oForwardVel = 20 + m.forwardVel
      if turn[m.prevAction] then
        o.oMoveAngleYaw = o.oMoveAngleYaw - 0x8000
      end
      o.oVelY = 10 + m.vel.y
      o.globalPlayerIndex = gNetworkPlayers[m.playerIndex].globalIndex
      o.oBehParams = m.playerIndex + 1
      o.oTimer = -m.capTimer
      m.interactObj = o
      --o.collidedObjInteractTypes = o.collidedObjInteractTypes | INTERACT_BOUNCE_TOP | INTERACT_DAMAGE
      print(o.oTimer)
    end)
    spawn_sync_object(id_bhvCapManager, E_MODEL_NONE, cap.oPosX, cap.oPosY, cap.oPosZ, function (o)
      o.parentObj = cap
      o.oBehParams = capflags
      cap.parentObj = o
    end)
  end
end

function on_CapThrow_command(msg)
  gGlobalSyncTable.CapThrow = not gGlobalSyncTable.CapThrow
  if gGlobalSyncTable.CapThrow then
    djui_chat_message_create("CapThrow On")
  else
    djui_chat_message_create("CapThrow Off")
  end
  return true
end

hook_event(HOOK_MARIO_UPDATE, capthrow)
hook_event(HOOK_ALLOW_INTERACT, function (m,o,type)
  if (m.action & ACT_FLAG_THROWING ~= 0 or m.action == ACT_WATER_THROW) and obj_has_behavior_id(o.parentObj, id_bhvCapManager) and o.globalPlayerIndex == gNetworkPlayers[m.playerIndex].globalIndex then
    m.interactObj = nil
    return false
  end
end)

if network_is_server() then
  hook_chat_command("CapThrow", "to turn CapThrow on or off", on_CapThrow_command)
end
hook_behavior()