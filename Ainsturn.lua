hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function (m, action)
    if action == ACT_TURNING_AROUND then
        m.faceAngle.y = m.intendedYaw
        return ACT_FINISH_TURNING_AROUND
    end
end)