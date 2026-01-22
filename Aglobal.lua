-- DEBUG = 1

function debug_message(s)
    if DEBUG then djui_chat_message_create(s) end
end

--- @class Sun
--- @field public x number
--- @field public y number
--- @field public z number
--- @field public r integer
--- @field public g integer
--- @field public b integer

--- @class PointLight
--- @field public x number
--- @field public y number
--- @field public z number
--- @field public r integer
--- @field public g integer
--- @field public b integer

local function vec3f(x, y, z)
    return {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }
end

local function get_mouse_world_pos()
    local l = gLakituState
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local rh = djui_hud_get_screen_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    local w = djui_hud_get_screen_width()
    local h = djui_hud_get_screen_height()
    local x = djui_hud_get_mouse_x()*240/rh
    local y = djui_hud_get_mouse_y()*240/rh
    local zoffset = 290

    local camrot = {
        x = -calculate_pitch(l.pos, l.focus),
        y = calculate_yaw(l.pos, l.focus),
        z = l.roll
    }

    local cursor = {
        x = w / 2 - x,
        y = h / 2 - y,
        z = zoffset
    }

    djui_hud_set_resolution(RESOLUTION_N64)
    vec3f_rotate_zxy(cursor, camrot)
    -- vec3f_add(cursor, l.pos)
    -- local normal = vec3f()
    -- vec3f_dif(normal, cursor, l.pos)
    -- vec3f_mul(normal, 30)
    -- local ray = collision_find_surface_on_ray(l.pos.x, l.pos.y, l.pos.z, normal.x, normal.y, normal.z)
    vec3f_mul(cursor, 30)
    local ray = collision_find_surface_on_ray(l.pos.x, l.pos.y, l.pos.z, cursor.x, cursor.y, cursor.z)
    vec3f_copy(cursor, ray.hitPos)
    return cursor
end

local function vec3f_rotate_zyx(dest, rotate)
    local v = { x = dest.x, y = dest.y, z = dest.z }

    local sx = sins(rotate.x)
    local cx = coss(rotate.x)

    local sy = sins(rotate.y)
    local cy = coss(rotate.y)

    local sz = sins(rotate.z)
    local cz = coss(rotate.z)

    -- Rotation around Z axis
    local xz = v.x * cz - v.y * sz
    local yz = v.x * sz + v.y * cz
    local zz = v.z

    -- Rotation around Y axis
    local xy = xz * cy + zz * sy
    local yy = yz
    local zy = -xz * sy + zz * cy

    -- Rotation around X axis
    dest.x = xy
    dest.y = yy * cx - zy * sx
    dest.z = yy * sx + zy * cx

    return dest
end

---@param x number
---@param y number
---@param z number
---@param r integer?
---@param g integer?
---@param b integer?
function Sun(x, y, z, r, g, b)
    return {
        x = x,
        y = y,
        z = z,
        r = r or 255,
        g = g or 255,
        b = b or 255,
        unregister = unregister_point_light
    }
end
PointLight = Sun

---@type Sun
local sun

--- @type PointLight[]
local pointLights = {}

--- @type PointLight[]
local placedPointLights = {}

---@return PointLight
function register_point_light(...)
    local l
    if select("#", ...) == 1 then
        l = select(1, ...)
    else l = PointLight(...) end
    table.insert(pointLights, l)
    return l
end

function unregister_point_light(light)
    for i, l in ipairs(pointLights) do
        if l == light then
            table.remove(pointLights, i)
        return end
    end
    log_to_console("ERROR: Light not found!", CONSOLE_MESSAGE_ERROR)
end

-- initialize point lights
local goombaLight = register_point_light(0, 0, 0)
local cPointLight
local mouseLight = register_point_light(0, 0, 0)

function update_point_lights()
    local m = gMarioStates[0]
    -- goomba point light
    local goomba = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvGoomba)
    if goomba then vec3f_copy(goombaLight, goomba.header.gfx.pos) end

    -- set point light
    if m.controller.buttonPressed & X_BUTTON ~= 0 then
        if not cPointLight then
            cPointLight = register_point_light(m.pos.x, m.pos.y, m.pos.z)
        else cPointLight:unregister() end
    end

    -- mouse point light
    local mouse = get_mouse_world_pos()
    vec3f_copy(mouseLight, mouse)
end

local pitch
local yaw
local roll
local suntrans = vec3f()
local off = 0x28 / 0xFF
local offset = vec3f(off, off, off)

---@param m MarioState
hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex == 0 then update_point_lights() end

    local b = m.marioBodyState
    local mPos = vec3f()
    vec3f_copy(mPos, m.pos)
    mPos.y = mPos.y + m.marioObj.hitboxHeight / 2

    local pl
    local dist = 1000
    for _, l in ipairs(pointLights) do
        local d = vec3f_dist(mPos, l)
        if d < dist then
            pl = l
            dist = d
        end
    end
    if not pl then return end

    local plt = vec3f()
    vec3f_copy(plt, pl)
    vec3f_dif(plt, mPos, plt)
    plt.y = -plt.y
    vec3f_rotate_zyx(plt, { x = -pitch, y = -yaw, z = roll })
    vec3f_normalize(plt)
    -- vec3f_mul(suntrans, 1/127)

    b.lightingDirX = -suntrans.x/127*(m.controller.buttonDown & L_JPAD ~= 0 and 1 or 0) + plt.x/127 - off
    b.lightingDirY = -suntrans.y/127*(m.controller.buttonDown & L_JPAD ~= 0 and 1 or 0) + plt.y/127 - off
    b.lightingDirZ = -suntrans.z/127*(m.controller.buttonDown & L_JPAD ~= 0 and 1 or 0) + plt.z/127 - off

    debug_message(""..b.lightingDirX)
    debug_message(""..b.lightingDirY)
    debug_message(""..b.lightingDirZ)
    debug_message(""..suntrans.x)
    debug_message(""..suntrans.y)
    debug_message(""..suntrans.z)
    -- b.lightR = pl.r
    -- b.lightG = pl.g
    -- b.lightB = pl.b
    debug_message("mario #"..m.playerIndex.." has been lit.")
end)

hook_chat_command("flash", "light mario", function()
    flashlight = not flashlight
    djui_chat_message_create("Flashlight Mario is "..(flashlight and "on!" or "off."))
    return true
end)

local lightRoll = 0
function update_sun()
    local l = gLakituState
    pitch = calculate_pitch(l.pos, l.focus)
    yaw = calculate_yaw(l.pos, l.focus)
    roll = lightRoll

    local s = vec3f()
    vec3f_copy(s, sun)
    vec3f_rotate_zyx(s, { x = -pitch, y = -yaw, z = roll })
    vec3f_sub(s, offset)
    vec3f_copy(suntrans, s)
    debug_message(""..vec3f_length(s))

    set_lighting_dir(0, s.x)
    set_lighting_dir(1, s.y)
    set_lighting_dir(2, s.z)

    set_lighting_color(0, sun.r)
    set_lighting_color(1, sun.g)
    set_lighting_color(2, sun.b)
end

hook_event(HOOK_UPDATE, function ()
    -- preset sun
    sun = Sun(50, 100, -90)

    local m = gMarioStates[0]
    -- flashlight mario
    -- if m.controller.buttonPressed & Y_BUTTON ~= 0 then
    --     flashlight = not flashlight
    -- end

    if flashlight then
        local fwd = vec3f()
        local head = m.marioBodyState.headAngle
        local angle = vec3f()
        if gFirstPersonCamera.enabled then
            angle.y = gFirstPersonCamera.yaw - 0x8000
            angle.x = gFirstPersonCamera.pitch
        else
            angle.y = m.faceAngle.y + head.y
            angle.z = m.faceAngle.x + head.x
        end
        fwd.x = sins(angle.y) * 100 * coss(angle.x)
        fwd.z = coss(angle.y) * 100 * coss(angle.x)
        fwd.y = coss(angle.x) * 100

        vec3f_copy(sun, fwd)

        -- brightness
        local brightness = 255

        local eye = m.marioBodyState.eyeState

        -- handle blinking
        if eye == MARIO_EYES_BLINK then
            local blinkFrame = ((get_area_update_counter() + m.playerIndex * 32) >> 1) & 0x1F
            eye = ({ 2, 3, 2, 1, 2, 3, 2 })[blinkFrame] or 1
        end

        if eye == MARIO_EYES_HALF_CLOSED then brightness = 127 end
        if eye == MARIO_EYES_CLOSED      then brightness = 0 end

        sun.r = brightness
        sun.g = brightness
        sun.b = brightness
    end

    update_sun()
end)

hook_event(HOOK_UPDATE, function ()
    local o = obj_get_first(OBJ_LIST_GENACTOR)
    if o then
        o.hookRender = 69
    end
end)

hook_event(HOOK_ON_OBJECT_RENDER, function(obj)
    if obj.hookRender == 69 then
        camera = cast_graph_node(obj.header.gfx.node.parent.parent.parent)
        camera.fnNode.node.hookProcess = 69
    end
end)

hook_event(HOOK_ON_GEO_PROCESS, function(node, i)
    if node.type ~= GRAPH_NODE_TYPE_CAMERA then return end
    lightRoll = cast_graph_node(node).rollScreen
end)
