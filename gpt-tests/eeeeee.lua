-- name: bombdrop
-- description: a mod that lets Mario drop a still-standing bomb a few units in front of him
count = 0
bombs = {}
players = {}
-- Define some constants
local BOMB_DROP_DISTANCE = 100 -- how far the bomb is dropped from Mario
local BOMB_DROP_HEIGHT = 100 -- how high the bomb is dropped from Mario
local BOMB_DROP_SPEED = 77 -- how fast the bomb is moving when dropped
local BOMB_DROP_ANGLE = 0 -- how much the bomb is rotated when dropped
local BOMB_DROP_MODEL = E_MODEL_BLACK_BOBOMB -- what model to use for the bomb
local BOMB_DROP_BEHAVIOR = id_bhvBobomb -- what behavior to use for the bomb

-- Define a function to perform bitwise OR
function bit_or(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

-- Define a function to drop a bomb
function drop_bomb()
    players = {}
    for i, player in pairs(gNetworkPlayers) do
        if player.currLevelNum == gNetworkPlayers[0].currLevelNum then
            table.insert(players,i)
        end
    end
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
    table.insert(bombs, {spawn_sync_object(BOMB_DROP_BEHAVIOR, BOMB_DROP_MODEL, 10000, 10000, 10000,
    function(bomb)
        -- Set the bomb's velocity and flags
        bomb.oAction = 0
        bomb.oVelY = 25
        bomb.oForwardVel = BOMB_DROP_SPEED
        bomb.oMoveAngleYaw = angle
        bomb.oBobombBlinkTimer = 0 -- make the bomb not blink
        bomb.oInteractStatus = bit_or(bomb.oInteractStatus, INT_STATUS_INTERACTED) -- make the bomb not interactable
    end),0,players[math.random(#players)]})

    -- Play a sound effect
    play_sound(SOUND_OBJ_POUNDING1, m.marioObj.header.gfx.cameraToObject)
end

function update(m)
    if m.playerIndex ~= 0 then return end
    if count ~= 0 then
        count = count-1
    end
    if m.controller.buttonDown & L_JPAD ~= 0 and count == 0 then
        drop_bomb()
        count = 4
    end
end
function updatebombs(m)
    if m.playerIndex ~= 0 then return end
    for i, bomb in pairs(bombs) do
        print(bomb[3])
        if bomb[1].oAction == 0 and bomb[2] == -1 then
            bomb[1].oPosY = gMarioStates[bomb[3]].pos.y + 400
            bomb[1].oAction = 3
            bomb[1].oPosY = gMarioStates[bomb[3]].pos.y + 400
        end
        if bomb[2] <= -2 then
            bomb[1].oPosX = gMarioStates[bomb[3]].pos.x
            bomb[1].oPosZ = gMarioStates[bomb[3]].pos.z
            bomb[1].oVelY = -10
        end

        bomb[2] = bomb[2] - 1
        if bomb[2] <= -60 then
            table.remove(bombs,i)
        end
    end
end
-- Hook a chat command to activate the mod
hook_event(HOOK_BEFORE_MARIO_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, updatebombs)
hook_chat_command("bombdrop", "drop a still-standing bomb in front of you", drop_bomb)