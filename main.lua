local intro = require("intro")
local level = require("level")

intro:init()
love.graphics.setBackgroundColor(0.1, 0.15, 0.15)

local balls = {}
local alerts = {}

local function circleVsRectangle(circle, rectangle)
  local px = circle.x
  local py = circle.y
  px = math.max(px, rectangle.x)
  px = math.min(px, rectangle.x + rectangle.w)
  py = math.max(py, rectangle.y)
  py = math.min(py, rectangle.y + rectangle.h)

  if ((circle.y-py)^2 + (circle.x-px)^2) < circle.r^2 then
  	local offset = {x = circle.x - px, y = circle.y - py}
		local distance = math.sqrt(offset.x^2 + offset.y^2)
		local direction = {x = offset.x/distance, y = offset.y/distance} 
		local moveLen = circle.r - distance

		circle.x = circle.x + moveLen*direction.x
		circle.y = circle.y + moveLen*direction.y

		return circle.x, circle.y
	end
	return false
end

function love.update()
	--[[APPLY FORCES TO BALL]]
	for i, ball in ipairs(balls) do
		local xV = (ball.x - (ball.xPre or ball.x))*0.98
		local yV = ball.y - (ball.yPre or ball.y)

		local perimetre = math.pi*ball.r*2
		ball.dir = ball.dir - xV/perimetre*math.pi*2

		ball.xPre = ball.x
		ball.yPre = ball.y
		ball.y = ball.y + 0.5 -- gravity is 1

		ball.x = ball.x + xV
		ball.y = ball.y + yV

		if ball.x ~= ball.x then
			ball.unstable = true
		end
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

				if (ball ~= sibling) and (ball.x == sibling.x) then
					ball.xPre = ball.xPre 
					-- + (-0.5 + math.random())*0.1
				end
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
		for i, rect in ipairs(level) do
			ball.x, ball.y = circleVsRectangle(ball, level[i]) or ball.x, ball.y
		end

		if ball.x > love.graphics.getWidth()-ball.r then
			ball.x = love.graphics.getWidth()-ball.r
		end
		if ball.x < ball.r then
			ball.x = ball.r
		end
		if ball.y > love.graphics.getHeight()-ball.r then
			ball.y = love.graphics.getHeight()-ball.r
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
	love.graphics.setColour(0.2, 0.5, 0.7)
	for i=1, #level do
		love.graphics.rectangle("fill", level[i].x, level[i].y, level[i].w, level[i].h)
	end

	-- love.graphics.setColour(0.7, 0.5, 0.2)
	for i=1, #balls do
		love.graphics.setColour(balls[i].c)
		love.graphics.circle("fill", balls[i].x, balls[i].y, balls[i].r)

		love.graphics.setColour(0,0,0)
		love.graphics.setLineWidth(2)
		love.graphics.circle("line", balls[i].x, balls[i].y, balls[i].r)
		love.graphics.line(balls[i].x, balls[i].y, balls[i].x + math.sin(balls[i].dir)*balls[i].r, balls[i].y + math.cos(balls[i].dir)*balls[i].r)
	end

	love.graphics.setColor(0.7, 0.5, 0.2)
	-- love.graphics.print(intro.varToString(balls))

	intro:draw()
end

function love.mousepressed(x,y)
	local ball = {}
	ball.x = x
	ball.y = y
	ball.r = 20
	ball.c = intro.HSL(math.random(0, 360)/360, 0.1, math.random()/2+0.25)
	ball.dir = 0
	table.insert(balls, ball)
end

function love.keypressed(k)
	balls = (k == "r" and {}) or balls
end