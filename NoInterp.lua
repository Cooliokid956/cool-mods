hook_event(HOOK_MARIO_UPDATE, function (m)
    -- m.marioObj.header.gfx.animInfo.prevAnimFrameTimestamp = 0
    if get_global_timer() // 30 % 2 == 0 then obj_anim_skip_interpolation(m.marioObj) end
    obj_skip_interpolation(nil)
    obj_anim_skip_interpolation(nil)
end)