-- Returns an identity matrix
local function mat4()
    return {
		a=0,b=0,c=0,d=0,
		e=0,f=0,g=0,h=0,
		i=0,j=0,k=0,l=0,
		m=0,n=0,o=0,p=0,
	}
end

local g = mat4()

---@param o Object
hook_event(HOOK_ON_OBJECT_RENDER, function (o)
    if o.hookRender ~= 29 then return end
    local tm = o.header.gfx.prevThrowMatrix
    djui_chat_message_create(tostring(o.header.gfx.prevThrowMatrix))
    
    mtxf_copy(tm, g)
end)

hook_chat_command("mark", "to alter", function ()
    gMarioStates[0].marioObj.hookRender = 29
    return true
end)