--Random helper functions that don't really belong anywhere else.


function get43size(size4_3)
	return 640*(size4_3/854)
end;


function capWideScale(AR4_3,AR16_9)
	if AR4_3 < AR16_9 then
		return clamp(WideScale(AR4_3, AR16_9),AR4_3,AR16_9)
	else
		return clamp(WideScale(AR4_3, AR16_9),AR16_9,AR4_3)
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

--Recursively grabs the parents' position.
--dunno if it actually returns the correct position, but it works with my needs for now.
function getTrueX(element)
	if element == nil then
		return 0
	end;
	if element:GetParent() == nil then
		return element:GetX() or 0
	else
		return element:GetX()+getTrueX(element:GetParent())
	end;
end;

function getTrueY(element)
	if element == nil then
		return 0
	end;
	if element:GetParent() == nil then
		return element:GetY() or 0
	else
		return element:GetY()+getTrueY(element:GetParent())
	end;
end;

--Button Rollovers
function isOver(element)
	--[[
	if element:GetVisible() == false then
		return false
	end;
	--]]
	local x = getTrueX(element)
	local y = getTrueY(element)
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

--for non-array tables.
function getTableSize(table)
	local i = 0
	for k,v in pairs(table) do
		i = i+1
	end;
	return i
end;
