-- name: Multiplier
-- description: For the keyboard players!! Tiptoe past those piranha plants by setting your control-stick\nmagnitude multiplier using \n\n/mag [0-1]\n\nor adjusting it using D-Pad Up/Down.\nUse /unsafe mode to raise the limit from\n1 to 64! Beware of crashes when approaching 64, though.

local mag = 1
local magoffset = 0

function setmag(msg)
    if tonumber(msg) ~= fail and tonumber(msg) >= 0 and ((tonumber(msg) <= 64 and gGlobalSyncTable.unsafe) or (tonumber(msg) <= 1 and not gGlobalSyncTable.unsafe)) then
        mag = tonumber(msg)
        djui_chat_message_create("Multiplier set to " .. tostring(mag) .. ".")
    elseif gGlobalSyncTable.unsafe then
        djui_chat_message_create("Try a number between 0 and 64.")
    else
        djui_chat_message_create("Try a number between 0 and 1.")
    end
    return true
end

function beforemario(m)
    if m.playerIndex ~= 0 then return end
    if m.controller.buttonDown & U_JPAD ~= 0 then
        magoffset = magoffset + 1
    end
    if m.controller.buttonDown & D_JPAD ~= 0 and not (magoffset < -64 and not gGlobalSyncTable.unsafe) then
        magoffset = magoffset - 1
    end
    if m.controller.stickMag == 0 or (magoffset > 0 and not gGlobalSyncTable.unsafe) then
        magoffset = 0
    end
    m.controller.stickMag = (m.controller.stickMag + magoffset) * mag
end

function toggleunsafe()
    gGlobalSyncTable.unsafe = not gGlobalSyncTable.unsafe
    return true
end

hook_on_sync_table_change(gGlobalSyncTable, "unsafe",i,
    function(i,o,n)
        print(n)
        if n then
            djui_chat_message_create("Unsafe mode has been toggled on.")
        else
            djui_chat_message_create("Unsafe mode has been toggled off.")
        end
        if mag > 1 and not n then
            mag = 1
            return
        end
    end
)
if network_is_server() then
    hook_chat_command('unsafe', "to enter/exit unsafe mode (SERVER-WIDE)", toggleunsafe)
    gGlobalSyncTable.unsafe = false
end
hook_chat_command('mag', "[0-1] to set magnitude, [0-64] if in unsafe mode", setmag)
hook_event(HOOK_BEFORE_MARIO_UPDATE, beforemario)