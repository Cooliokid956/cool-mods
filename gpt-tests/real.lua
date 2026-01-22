-- This mod lets you place stationary bombs in front of Mario
-- The bombs will explode after a few seconds or when touched by another player
-- You can place up to 10 bombs at a time
-- Press L to place a bomb

local bombModel = 0x13000F00 -- The model ID of the bomb
local bombBehavior = 0x13000F10 -- The behavior ID of the bomb
local bombTimer = 150 -- The number of frames before the bomb explodes
local bombRadius = 100 -- The radius of the bomb explosion
local bombDamage = 3 -- The amount of damage the bomb does to other players
local maxBombs = 10 -- The maximum number of bombs you can place at a time

local bombs = {} -- A table to store the bombs

function placeBomb()
    local mario = gMarioStates[0] -- Get the local Mario state
    local pos = mario.pos -- Get Mario's position
    local faceAngle = mario.faceAngle[1] -- Get Mario's facing angle
    local spawnPos = {} -- A table to store the spawn position of the bomb
    spawnPos[1] = pos[1] + math.sin(faceAngle / 0x8000 * math.pi) * 100 -- Calculate the x coordinate of the spawn position
    spawnPos[2] = pos[2] + 100 -- Calculate the y coordinate of the spawn position
    spawnPos[3] = pos[3] + math.cos(faceAngle / 0x8000 * math.pi) * 100 -- Calculate the z coordinate of the spawn position
    local bomb = spawn_object_abs_with_rot(mario, 0, bombModel, bombBehavior, spawnPos[1], spawnPos[2], spawnPos[3], 0, faceAngle, 0) -- Spawn the bomb object with the same rotation as Mario
    bomb.rawData.timer = bombTimer -- Set the timer of the bomb to the defined value
    table.insert(bombs, bomb) -- Add the bomb to the table
end

function updateBombs()
    for i, bomb in ipairs(bombs) do -- Loop through all the bombs in the table
        if is_network_player_connected(0) then -- Check if we are connected to a server
            network_send_object(bomb) -- Send the bomb object to other players
        end
        if bomb.rawData.timer > 0 then -- Check if the bomb has not exploded yet
            bomb.rawData.timer = bomb.rawData.timer - 1 -- Decrease the timer by one frame
            if bomb.rawData.timer == 0 then -- Check if the timer has reached zero
                create_sound_spawner(0x302E0000) -- Play the explosion sound
                for j = 0, gNetworkPlayerCount - 1 do -- Loop through all the network players
                    local player = gNetworkPlayers[j] -- Get the network player state
                    local mario = gMarioStates[player.localIndex] -- Get the corresponding Mario state
                    local pos = mario.pos -- Get Mario's position
                    local dist = math.sqrt((pos[1] - bomb.rawData.x)[2] + (pos[2] - bomb.rawData.y)[2] + (pos[3] - bomb.rawData.z)[2]) -- Calculate the distance between Mario and the bomb
                    if dist < bombRadius then -- Check if Mario is within the explosion radius
                        mario.hurtCounter = mario.hurtCounter + (bombDamage * (gNetworkPlayerCount - j)) -- Increase Mario's hurt counter by a factor of their player index (higher index means more damage)
                        mario.vel[1] = mario.vel[1] + (pos[1] - bomb.rawData.x) / dist * 10 -- Apply a knockback force to Mario's x velocity based on their distance from the bomb
                        mario.vel[2] = mario.vel[2] + (pos[2] - bomb.rawData.y) / dist * 10 -- Apply a knockback force to Mario's y velocity based on their distance from the bomb
                        mario.vel[3] = mario.vel[3] + (pos[3] - bomb.rawData.z) / dist * 10 -- Apply a knockback force to Mario's z velocity based on their distance from the bomb
                    end
                end
                obj_mark_for_deletion(bomb) -- Mark the bomb for deletion
                table.remove(bombs, i) -- Remove the bomb from the table
            end
        end
    end
end

function onPlayerInput(input)
    if input.buttonPressed.L then -- Check if the L button was pressed
        if #bombs < maxBombs then -- Check if we have not reached the maximum number of bombs
            placeBomb() -- Call the function to place a bomb
        end
    end
end

function onTick()
    updateBombs() -- Call the function to update the bombs
end

registerHook("onPlayerInput", onPlayerInput) -- Register a hook for when the player inputs something
registerHook("onTick", onTick) -- Register a hook for when the game updates