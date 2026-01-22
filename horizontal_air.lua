function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end
function horizontal_wind_loop(o)
    if o.oBehParams == -1 then
    for i, m in ipairs(gMarioStates) do
        local o2 = cur_obj_nearest_object_with_behavior(get_behavior_from_id(id_bhvHorizontalWind))
        print("o2 found")
        local min = {x = math.min(o.oPosX,o2.oPosX), z = math.min(o.oPosZ,o2.oPosZ)}
        print("min set")
        local max = {x = math.max(o.oPosX,o2.oPosX), z = math.max(o.oPosZ,o2.oPosZ)}
        print("max set")
        if o2.oPosY < m.pos.y and m.pos.y < o.oPosY then
        if min.x < m.pos.x and m.pos.x < max.x then
        if min.z < m.pos.z and m.pos.z < max.z then
            print("PASS!")
            local pushAngle = o.faceAngleYaw
            print("pushAngle: "..pushAngle)
            if (m.action & ACT_FLAG_AIR) ~= 0 then
                print("air time")
                m.slideVelX = m.slideVelX + 1.2 * sins(pushAngle)
                m.slideVelZ = m.slideVelX + 1.2 * coss(pushAngle)

                speed = math.sqrt(m.slideVelX * m.slideVelX + m.slideVelZ * m.slideVelZ)

                if speed > 48.0 then
                    m.slideVelX = m.slideVelX * 48 / speed
                    m.slideVelZ = m.slideVelZ * 48 / speed
                    speed = 32 --! This was meant to be 48?
                elseif speed > 32 then
                    speed = 32
                end

                m.vel.x = m.slideVelX
                m.vel.z = m.slideVelZ
                m.slideYaw = atan2s(m.slideVelZ, m.slideVelX)
                m.forwardVel = speed * coss(m.faceAngle.y - m.slideYaw)
            else
                print("ground wind")
                local pushSpeed

                if (m.action & ACT_FLAG_MOVING) ~= 0 then
                    local pushDYaw = m.faceAngle.y - pushAngle

                    pushSpeed = if_then_else(m.forwardVel > 0.0,-m.forwardVel * 0.5, -8)

                    if pushDYaw > -0x4000 and pushDYaw < 0x4000 then
                        pushSpeed = -pushSpeed
                    end

                    pushSpeed = pushSpeed*coss(pushDYaw)
                else
                    pushSpeed = 3.2 + (gGlobalTimer % 4)
                end

                m.vel.x = m.vel.x + pushSpeed * sins(pushAngle)
                m.vel.z = m.vel.z + pushSpeed * coss(pushAngle)
            end
            spawn_wind_particles(0, pushAngle)
            print("particle")
            play_sound(SOUND_ENV_WIND2, m.marioObj.header.gfx.cameraToObject)
            print("sound")
        end
        end
        end
    end
    end
end

id_bhvHorizontalWind = hook_behavior(nil, OBJ_LIST_LEVEL,false,nil,horizontal_wind_loop)