local l = gLakituState
hook_event(HOOK_UPDATE, function ()
    l.posHSpeed, l.posVSpeed, l.focHSpeed, l.focVSpeed = 1, 1, 1, 1
end)