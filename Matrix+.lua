local function vec3f() return {x=0,y=0,z=0} end

local function mat4()
    -- old
    -- return {
    --     a=0,b=0,c=0,d=0,
    --     e=0,f=0,g=0,h=0,
    --     i=0,j=0,k=0,l=0,
    --     m=0,n=0,o=0,p=0,
    -- }
    return {
        m00=0,m01=0,m02=0,m03=0,
        m10=0,m11=0,m12=0,m13=0,
        m20=0,m21=0,m22=0,m23=0,
        m30=0,m31=0,m32=0,m33=0,
    }
end

local function mtxf_copy_lua(dest, src)
    for x = 0, 3 do
        for y = 0, 3 do
            local l = "m"..x..y
            dest[l] = src[l]
        end
    end
end
local tmp = mat4()
local function mtxf_rotate_axis(dest, angle, x, y, z)
    local mtx = mat4()
    local c = math.cos(angle)
    local s = math.sin(angle)
    local t = 1 - c

    -- normalize
    local mag = math.sqrt(x*x + y*y + z*z)
    x = x / mag
    y = y / mag
    z = z / mag

    -- Construct the rotation matrix
    mtx.m00 = t * x * x + c
    mtx.m01 = t * x * y - s * z
    mtx.m02 = t * x * z + s * y
    mtx.m03 = 0

    mtx.m10 = t * x * y + s * z
    mtx.m11 = t * y * y + c
    mtx.m12 = t * y * z - s * x
    mtx.m13 = 0

    mtx.m20 = t * x * z - s * y
    mtx.m21 = t * y * z + s * x
    mtx.m22 = t * z * z + c
    mtx.m23 = 0

    mtx.m30 = 0
    mtx.m31 = 0
    mtx.m32 = 0
    mtx.m33 = 1
    -- mtxf_copy_lua(tmp, mtx)

    mtxf_mul(dest, mtx, dest)
end

if kermeet == "real" then

local mat = mat4()
local marioMat = mat4()
local mtxCam = mat4()
local x = 0
hook_event(HOOK_ON_OBJECT_RENDER, function (o)
    if o.hookRender ~= 29 then return end
    x = x + 0.1
    -- if x % 5 ~= 0 then return end

    local slave = o
    local transforming = o

    local mtxA = mat4()
    -- mtxf_lookat(mtxCam, gLakituState.pos, gLakituState.focus, gLakituState.roll)
    mtxf_copy(mtxCam, gCamera.mtx)
    mtxf_inverse(mtxCam, mtxCam)

    -- slave.oFlags = slave.oFlags & ~OBJ_FLAG_0020
    -- slave.oFlags = slave.oFlags | OBJ_FLAG_SET_THROW_MATRIX_FROM_TRANSFORM

    obj_build_transform_from_pos_and_angle(slave, 0x06, 0x12)
    obj_apply_scale_to_transform(slave)
    mtxf_copy(mtxA, slave.transform)
    mtxf_copy(marioMat, mtxA)

    local tm = slave.header.gfx.throwMatrix
    if tm then
        tm.a = 2
    end

    for x = 0, 3 do
        for y = 0, 3 do
            local l = "m"..x..y
            mtxA[l] = mtxA[l] + mat[l]
            -- mtxA[l] = mtxA[l] + mtxCam[l]/3
            -- mtxA[l] = mtxCam[l]
        end
    end

    -- mtxf_inverse(mtxA,mtxA)

    mtxf_mul(slave.transform, mtxA, mtxCam)

    local l = gLakituState
    local yaw = calculate_yaw(l.pos, l.focus)
    local pitch = -calculate_pitch(l.pos, l.focus)

    local pos = { x = 0, y = -50, z = 200 }

    mtxf_identity(slave.transform)
    local t1 = mat4()
    mtxf_translate(t1, pos)
    local t2 = mat4()
    mtxf_rotate_zxy_and_translate(t2, vec3f(), { x = pitch, y = yaw, z = l.roll })

    mtxf_mul(slave.transform, t1, t2)

    slave.transform.m = slave.transform.m + l.pos.x
    slave.transform.n = slave.transform.n + l.pos.y
    slave.transform.o = slave.transform.o + l.pos.z

    mtxf_copy(marioMat, slave.transform)

    -- mtxf_mul(mtxA, mtxA, mtxCam)
    -- mtxf_mul(mtxA, mtxA, mtxCam)
    -- mtxf_copy(slave.transform, mtxA)
    -- obj_set_throw_matrix_from_transfrm(slave)
end)

hook_chat_command("setmat", "[reset], a-p", function (msg)
    if msg == "reset" then
        mat = mat4()
        return true
    end
    local l = msg:sub(1,1)
    if mat[l] then
        mat[l] = tonumber(msg:sub(2))
        return true
    end
end)

hook_chat_command("mark", "to alter", function ()
    gMarioStates[0].marioObj.hookRender = 29
    return true
end)

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local s = 3
    local m

    local x = djui_hud_get_mouse_x()
    local y = djui_hud_get_mouse_y()
    m = mat
    djui_hud_print_text(m.m00.." "..m.m01.." "..m.m02.." "..m.m03, x, y+ 0*s, s)
    djui_hud_print_text(m.m10.." "..m.m11.." "..m.m12.." "..m.m13, x, y+18*s, s)
    djui_hud_print_text(m.m20.." "..m.m21.." "..m.m22.." "..m.m23, x, y+36*s, s)
    djui_hud_print_text(m.m30.." "..m.m31.." "..m.m32.." "..m.m33, x, y+54*s, s)

    y = y + 18*5*s
    m = marioMat
    djui_hud_print_text(m.m00.." "..m.m01.." "..m.m02.." "..m.m03, x, y+ 0*s, s)
    djui_hud_print_text(m.m10.." "..m.m11.." "..m.m12.." "..m.m13, x, y+18*s, s)
    djui_hud_print_text(m.m20.." "..m.m21.." "..m.m22.." "..m.m23, x, y+36*s, s)
    djui_hud_print_text(m.m30.." "..m.m31.." "..m.m32.." "..m.m33, x, y+54*s, s)

    y = y + 18*5*s
    m = mtxCam
    djui_hud_print_text(m.m00.." "..m.m01.." "..m.m02.." "..m.m03, x, y+ 0*s, s)
    djui_hud_print_text(m.m10.." "..m.m11.." "..m.m12.." "..m.m13, x, y+18*s, s)
    djui_hud_print_text(m.m20.." "..m.m21.." "..m.m22.." "..m.m23, x, y+36*s, s)
    djui_hud_print_text(m.m30.." "..m.m31.." "..m.m32.." "..m.m33, x, y+54*s, s)
end)

elseif false then
    
local camera

hook_event(HOOK_UPDATE, function()
    gMarioStates[0].marioObj.hookRender = 69
end)

hook_event(HOOK_ON_OBJECT_RENDER, function(obj)
    if obj.hookRender == 69 then
        camera = cast_graph_node(obj.header.gfx.node.parent.parent.parent)
        camera.fnNode.node.hookProcess = 69
    end
end)

local f = 0

hook_event(HOOK_ON_GEO_PROCESS, function(node, mtx)
    if node.hookProcess ~= 69 then return end

    local fp = f
    f = f + 1

    local i = "m01"
    camera.matrixPtr[i]     = camera.matrixPtr[i]     + math.sin(f / 20) / 12
    camera.matrixPtrPrev[i] = camera.matrixPtrPrev[i] + math.sin(fp/ 20) / 12
    i = "m12"
    camera.matrixPtr[i]     = camera.matrixPtr[i]     + math.sin(f / 10) / 3
    camera.matrixPtrPrev[i] = camera.matrixPtrPrev[i] + math.sin(fp/ 10) / 3
    i = "m02"
    camera.matrixPtr[i]     = camera.matrixPtr[i]     + math.sin(f / 12) / 6
    camera.matrixPtrPrev[i] = camera.matrixPtrPrev[i] + math.sin(fp/ 12) / 6
end)

else

---@type GraphNodeCamera
local camera
-- local tmp = mat4()

hook_event(HOOK_UPDATE, function()
    gMarioStates[0].marioObj.hookRender = 69
end)

hook_event(HOOK_ON_OBJECT_RENDER, function(obj)
    if obj.hookRender == 69 then
        camera = cast_graph_node(obj.header.gfx.node.parent.parent.parent)
        camera.fnNode.node.hookProcess = 69
    end
end)

local scale = {
    x = 1,
    y = 0.2,
    z = 1
}

hook_event(HOOK_ON_GEO_PROCESS, function(node, i)
    if node.hookProcess ~= 69 then return end
    local f1 = get_global_timer()

    if f1 > 0 then
        local cm = camera.matrixPtr
        local cmp = camera.matrixPtrPrev
        local trans = vec3f()
        local transPrev = vec3f()
        vec3f_set(trans,     cm. m30, cm .m31, cm .m32)
        vec3f_set(transPrev, cmp.m30, cmp.m31, cmp.m32)
        local i = 20
        local m = mat4() mtxf_copy_lua(m, camera.matrixPtr)
        local mPrev = mat4() mtxf_copy_lua(mPrev, camera.matrixPtrPrev)
        mtxf_copy_lua(tmp, m)
        local f2 = 5 / (f1 * f1 + 5) - f1 * 0.04
        f2 = f2 * f2
        local m1 = mat4()
        mtxf_identity(m1)
        mtxf_rotate_axis(m1, f1, 0, 1, 1)
        mtxf_scale_vec3f(m1, m1, {x=1, y=1/f2, z=1})
        mtxf_rotate_axis(m1, -f1, 0, 1, 1)
        -- mtxf_copy_lua(tmp, m1)

        mtxf_mul(camera.matrixPtr, m1, camera.matrixPtr)
        mtxf_mul(camera.matrixPtrPrev, m1, camera.matrixPtrPrev)
        
        -- mtxf_translate(camera.matrixPtr, trans)
        -- mtxf_translate(camera.matrixPtrPrev, transPrev)
        -- mtxf_copy_lua(camera.matrixPtr, m)
        -- mtxf_copy_lua(camera.matrixPtrPrev, m1)
        
        -- mtxf_mul(m, m1, m)
        -- mtxf_mul(mPrev, m1, mPrev)
        
        -- mtxf_copy_lua(camera.matrixPtr, m)
        -- mtxf_copy_lua(camera.matrixPtrPrev, mPrev)
        -- mtxf_copy_lua(m1, camera.matrixPtr)
        -- mtxf_scale_vec3f(m1, m1, scale)
        -- mtxf_copy_lua(camera.matrixPtr, m1)
        
        -- local m2 = mat4()
        -- mtxf_copy_lua(m2, camera.matrixPtr)
        -- mtxf_scale_vec3f(m2, m2, scale)
        -- mtxf_copy_lua(camera.matrixPtr, m2)
    end

    -- camera.matrixPtr.a = camera.matrixPtr.a * 2
    -- camera.matrixPtrPrev.a = camera.matrixPtrPrev.a * 2

    -- camera.matrixPtr.m00 = camera.matrixPtr.m00 * 2
    -- camera.matrixPtrPrev.m00 = camera.matrixPtrPrev.m00 * 2
end)

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local s = 3
    local m

    local x = djui_hud_get_mouse_x()
    local y = djui_hud_get_mouse_y()
    m = tmp
    djui_hud_print_text(m.m00.." "..m.m01.." "..m.m02.." "..m.m03, x, y+ 0*s, s)
    djui_hud_print_text(m.m10.." "..m.m11.." "..m.m12.." "..m.m13, x, y+18*s, s)
    djui_hud_print_text(m.m20.." "..m.m21.." "..m.m22.." "..m.m23, x, y+36*s, s)
    djui_hud_print_text(m.m30.." "..m.m31.." "..m.m32.." "..m.m33, x, y+54*s, s)

    -- y = y + 18*5*s
    -- m = marioMat
    -- djui_hud_print_text(m.m00.." "..m.m01.." "..m.m02.." "..m.m03, x, y+ 0*s, s)
    -- djui_hud_print_text(m.m10.." "..m.m11.." "..m.m12.." "..m.m13, x, y+18*s, s)
    -- djui_hud_print_text(m.m20.." "..m.m21.." "..m.m22.." "..m.m23, x, y+36*s, s)
    -- djui_hud_print_text(m.m30.." "..m.m31.." "..m.m32.." "..m.m33, x, y+54*s, s)

    -- y = y + 18*5*s
    -- m = mtxCam
    -- djui_hud_print_text(m.m00.." "..m.m01.." "..m.m02.." "..m.m03, x, y+ 0*s, s)
    -- djui_hud_print_text(m.m10.." "..m.m11.." "..m.m12.." "..m.m13, x, y+18*s, s)
    -- djui_hud_print_text(m.m20.." "..m.m21.." "..m.m22.." "..m.m23, x, y+36*s, s)
    -- djui_hud_print_text(m.m30.." "..m.m31.." "..m.m32.." "..m.m33, x, y+54*s, s)
end)

end