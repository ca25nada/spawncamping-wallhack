local topActor
local topActorZ = 0
local topActorName

-- To check the Z axis for getting the topmost actor upon clicking:
-- Give an actor a Z value and call addPressedActors(self) inside any command.
-- (e.g. MouseLeftClickMessageCommand)
-- If the actor is supposed to react to the click (e.g. button), add a TopPressedCommand to the actor.
-- TopPressedCommand will be called for a single actor with the highest Z value.

-- The above is already done for you for quads if you call:
-- quadButton(z)
-- So the above only applies for adding non-quad actors as buttons.

-- Call this when left/right click event occurs and isOver() is true.
-- Sets the actor calling this as the top actor if it has the highest Z value.
function addPressedActors(actor, screenName)
	local top = SCREENMAN:GetTopScreen()
	local topName

	if top == nil then
		return
	else
		topName = top:GetName()
	end

	-- SCREENMAN:SystemMessage(string.format("%s %s",screenName, topName))

	if topName ~= screenName then
		return
	end

	local z = actor:GetZ()
	if z > topActorZ then
		topActorZ = z
		topActor = actor
		topName = actor:GetName()
	end
end

-- Resets the variables back to original values.
function resetPressedActors()
	topActor = nil
	topActorZ = 0
	topActorName = nil
end

-- Plays the TopPressed Command on the current top actor.
function playTopPressedActor()	
	-- SCREENMAN:SystemMessage("PLAY PLS")
	if topActor ~= nil then
		topActor:playcommand("TopPressed")
	end
end


--Gets the true X/Y Position by recursively grabbing the parents' position.
--Does not take zoom into account.
function getTrueX(actor)
	if actor == nil then
		return 0
	end;
	if actor:GetParent() == nil then
		return actor:GetX() or 0
	else
		return actor:GetX()+getTrueX(actor:GetParent())
	end;
end;

function getTrueY(actor)
	if actor == nil then
		return 0
	end;
	if actor:GetParent() == nil then
		return actor:GetY() or 0
	else
		return actor:GetY()+getTrueY(actor:GetParent())
	end;
end;

--Button Rollovers
function isOver(actor)
	local x = getTrueX(actor)
	local y = getTrueY(actor)
	local hAlign = actor:GetHAlign()
	local vAlign = actor:GetVAlign()
	local w = actor:GetZoomedWidth()
	local h = actor:GetZoomedHeight()

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	local withinX = (mouseX >= (x-(hAlign*w))) and (mouseX <= ((x+w)-(hAlign*w)))
	local withinY = (mouseY >= (y-(vAlign*h))) and (mouseY <= ((y+h)-(vAlign*h)))

	return (withinX and withinY)
end;


function quadButton(z)
	local topName 

	local t = Def.Quad{
		InitCommand= function(self) 
			self:z(z)
		end;

		OnCommand = function(self)
			local top = SCREENMAN:GetTopScreen()
			topName = top:GetName()
		end;

		MouseLeftClickMessageCommand = function(self)
			if isOver(self) then
				addPressedActors(self, topName)
			end
		end;
		TopPressedCommand = function(self)
		end;
	}

	return t
end
