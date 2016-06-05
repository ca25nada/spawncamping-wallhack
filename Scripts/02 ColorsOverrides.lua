
-- trying to add saturation to an completely desaturated color doesn't make sense.
function Saturation(color,percent)
	local c = ColorToHSV(color)

	if c.Sat == 0 then
		return color
	end
	-- error checking
	if percent < 0 then
		percent = 0.0
	elseif percent > 1 then
		percent = 1.0
	end
	c.Sat = percent
	return HSVToColor(c)
end