local skipdialogs = {
    [DIALOG_013] = 0,
    [DIALOG_014] = 0,
}
hook_event(HOOK_ON_DIALOG, function (id)
    return skipdialogs[id] == nil
end)
gBehaviorValues.ShowStarMilestones = false
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, 
---@param m MarioState
---@param action integer
function (m, action)
    if action == ACT_EXIT_LAND_SAVE_DIALOG then
        m.area.camera.cutscene = 0
        m.faceAngle.y = m.faceAngle.y + 32767
        return ACT_FREEFALL_LAND
    end
end)