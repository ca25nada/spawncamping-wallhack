MOUSE = {
	topActor = false,
	topActorZ = 0,
	topActorName = false,
	topInput = false,
}


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
function MOUSE.addPressedActors(self, actor, screenName, input)
	local top = SCREENMAN:GetTopScreen()
	local topName -- top screen name

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
	if z > self.topActorZ then
		self.topActorZ = z
		self.topActor = actor
		topName = actor:GetName()
		self.topInput = input
	end
end

-- Resets the variables back to original values.
function MOUSE.resetPressedActors(self)
	self.topActor = false
	self.topActorZ = 0
	self.topActorName = false
end

-- Plays the TopPressed Command on the current top actor.
function MOUSE.playTopPressedActor(self)	
	-- SCREENMAN:SystemMessage("PLAY PLS")
	if self.topActor then
		self.topActor:playcommand("TopPressed", {input = MOUSE.topInput})
	end
end


--Gets the true X/Y Position by recursively grabbing the parents' position.
--Does not take zoom into account.
function Actor.getTrueX(self)
	if self == nil then
		return 0
	end;

	local parent = self:GetParent()

	if parent == nil then
		return self:GetX() or 0
	else
		return self:GetX() + parent:getTrueX()
	end;
end;

function Actor.getTrueY(self)
	if self == nil then
		return 0
	end;

	local parent = self:GetParent()

	if parent == nil then
		return self:GetY() or 0
	else
		return self:GetY() + parent:getTrueY()
	end;
end;

--Button Rollovers
function Actor.isOver(self)
	local x = self:getTrueX()
	local y = self:getTrueY()
	local hAlign = self:GetHAlign()
	local vAlign = self:GetVAlign()
	local w = self:GetZoomedWidth()
	local h = self:GetZoomedHeight()

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
			if self:isOver() then
				MOUSE:addPressedActors(self, topName, "DeviceButton_left mouse button")
			end
		end;
		MouseRightClickMessageCommand = function(self)
			if self:isOver() then
				MOUSE:addPressedActors(self, topName, "DeviceButton_right mouse button")
			end
		end;
		TopPressedCommand = function(self)
		end;
	}

	return t
end
