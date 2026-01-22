local player = {
	x = 40,
	y = 260,
	z = 0, --unused, for vec3f_copy
	w = 40,
	h = 70,
	deg = 0,
	xVel = 0,
	yVel = -20,
	degVel = 0
}
local prevPlayer = {
	x = 0,
	y = 9,
	z = 0 --unused, for vec3f_copy
}
local camera = {
	x = 0,
	y = 0,
	z = .05,
	xFocus = 0
}
local prevCamera = {
	x = 0,
	y = 0,
	z = .05,
}
local platforms = {}
local entity = {}
local wallX = 0

function isDown(c) return gMarioStates[0].controller.buttonDown & c ~= 0 end

--function cssUpdate()
--	local root = document.querySelector(":root").style 
--	root.setProperty("--cameraX", (camera.x*-1+window.innerWidth/camera.z/2)*camera.z+"px")
--	root.setProperty("--cameraY", (camera.y*-1+window.innerHeight/camera.z/2)*camera.z+"px")
--	root.setProperty("--cameraZ", camera.z)
--	root.setProperty("--playerWidth", player.w+"px")
--	root.setProperty("--playerHeight", player.h+"px")
--	root.setProperty("--playerX", player.x-player.w/2+"px")
--	root.setProperty("--playerY", player.y-player.h/2+"px")
--	root.setProperty("--playerXAnchor", player.w*-.5+player.w/2+"px")
--	root.setProperty("--playerYAnchor", -player.h+player.h/2+"px")
--	root.setProperty("--playerXAReal", -player.xAnchor+"px")
--	root.setProperty("--playerYAReal", -player.yAnchor+"px")
--	root.setProperty("--playerDeg", player.deg + "deg")
--end
local rot = 0.0
local rate = 0
hook_chat_command("rot", " ", function (n) rate = tonumber(n) or 0 end)
function cssUpdate()
	rot = rot + rate
	djui_hud_set_resolution(RESOLUTION_DJUI)
	local w = djui_hud_get_screen_width()
	local h = djui_hud_get_screen_height()
	local c = camera
	local pc = prevCamera
	-- djui_hud_set_rotation(rot, .5, .5)
	djui_hud_set_rotation_interpolated(rot-rate, .5, .5, rot, .5, .5)

	for _, p in pairs(platforms) do
		djui_hud_set_color(p.color.r, p.color.g, p.color.b, p.color.a and p.color.a or 255)
		--djui_hud_render_rect((p.x-c.x)*c.z+w/2, (p.y-c.y)*c.z+h/2, p.w*c.z, p.h*c.z)
		djui_hud_render_rect_interpolated((p.x-pc.x)*pc.z+w/2, (p.y-pc.y)*pc.z+h/2, p.w*pc.z, p.h*pc.z,
		                                  (p.x- c.x)* c.z+w/2, (p.y- c.y)* c.z+h/2, p.w* c.z, p.h* c.z)
	end

	local p = player
	local pp = prevPlayer
	djui_hud_set_rotation(player.deg*16384/180, .5, 1)
	djui_hud_set_color(0, 255, 0, 255)
	--djui_hud_render_rect((player.x-player.w/2-c.x)*c.z+w/2, (player.y-player.h-c.y)*c.z+h/2, player.w*c.z, player.h*c.z)
	djui_hud_render_rect_interpolated((pp.x-p.w/2-pc.x)*pc.z+w/2, (pp.y-p.h-pc.y)*pc.z+h/2, p.w*pc.z, p.h*pc.z,
	                                  (p .x-p.w/2- c.x)* c.z+w/2, (p .y-p.h- c.y)* c.z+h/2, p.w* c.z, p.h* c.z)
end

function createPlatform(x,y,w,h,color,type)
	table.insert(platforms, {
		x = x,
		y = y,
		w = w,
		h = h,
		color = color,
		type = type
	})
	return platforms[#platforms]
end

function deletePlatform(id)
	table.remove(platforms, id)
end

function spawnEntity(x,y,w,h,color,type)
	table.insert(entity, {
		x = x,
		y = y,
		w = w,
		h = h,
		color = color,
		type = type
	})
	return entity[#entity]
end

function destroyEntity(id)
	table.remove(entity, id)
end

function collide(side)
	for _, platform in pairs(platforms) do
		if side == "u" then
			if (player.y - player.h == platform.y + platform.h and platform.x - player.w/2 < player.x and player.x < platform.x + platform.w + player.w/2 and platform.type == 0) then
				return true
			end
		elseif side == "d" then
			if (player.y == platform.y and platform.x - player.w/2 < player.x and player.x < platform.x + platform.w + player.w/2) then
				return true
			end
		elseif side == "l" then
			if (platform.x + platform.w <= player.x - player.w/2 + 1 and player.x - player.w/2 + 1 <= platform.x + platform.w + 1 and platform.y <= player.y and player.y < platform.y + platform.h + player.h and platform.type == 0) then
				wallX = platform.x + platform.w + player.w/2
				return true
			end
		elseif side == "r" then
			if (platform.x - 1 <= player.x + player.w/2 - 1 and player.x + player.w/2 - 1 <= platform.x and platform.y <= player.y and player.y < platform.y + platform.h + player.h and platform.type == 0) then
				wallX = platform.x - player.w/2
				return true
			end
		end
	end
	return false
end

function step()
	player.deg = player.deg + player.degVel
	player.deg = player.xVel

	if not collide("d") then
		player.yVel = player.yVel + 1
	end
	if not (collide("d") and collide("u")) and collide("d") then
		if isDown(U_JPAD) then
			player.yVel = -20
		end
	end

	if isDown(R_JPAD) and math.abs(player.xVel) < 16 then
		player.xVel = player.xVel + 1
	elseif isDown(L_JPAD) and math.abs(player.xVel) < 16 then
		player.xVel = player.xVel - 1
	else
		if player.xVel > 0 then
			player.xVel = player.xVel - 1
		elseif player.xVel < 0 then
			player.xVel = player.xVel + 1
		end
	end

	if player.yVel ~= 0 then
		for i=0, math.abs(player.yVel) do
			if player.yVel > 0 then
				player.y = player.y + 1
				if collide("d") then
					player.yVel = 0
					break
				end
			elseif (player.yVel < 0) then
				if collide("u") then
					player.yVel = 0
					if not (collide("d") and collide("u")) then
						player.y = player.y + 1
					end
					break
				end
				player.y = player.y - 1
			end
		end
	end
	if player.xVel ~= 0 then
		for i=0, math.abs(player.xVel) do
			if (player.xVel > 0) then
				player.x = player.x + 1
				if (collide("r")) then
					player.xVel = 0
					player.x = wallX
					break
				end
			elseif (player.xVel < 0) then
				player.x = player.x - 1
				if (collide("l")) then
					player.xVel = 0
					player.x = wallX
					break
				end
			end
		end
	end

	if not isDown(L_JPAD | R_JPAD) then
		camera.xFocus = camera.x
	end
	camera.x = camera.x + ( ( isDown(L_JPAD | R_JPAD) and player.x + player.xVel*20 or camera.xFocus) - camera.x ) * 0.1
	camera.y = camera.y + ( ( player.y + player.yVel*20 - 100) - camera.y) * 0.1
	camera.z = camera.z + ( ( 1 / (math.sqrt(sqrf(math.abs(camera.x - player.x)) + sqrf(math.abs(camera.y - player.y+100))) * 0.01 + 1)) - camera.z) * 0.05

	if isDown(D_JPAD) then
		rate = rate + 64
	end
end
function loop()
	vec3f_copy(prevCamera, camera)
	vec3f_copy(prevPlayer, player)
	step()
	step()
	cssUpdate()
end

hook_event(HOOK_ON_HUD_RENDER, loop)
createPlatform(0,		400,	1000,	20,	{ r=255,	g=  0,	b=  0 }, 0)
createPlatform(100,		10000,	1000,	20,	{ r=255,	g=  0,	b=  0 }, 0)
createPlatform(200,		250,	400,	20,	{ r=  0,	g=  0,	b=255 }, 1)
createPlatform(500,		330,	20,		90,	{ r=255,	g=255,	b=  0 }, 0)
createPlatform(560.3,	330,	20,		90,	{ r=255,	g=255,	b=  0 }, 0)
createPlatform(800,		280,	20,		50,	{ r=255,	g=255,	b=  0 }, 0)
createPlatform(1000,	330,	20,		90,	{ r=255,	g=255,	b=  0 }, 0)
-- alert("this game totally wasn't stolen from stack exchange, any matches found online are entirely coincidental")
