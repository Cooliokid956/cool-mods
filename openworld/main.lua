-- name: 12x Bounds World
-- description: collect my stars

gLevelValues.entryLevel = LEVEL_BOB

local c1 = { geo = smlua_model_util_get_id("c1_geo"), col = smlua_collision_util_get("c1_collision") }
local c2 = { geo = smlua_model_util_get_id("c2_geo"), col = smlua_collision_util_get("c2_collision") }
local c3 = { geo = smlua_model_util_get_id("c3_geo"), col = smlua_collision_util_get("c3_collision") }
local c4 = { geo = smlua_model_util_get_id("c4_geo"), col = smlua_collision_util_get("c4_collision") }
local c5 = { geo = smlua_model_util_get_id("c5_geo"), col = smlua_collision_util_get("c5_collision") }
local c6 = { geo = smlua_model_util_get_id("c6_geo"), col = smlua_collision_util_get("c6_collision") }
local c7 = { geo = smlua_model_util_get_id("c7_geo"), col = smlua_collision_util_get("c7_collision") }
local c8 = { geo = smlua_model_util_get_id("c8_geo"), col = smlua_collision_util_get("c8_collision") }
local c9 = { geo = smlua_model_util_get_id("c9_geo"), col = smlua_collision_util_get("c9_collision") }

local xOffset = -98303
local zOffset = -98303

local cellSize = 65535

local colCells = {
    c1,c2,c3,
    c4,c5,c6,
    c7,c8,c9
}
local m = gMarioStates[0]

function set_visual_model(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_model_extended(o, colCells[o.oBehParams].geo)
    if o.oBehParams ~= 5 then obj_mark_for_deletion(o) end
    o.header.gfx.skipInViewCheck = true
end
id_bhvVisualObject = hook_behavior(nil, OBJ_LIST_LEVEL, true, set_visual_model, nil, "bhvVisualObject")

function update_collision(o)
    local cellX = (m.pos.x - xOffset) // cellSize + 1
    local cellZ = (m.pos.z - zOffset) // cellSize + 1
    djui_chat_message_create(""..cellX..", "..cellZ)

    o.collisionData = colCells[cellX+(cellZ-1)*3].col
    load_object_collision_model()
end
id_bhvCollisionObject = hook_behavior(nil, OBJ_LIST_SURFACE, true, nil, update_collision, "bhvCollisionObject")