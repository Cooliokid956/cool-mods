local scaleMtx = gMat4Identity()
mtxf_scale_vec3f(scaleMtx, scaleMtx, {x=1,y=1,z=0.1})

function flatten(node, mtx)
    local mtxP = gMatStackPrev[mtx]; mtx = gMatStack[mtx]
    local x,y,z = mtx.m30, mtx.m31, mtx.m32
    local px,py,pz = mtxP.m30, mtxP.m31, mtxP.m32
    mtxf_mul(mtxP, mtxP, scaleMtx)
    mtxf_mul(mtx, mtx, scaleMtx)
    mtx.m30, mtx.m31, mtx.m32 = x,y,z
    mtxP.m30, mtxP.m31, mtxP.m32 = px,py,pz

    -- for i = 0, 2 do
    --     local i = "m2"..i
    --     mtxP[i] = mtxP[i] * 0.2
    --     mtx[i] = mtx[i] * 0.2
    -- end
end
hook_event(HOOK_BEFORE_GEO_PROCESS, flatten)

hook_event(HOOK_MARIO_UPDATE, function (m)
    m.marioObj.header.gfx.sharedChild.children.hookProcess = 1
end)