-- name: GPT-4 mod: bombdrop
-- description: a mod that lets Mario drop a still-standing bomb a few units in front of him

-- Define some constants
local BOMB_DROP_DISTANCE = 150 -- how far the bomb is dropped from Mario
local BOMB_DROP_HEIGHT = 50 -- how high the bomb is dropped from Mario
local BOMB_DROP_SPEED = 0 -- how fast the bomb is moving when dropped
local BOMB_DROP_ANGLE = 0 -- how much the bomb is rotated when dropped
local BOMB_DROP_MODEL = E_MODEL_BLACK_BOBOMB -- what model to use for the bomb
local BOMB_DROP_BEHAVIOR = id_bhvBobomb -- what behavior to use for the bomb


-- Define a function to drop a bomb
function drop_bomb()
    -- Get the MarioStruct of the local player
    local m = gMarioStates[0]

    -- Get Mario's position and angle
    local x = m.pos.x
    local y = m.pos.y
    local z = m.pos.z
    local angle = m.faceAngle.y

    -- Calculate the position of the bomb
    local bx = x + BOMB_DROP_DISTANCE * math.sin(angle * math.pi / 32768)
    local by = y + BOMB_DROP_HEIGHT
    local bz = z + BOMB_DROP_DISTANCE * math.cos(angle * math.pi / 32768)

-- Create the bomb object
local bomb = spawn_sync_object(BOMB_DROP_BEHAVIOR, BOMB_DROP_MODEL, bx, by, bz,
    function(bomb)
        -- Set the bomb's velocity and flags
        bomb.oForwardVel = BOMB_DROP_SPEED
        bomb.oMoveAngleYaw = angle
        bomb.oBobombBlinkTimer = 0 -- make the bomb not blink
        bomb.oBobombFuseLit = 1 -- make the bomb lit
        bomb.oInteractType = 0x00000000 -- make the bomb not interactable
    end)

    -- Play a sound effect
    play_sound(SOUND_OBJ_POUNDING1, m.marioObj.header.gfx.cameraToObject)
end

function check(m)
    if m.controller.buttonPressed & L_JPAD ~= 0 then
        drop_bomb()
    end
end
-- Hook a chat command to activate the mod
hook_event(HOOK_BEFORE_MARIO_UPDATE, check)
function cancel_grab(m)
    -- Check if Mario is holding a bomb
    if m.heldObj ~= nil and m.heldObj.behavior == BOMB_DROP_BEHAVIOR then
        -- Cancel the action and drop the bomb
        m.action = ACT_IDLE
        mario_drop_held_object(m)
    end
end

-- Hook the event before Mario's action update
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, cancel_grab)
hook_chat_command("bombdrop", "drop a still-standing bomb in front of you", drop_bomb)