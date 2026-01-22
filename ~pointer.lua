function djui_hud_render_line(x1,y1,x2,y2,thickness)
    local angle = atan2s(x2-x1,y1-y2)
    local length = math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
    djui_hud_set_rotation(angle, 0, .5)
    djui_hud_render_rect(x1,y1-thickness/2,length,thickness)
    djui_hud_set_rotation(0,0,0)
end

function lerp(a, b, t) return a * (1 - t) + b * t end
function vec3f_lerp(a, b, t)
    return {
        x = lerp(a.x, b.x, t),
        y = lerp(a.y, b.y, t),
        z = lerp(a.z, b.z, t)
    }
end

target = {x=0,y=0,z=0}
zoffset = 290

function render_rect(pos,size)
    djui_hud_render_rect(pos.x-size/2,pos.y-size/2,size,size)
end
local l = gLakituState
hook_event(HOOK_UPDATE, function ()
    if l.curFocus and target then
        vec3f_copy(l.curFocus, vec3f_lerp(l.curFocus, target, .2))
    end
end)
hook_event(HOOK_ON_HUD_RENDER, function ()
    ---@type LakituState
    local l = gLakituState
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local rh = djui_hud_get_screen_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    local w = djui_hud_get_screen_width()
    local h = djui_hud_get_screen_height()
    local x = djui_hud_get_mouse_x()*240/rh
    local y = djui_hud_get_mouse_y()*240/rh
    local camrot = {
        x = -calculate_pitch(l.pos, l.focus)-(h / 2 - y)*60,
        y = calculate_yaw(l.pos, l.focus)+(w / 2 - x)*110,
        z = l.roll
    }
    local cursor = {
        x = 0,
        y = 0,
        z = zoffset
    }
    djui_hud_set_resolution(RESOLUTION_N64)
    vec3f_rotate_zxy(cursor, camrot)
    vec3f_add(cursor, l.pos)
    local normal = {x=0,y=0,z=0}
    vec3f_dif(normal, cursor, l.pos)
    vec3f_normalize(normal)
    vec3f_mul(normal, vec3f_dist(l.curPos, l.curFocus))
    local ray = collision_find_surface_on_ray(l.pos.x, l.pos.y, l.pos.z, normal.x, normal.y, normal.z)
    vec3f_copy(cursor, ray.hitPos)
    vec3f_copy(target, ray.hitPos)
    vec3f_sum(target, l.pos, normal)

    --render_rect(screen[5], 20)
    --djui_hud_render_line(w/2, h/2, screen[5].x, screen[5].y, 10)
end)