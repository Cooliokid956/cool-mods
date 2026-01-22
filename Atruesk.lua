---@param m MarioState
function act_squat_kick(m)
	play_sound_if_no_flag(m, SOUND_ACTION_THROW, MARIO_ACTION_SOUND_PLAYED)

	set_mario_animation(m, m.actionArg == 0 and MARIO_ANIM_START_GROUND_POUND
											 or MARIO_ANIM_FORWARD_SPINNING)
	if (m.actionTimer == 0) then
		m.forwardVel = m.forwardVel * 1.25
		set_mario_y_vel_based_on_fspeed(m, 20, .2)
		m.vel.x = m.forwardVel*sins(m.faceAngle.y)
		m.vel.z = m.forwardVel*coss(m.faceAngle.y)
		play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
		play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
	end
	m.actionTimer = m.actionTimer+1

	m.vel.y = m.vel.y - 1
	local stepResult = perform_air_step(m, 0)

	if stepResult == AIR_STEP_LANDED then
		if should_get_stuck_in_ground(m) ~= 0 then
			queue_rumble_data_mario(m, 5, 80)
			play_character_sound(m, CHAR_SOUND_OOOF2)
			set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, false)
			set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
		else
			if check_fall_damage(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
				set_mario_action(m, ACT_BUTT_SLIDE, 0)
			end
		end
	elseif stepResult == AIR_STEP_HIT_WALL then
		mario_set_forward_vel(m, -16)

		set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, false)
		set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
	end
	return false
end
hook_mario_action(ACT_SLIDE_KICK, act_squat_kick, INT_GROUND_POUND_OR_TWIRL)

hook_event(HOOK_MARIO_UPDATE, function (m)
	if m.action == ACT_BUTT_SLIDE and m.prevAction == ACT_SLIDE_KICK and m.controller.buttonPressed & (A_BUTTON|Z_TRIG) ~= 0 then
		set_mario_action(m, ACT_SLIDE_KICK, 0)
	end
end)