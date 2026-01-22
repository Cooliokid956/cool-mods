-- name: Control Stick Modifier
-- description: For the keyboard players!! Tiptoe past those piranha plants by setting your control stick modifier using \n\n/mag [0-1]\n\nor adjusting it using D-Pad Up/Down.\n\nUse /unsafe mode to raise the limit from 1 to 64! Beware of crashes when\napproaching 64, though.

function ia(m) return m.playerIndex == 0 end
function pt(m) return gPlayerSyncTable[m.playerIndex] end

gPlayerSyncTable[0].mag = 1
gPlayerSyncTable[0].magoffset = 0

function update_stick_mag(m)
    local pst = pt(m)
    if not (pst.mag and pst.magoffset) then return end
    if ia(m) then
        if m.controller.buttonDown & (X_BUTTON|Y_BUTTON) ~= 0 then
            pst.mag = 1
        end
        if m.controller.buttonDown & U_JPAD ~= 0 then
            pst.magoffset = pst.magoffset + 1
        end
        if m.controller.buttonDown & D_JPAD ~= 0 and not (pst.magoffset < -64 and not gGlobalSyncTable.unsafe) then
            pst.magoffset = pst.magoffset - 1
        end
        if m.controller.stickMag == 0 or (pst.magoffset > 0 and not gGlobalSyncTable.unsafe) then
            pst.magoffset = 0
        end
    end

    m.controller.stickMag = (m.controller.stickMag + pst.magoffset) * pst.mag

    local stickAng = atan2s(m.controller.stickY, m.controller.stickX)
    m.controller.stickX = (m.controller.stickX + pst.magoffset * sins(stickAng)) * pst.mag
    m.controller.stickY = (m.controller.stickY + pst.magoffset * coss(stickAng)) * pst.mag
    m.controller.rawStickX = (m.controller.rawStickX + pst.magoffset * sins(stickAng)) * pst.mag
    m.controller.rawStickY = (m.controller.rawStickY + pst.magoffset * coss(stickAng)) * pst.mag
end
hook_event(HOOK_BEFORE_MARIO_UPDATE, update_stick_mag)

function set_mag(msg)
    local mag = tonumber(msg)
    if mag and mag >= 0 and (gGlobalSyncTable.unsafe and (mag <= 64) or (mag <= 1)) then
        gPlayerSyncTable[0].mag = mag
        djui_chat_message_create("Multiplier set to " .. mag .. ".")
    else
        djui_chat_message_create("Try a number between 0 and " ..
        (gGlobalSyncTable.unsafe and 64 or 1) ..".")
    end
    return true
end
hook_chat_command('mag', "[0-1] to set magnitude", set_mag)

hook_on_sync_table_change(gGlobalSyncTable, "unsafe", 1,
    function(_,_,n)
        local pst = gPlayerSyncTable[0]
        djui_chat_message_create("Unsafe mode has been toggled " ..
        (n and "on" or "off") .. ".")
        update_chat_command_description("mag", "[0-"..(gGlobalSyncTable.unsafe and 64 or 1).."] to set magnitude")
        if pst.mag > 1 and not n then
            pst.mag = 1
            return
        end
    end
)

if network_is_server() then
    hook_chat_command('unsafe', "to toggle unsafe mode (SERVER-WIDE)", function ()
        gGlobalSyncTable.unsafe = not gGlobalSyncTable.unsafe
        return true
    end)
    gGlobalSyncTable.unsafe = false
end