--Random helper functions that don't really belong anywhere else.

function get43size(size4_3)
	return 640*(size4_3/854)
end;


function capWideScale(AR4_3,AR16_9)
	if AR4_3 < AR16_9 then
		return math.max(AR4_3,math.min(AR16_9,WideScale(AR4_3, AR16_9)))
	else
		return math.min(AR4_3,math.max(AR16_9,WideScale(AR4_3, AR16_9)))
	end;
end;

--returns current autoplay type. returns a integer between 0~2 corresponding to
--human, autoplay and autoplay cpu respectively.
function getAutoplay()
	return Enum.Reverse(PlayerController)[tostring(PREFSMAN:GetPreference("AutoPlay"))]
end;

--returns true if windowed.
function isWindowed()
	return PREFSMAN:GetPreference("Windowed")
end;

--Button Rollovers
function isOver(element)
	--[[
	if element:GetVisible() == false then
		return false
	end;
	--]]
	local x = element:GetX()
	local y = element:GetY()
	local hAlign = element:GetHAlign()
	local vAlign = element:GetVAlign()
	local w = element:GetZoomedWidth()
	local h = element:GetZoomedHeight()

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	local withinX = (mouseX >= (x-(hAlign*w))) and (mouseX <= ((x+w)-(hAlign*w)))
	local withinY = (mouseY >= (y-(vAlign*h))) and (mouseY <= ((y+h)-(vAlign*h)))

	return (withinX and withinY)
end;

--returns if the table contains the key.
function tableContains(table,key)
	return (table[key] ~= nil)
end;