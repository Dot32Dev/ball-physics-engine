--[[

I did not write this myself, and i cannot begin to understand it.
Massive thanks to https://2dengine.com/?p=intersections for the code!

While i am still handling the collision in my project, this can take
the ball's current location and return to me the closest point to the
ball on the triangle, something which i was struggeling to calculate
for myself!

]]

local function dot(ax, ay, bx, by)
  return ax*bx + ay*by
end
function pointOnTriangle(px, py, ax, ay, bx, by, cx, cy)
  local abx, aby = bx - ax, by - ay
  local acx, acy = cx - ax, cy - ay
  local apx, apy = px - ax, py - ay
  -- vertex region outside a
  local d1 = dot(abx, aby, apx, apy)
  local d2 = dot(acx, acy, apx, apy)
  if d1 <= 0 and d2 <= 0 then
    return ax, ay
  end
  -- vertex region outside b
  local bpx, bpy = px - bx, py - by
  local d3 = dot(abx, aby, bpx, bpy)
  local d4 = dot(acx, acy, bpx, bpy)
  if d3 >= 0 and d4 <= d3 then
    return bx, by
  end
  -- edge region ab
  if d1 >= 0 and d3 <= 0 and d1*d4 - d3*d2 <= 0 then
    local v = d1/(d1 - d3)
    return ax + abx*v, ay + aby*v
  end
  -- vertex region outside c
  local cpx, cpy = px - cx, py - cy
  local d5 = dot(abx, aby, cpx, cpy)
  local d6 = dot(acx, acy, cpx, cpy)
  if d6 >= 0 and d5 <= d6 then
    return cx, cy
  end
  -- edge region ac
  if d2 >= 0 and d6 <= 0 and d5*d2 - d1*d6 <= 0 then
    local w = d2/(d2 - d6)
    return ax + acx*w, ay + acy*w
  end
  -- edge region bc
  if d3*d6 - d5*d4 <= 0 then
    local d43 = d4 - d3
    local d56 = d5 - d6
    if d43 >= 0 and d56 >= 0 then
      local w = d43/(d43 + d56)
      return bx + (cx - bx)*w, by + (cy - by)*w
    end
  end
  -- inside face region
  return px, py
end

return pointOnTriangle