-- name: main
-- description: sub

gPlayerSyncTable[0].crash = false

local pvpcrashon = 0
local ccrash = false

function pvpcrash(me, you)
	if pvpcrashon ~= 0 and me.playerIndex == 0 then
		gPlayerSyncTable[you.playerIndex].crash = true
		pvpcrashon = pvpcrashon - 1
		djui_chat_message_create("crash this user")
	end
	return
end
function crash(m)
	if m.playerIndex ~= 0 and (gPlayerSyncTable[0].crash == true or ccrash == true) then
		gPlayerSyncTable[0].crash = false
		ccrash = true
		crash(m)
	end
	return
end

function addpvpcrash(msg)
	pvpcrashon = pvpcrashon + 1
	djui_chat_message_create("ok, now find someone to crash")
	return true
end

function setcrash(msg)
	djui_chat_message_create("crashing player #" .. msg)
	gPlayerSyncTable[tonumber(msg)].crash = true
	return true
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, crash)
hook_chat_command("crash","to crash player of choice", setcrash)
hook_chat_command("pvpcrash", "hit to crash", addpvpcrash)
hook_event(HOOK_ON_PVP_ATTACK, pvpcrash)
