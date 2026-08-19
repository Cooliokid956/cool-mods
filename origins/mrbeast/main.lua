-- name: MR BEAST
-- description: Every time you press any button, BEAST

mrBeast = audio_sample_load("mrbeast.mp3");

function playBeast(m)
    if m.controller.buttonPressed & (A_BUTTON | B_BUTTON | Z_TRIG | X_BUTTON | Y_BUTTON | L_JPAD | R_JPAD | U_JPAD | D_JPAD | U_CBUTTONS | D_CBUTTONS | L_CBUTTONS | R_CBUTTONS | START_BUTTON | L_TRIG | R_TRIG) ~= 0 then
        audio_sample_play(mrBeast,gMarioStates[0].pos,1)
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, playBeast)