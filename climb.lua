ACT_CLIMBS = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_AIR|ACT_FLAG_MOVING)

---@param m MarioState
function act_climbs(m)
	if not m.wall then
		return set_mario_action(m, m.prevAction, 0)
	end

	local rotSpeed = 1024
	local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x)
	if m.actionState == 0 then
		m.forwardVel = 10
	else
		m.forwardVel = (rotSpeed * math.pi / 0x8000) * 50;
	end
	m.faceAngle.y = m.faceAngle.y + 16386
	set_vel_from_pitch_and_yaw(m)
	m.faceAngle.y = m.faceAngle.y - 16386

	local currwall = m.wall
	perform_air_step(m, 0)
	if currwall ~= m.wall then
		m.angleVel = 
	end
end
hook_mario_action(ACT_CLIMBS, act_climbs)