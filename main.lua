local intro = require("intro")
local level = require("level")
local triangleCollision = require("magical triangle collision i found")

intro:init()
-- love.graphics.setBackgroundColor(0.1, 0.15, 0.15)
love.graphics.setBackgroundColor(intro.HSL(220/360, 0.5, 0.1))

local balls = {}

function love.update()
	--[[APPLY FORCES TO BALL]]
	for i, ball in ipairs(balls) do
		if ball.x ~= ball.x then -- temporary fix to something that should ideally never happen
			ball.x = ball.xPre
			ball.y = ball.yPre
		end
		local xV = (ball.x - (ball.xPre or ball.x))*0.98
		local yV = ball.y - (ball.yPre or ball.y)

		local perimetre = math.pi*ball.r*2
		ball.rotationsPerTick = - xV/perimetre*math.pi*2
		ball.dir = ball.dir + ball.rotationsPerTick

		ball.xPre = ball.x
		ball.yPre = ball.y
		ball.y = ball.y + 0.5 -- gravity is 0.5

		ball.x = ball.x + xV
		ball.y = ball.y + yV
	end

	--[[BALL VS BALL COLLISION]]
	for i=1, 2 do
	for i, ball in ipairs(balls) do 
		for i, sibling in ipairs(balls) do
			if (ball ~= sibling) and ((ball.y-sibling.y)^2 + (ball.x-sibling.x)^2) < (ball.r+sibling.r)^2 then
				local offset = {x = ball.x - sibling.x, y = ball.y - sibling.y}
				local distance = math.sqrt(offset.x^2 + offset.y^2) 
				local direction = {x = offset.x/distance, y = offset.y/distance}
				local moveLen = (ball.r + sibling.r) - distance

				ball.x = ball.x + moveLen*direction.x*0.5
				ball.y = ball.y + moveLen*direction.y*0.5

				sibling.x = sibling.x + moveLen*direction.x*-0.5
				sibling.y = sibling.y + moveLen*direction.y*-0.5
			end
			if (ball ~= sibling) and (ball.x == sibling.x and ball.y == sibling.y) then
				ball.xPre = ball.xPre + love.math.random()*5-2.5
				ball.yPre = ball.yPre + love.math.random()*5-2.5
			end
		end
	end
	end

	--[[BALL VS WALL COLLISION]]
	for i, ball in ipairs(balls) do
		for i, rectangle in ipairs(level["rects"]) do
			local px = ball.x
		  local py = ball.y
		  px = math.max(px, rectangle.x)
		  px = math.min(px, rectangle.x + rectangle.w)
		  py = math.max(py, rectangle.y)
		  py = math.min(py, rectangle.y + rectangle.h)

		  if ((ball.y-py)^2 + (ball.x-px)^2) < ball.r^2 then
		  	local offset = {x = ball.x - px, y = ball.y - py}
				local distance = math.sqrt(offset.x^2 + offset.y^2)
				local direction = {x = offset.x/distance, y = offset.y/distance} 
				local moveLen = ball.r - distance

				ball.x = ball.x + moveLen*direction.x
				ball.y = ball.y + moveLen*direction.y
			end
		end
		for i, triangle in ipairs(level["tris"]) do
			if ball.x+ball.r > triangle.bound.x
			and ball.x-ball.r < triangle.bound.x + triangle.bound.w
			and ball.y+ball.r > triangle.bound.y
			and ball.y-ball.r < triangle.bound.y + triangle.bound.h
			then
				px, py = triangleCollision(ball.x, ball.y, triangle[1].x, triangle[1].y, triangle[2].x, triangle[2].y, triangle[3].x, triangle[3].y)
				if ((ball.y-py)^2 + (ball.x-px)^2) < ball.r^2 then
			  	local offset = {x = ball.x - px, y = ball.y - py}
					local distance = math.sqrt(offset.x^2 + offset.y^2)
					local direction = {x = offset.x/distance, y = offset.y/distance} 
					local moveLen = ball.r - distance

					ball.x = ball.x + moveLen*direction.x
					ball.y = ball.y + moveLen*direction.y
				end
			end
		end

		if ball.x > 1280-ball.r then
			ball.x = 1280-ball.r
		end
		if ball.x < ball.r then
			ball.x = ball.r
		end
		if ball.y > 720-ball.r then
			ball.y = 720-ball.r
		end
		if ball.y < ball.r then
			ball.y = ball.r
		end
	end

	for i=#balls, 1, -1 do
		if balls[i].unstable then
			table.remove(balls, i)
		end
	end

	intro:update()
end

function love.draw()
	-- love.graphics.setColour(0.2, 0.5, 0.7)
	love.graphics.push()
	-- love.graphics.scale(love.graphics.getWidth()/1280)
	love.graphics.setColour(intro.HSL(220/360, 0.5, 0.4))
	for i=1, #level["rects"] do
		love.graphics.rectangle("fill", level["rects"][i].x, level["rects"][i].y, level["rects"][i].w, level["rects"][i].h)
	end
	for i, triangle in ipairs(level["tris"]) do
		love.graphics.polygon("fill", triangle[1].x, triangle[1].y, triangle[2].x, triangle[2].y, triangle[3].x, triangle[3].y)
	end

	for i=1, #balls do
		-- love.graphics.setColour(0.7, 0.5, 0.2)
		love.graphics.setColour(balls[i].c)
		love.graphics.circle("fill", balls[i].x, balls[i].y, balls[i].r)

		love.graphics.setColour(0,0,0)
		love.graphics.setLineWidth(3)
		love.graphics.circle("line", balls[i].x, balls[i].y, balls[i].r-love.graphics.getLineWidth())
		-- love.graphics.line(balls[i].x, balls[i].y, balls[i].x + math.sin(balls[i].dir)*balls[i].r, balls[i].y + math.cos(balls[i].dir)*balls[i].r)
		love.graphics.circle("fill", balls[i].x-math.sin(balls[i].dir-60/180*math.pi)*10, balls[i].y-math.cos(balls[i].dir-60/180*math.pi)*10, love.graphics.getLineWidth())
		love.graphics.circle("fill", balls[i].x-math.sin(balls[i].dir+60/180*math.pi)*10, balls[i].y-math.cos(balls[i].dir+60/180*math.pi)*10, love.graphics.getLineWidth())
		love.graphics.line(
			balls[i].x-math.sin(balls[i].dir-120/180*math.pi)*6, balls[i].y-math.cos(balls[i].dir-120/180*math.pi)*6,
			balls[i].x-math.sin(balls[i].dir-140/180*math.pi)*6, balls[i].y-math.cos(balls[i].dir-140/180*math.pi)*6,
			balls[i].x-math.sin(balls[i].dir-180/180*math.pi)*6, balls[i].y-math.cos(balls[i].dir-180/180*math.pi)*6,
			balls[i].x-math.sin(balls[i].dir-220/180*math.pi)*6, balls[i].y-math.cos(balls[i].dir-220/180*math.pi)*6,
			balls[i].x-math.sin(balls[i].dir-240/180*math.pi)*6, balls[i].y-math.cos(balls[i].dir-240/180*math.pi)*6
		)
	end

	love.graphics.setColor(0.7, 0.5, 0.2)
	-- love.graphics.print(intro.varToString(balls))

	love.graphics.pop()
	intro:draw()
end

function love.mousepressed(x,y)
	-- x = x*1280/love.graphics.getWidth()
	-- y = y*1280/love.graphics.getWidth()
	local ball = {}
	ball.x = x -math.random()
	ball.y = y -math.random()
	ball.r = 20
	-- ball.c = intro.HSL(math.random(0, 360)/360, 0.1, math.random()/2+0.25)
	ball.c = intro.HSL(math.random(0, 360)/360, 0.5, 0.5)
	ball.dir = 0
	ball.rotationsPerTick = 0
	table.insert(balls, ball)
end

function love.keypressed(k)
	balls = (k == "r" and {}) or balls
end