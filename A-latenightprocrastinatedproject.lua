-- scene 1

-- function lerp(a, b, t) return clampf(a * (1 - t) + b * t, min(a,b), max(a,b)) end

-- local bgColor = {201, 174, 174}

-- local box1Color = {246, 154, 74}
-- local box2Color = {134, 38, 8}
-- local box3Color = {7, 36, 79}

-- local time = 0

-- local offset = 40
-- local boxSize = 80

-- local startY = offset
-- local endY = 500 - offset - boxSize

-- hook_event(HOOK_ON_HUD_RENDER, function ()
--     if gMarioStates[0].controller.buttonPressed & Y_BUTTON ~= 0 then
--         time = 0
--         startY, endY = endY, startY
--     end

--     local trueX = clampf(startY>endY and time or 1-time, 0, 1)
--     djui_hud_set_color(bgColor[1], bgColor[2], bgColor[3], 255)
--     djui_hud_render_rect(0, 0, 540, 500)

--     djui_hud_set_color(box1Color[1], box1Color[2], box1Color[3], 255)
--     djui_hud_render_rect(offset, lerp(startY, endY, time), boxSize, boxSize)

--     djui_hud_set_color(box2Color[1], box2Color[2], box2Color[3], 255)
--     djui_hud_render_rect(offset*2+boxSize*1, lerp(startY, endY, time*time), boxSize, boxSize)

--     djui_hud_set_color(box3Color[1], box3Color[2], box3Color[3], 255)
--     djui_hud_render_rect(offset*3+boxSize*2, lerp(startY, endY, sins(time*16384)), boxSize, boxSize)

--     djui_hud_set_color(255, 211, 211, 255)
--     djui_hud_print_text(("x: "..trueX):sub(1, 7), offset*4+boxSize*3, 540 - offset - boxSize, 1.5)

--     djui_hud_render_rect(offset*4+boxSize*3+10, (540 - offset - boxSize)-trueX*380, 70, trueX*380)
--     time = minf(time+.03, 1)
-- end)

--------------------------------------------------------------------------------------------------------------------------------------

-- scene 2

-- function render_rect(x, y, size)
--     djui_hud_render_rect(x-size/2, y-size/2,size, size)
-- end

-- function sm64_to_radians(val) return val * math.pi / 0x8000 end

-- local bgColor = {201, 174, 174}

-- local boxCount = 5
-- local boxColor = {255, 211, 211}
-- local boxSize = 15

-- local offset = 10

-- local boxes = {}
-- for i=1, boxCount do
--     boxes[i] = {
--         radius = 100 + boxSize*i + offset*(i-1),
--         vel = 10,
--         dist = 0
--     }
-- end
-- local sunX = 250
-- local sunY = 500

-- local angle = 256*60
-- local release = false

-- local angle2 = 256*20

-- hook_event(HOOK_ON_HUD_RENDER, function ()
--     release = angle < -28000

--     djui_hud_set_color(42, 33, 33, 255)
--     djui_hud_render_rect(0, 0, 700, 600)
--     djui_hud_set_color(bgColor[1], bgColor[2], bgColor[3], 255)
--     djui_hud_render_rect(0, 0, 500, 600)

--     djui_hud_set_rotation((angle+min(0, angle2))/3, .5, .5)
--     djui_hud_set_color(250, 242, 175, 255)
--     render_rect(sunX, sunY, 100)

--     for i, box in ipairs(boxes) do
--         djui_hud_set_rotation(angle+box.dist*256, .5, .5)

--         local x = box.radius*sins(angle) + box.dist*coss(angle) + sunX
--         local y = box.radius*coss(angle) - box.dist*sins(angle) + sunY

--         box.vel = sm64_to_radians(256)*box.radius
--         box.dist = release and box.dist - box.vel or 0

--         djui_hud_set_color(30, 30, 30, 64)
--         djui_hud_print_text("r="..box.radius, x+2, y+2, 1)
--         djui_hud_print_text(("vel: "..box.vel):sub(1, 9), x+2, y+32+2, 1)

--         djui_hud_set_color(boxColor[1], boxColor[2], boxColor[3], 255)
--         djui_hud_print_text("r="..box.radius, x, y, 1)
--         djui_hud_print_text(("vel: "..box.vel):sub(1, 9), x, y+32, 1)

--         render_rect(x, y, boxSize)
--     end

--     angle = angle - (release and 0 or 256)
--     angle2= angle2- (release and 256 or 0)
-- end)

--------------------------------------------------------------------------------------------------------------------------------------

-- scene 3

function lerp(a, b, t) return clampf(a * (1 - t) + b * t, min(a,b), max(a,b)) end

function thsnd(num)
    local k = math.floor(num / 1000)
    return "$"..k.."k"
end

local bgColor = {201, 174, 174}

local barCount = 8
local barColor = {255, 211, 211}
local barSize = 50

local padding = 20
local offset = 20
local bottomOffset = 40

local bars = {}
for i=1, barCount do
    bars[i] = {
        height = 0
    }
end

local P = 25000
local r = .09
local n = 12

local maxVal = (600-padding-bottomOffset)/(P*(1+(r/n))^(n*(#bars-1)))

local time = -4
hook_event(HOOK_ON_HUD_RENDER, function ()
    djui_hud_set_color(bgColor[1], bgColor[2], bgColor[3], 255)
    djui_hud_render_rect(0, 0, padding*2+(offset+barSize)*(#bars)-offset, 600)

    djui_hud_set_color(barColor[1], barColor[2], barColor[3], 255)

    for i, bar in ipairs(bars) do
        i = i-1
        local A = lerp(0, P*(1+(r/n))^(n*i), maxf(0, (time-i))^2)
        bar.height = A*maxVal

        local x = padding+(offset+barSize)*(i)
        local y = 600-bottomOffset-bar.height

        djui_hud_render_rect(x, y, barSize, bar.height)
        
        local m = thsnd(A)
        djui_hud_set_color(30, 30, 30, 64)
        djui_hud_print_text(m, x+2-5, 600-bottomOffset+2, 1)

        djui_hud_set_color(barColor[1], barColor[2], barColor[3], 255)
        djui_hud_print_text(m, x-5, 600-bottomOffset, 1)
    end
    
    time = time + 0.03
end)
