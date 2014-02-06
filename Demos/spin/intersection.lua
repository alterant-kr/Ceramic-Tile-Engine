return function(ax, ay, bx, by, cx, cy, dx, dy)
	local distAB
	local tcos
	local tsin
	local newX
	local abPos
	
	-- Fail if either line segment is zero - length.
	if (ax == bx and ay == by or cx == dx and cy == dy) then
		return nil
	end

	-- Fail if the segments share an end - point.		 
	if (ax == cx and ay == cy or bx == cx and by == cy or 
		ax == dx and ay == dy or bx == dx and by == dy) then
		return nil
	end
	
	-- Translate the system so that point A is on the origin.		 
	bx = bx - ax
	by = by - ay
	cx = cx - ax
	cy = cy - ay
	dx = dx - ax
	dy = dy - ay
	
	-- Discover the length of segment A - B.
	distAB = (bx * bx + by * by) ^ 0.5
	
	-- Rotate the system so that point B is on the positive X axis.
	tcos = bx / distAB
	tsin = by / distAB
	newX = cx * tcos + cy * tsin
	cy = cy * tcos - cx * tsin
	cx = newX
	newX = dx * tcos + dy * tsin
	dy = dy * tcos - dx * tsin
	dx = newX
	
	-- Fail if segment C - D doesn't cross line A - B.
	if (cy<0 and dy<0 or cy >= 0 and dy >= 0) then
		return nil-- - 3
	end

	-- Discover the position of the intersection point along line A - B.		 
	abPos = dx + (cx - dx) * dy / (dy - cy)
	
	-- Fail if segment C - D crosses line A - B outside of segment A - B.
	if (abPos < 0 or abPos > distAB) then
		return nil
	end

	-- Apply the discovered position to line A - B in the original coordinate system.  
	local oX = ax + abPos * tcos
	local oY = ay + abPos * tsin
	

	return {x = oX, y = oY}
end