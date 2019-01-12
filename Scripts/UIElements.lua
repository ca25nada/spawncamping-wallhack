BUTTON = {
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
function BUTTON.addPressedActors(self, actor, screenName, input)
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
function BUTTON.resetPressedActors(self)
	self.topActor = false
	self.topActorZ = 0
	self.topActorName = false
end

-- Plays the TopPressed Command on the current top actor.
function BUTTON.playTopPressedActor(self)	
	-- SCREENMAN:SystemMessage("PLAY PLS")
	if self.topActor then

		-- No way of checking whether the actor being referenced is stale
		-- so just catch the error it throws with pcall instead.
		local result,value = pcall(self.topActor.playcommand, self.topActor, "TopPressed" , {input = self.topInput})
		-- self.topActor:playcommand("TopPressed", {input = self.topInput}) 

		-- Reset the top actor if there's an error
		if not result then
			self:resetPressedActors()
		end
	end
end


--Gets the true X/Y Position by recursively grabbing the parents' position.
--Does not take zoom into account.
function Actor.getTrueX(self)
	if self == nil then
		return 0
	end

	local parent = self:GetParent()

	if parent == nil then
		return self:GetX() or 0
	else
		return self:GetX() + parent:getTrueX()
	end
end

function Actor.getTrueY(self)
	if self == nil then
		return 0
	end

	local parent = self:GetParent()

	if parent == nil then
		return self:GetY() or 0
	else
		return self:GetY() + parent:getTrueY()
	end
end

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
end



-- Basic clickable button implementation with quads
function quadButton(z)
	local topName 

	local t = Def.Quad{
		InitCommand= function(self) 
			self:z(z)
		end,

		OnCommand = function(self)
			local top = SCREENMAN:GetTopScreen()
			topName = top:GetName()
		end,

		MouseLeftClickMessageCommand = function(self)
			if self:isOver() then
				BUTTON:addPressedActors(self, topName, "DeviceButton_left mouse button")
			end
		end,
		MouseRightClickMessageCommand = function(self)
			if self:isOver() then
				BUTTON:addPressedActors(self, topName, "DeviceButton_right mouse button")
			end
		end,
		TopPressedCommand = function(self)
		end,
	}

	return t
end


-- Checkboxes
function checkbox(z, checked)

	local zoom = 0.15
	local checked = checked

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:playcommand("Toggle")
		end,
		ToggleCommand = function(self)
			if checked then 
				checked = false
				self:playcommand("Uncheck")
				self:RunCommandsOnChildren(function(self) self:playcommand("Uncheck") end)
			else
				checked = true
				self:playcommand("Check")
				self:RunCommandsOnChildren(function(self) self:playcommand("Check") end)
			end
		end,
		CheckCommand = function(self)
		end,

		UncheckCommand = function(self)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(zoom*100,zoom*100)
			self:diffuse(color("#000000")):diffusealpha(0.8)
		end
	}

	t[#t+1] = quadButton(z) .. {
		InitCommand = function(self)
			self:zoomto(zoom*100,zoom*100)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
		end,
		TopPressedCommand = function(self, params)
			if params.input == "DeviceButton_left mouse button" then
				self:GetParent():playcommand("Toggle")
				self:finishtweening()
				self:diffusealpha(0.2)
				self:smooth(0.3)
				self:diffusealpha(0)
			end
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "_x"))..{
		InitCommand = function(self)
			self:zoom(zoom)
		end,
		CheckCommand = function(self)
			self:finishtweening()
			self:smooth(0.1)
			self:zoom(zoom)
			self:diffusealpha(1)
		end,
		UncheckCommand = function(self)
			self:finishtweening()
			self:smooth(0.1)
			self:zoom(0)
			self:diffusealpha(0)
		end
	}

	return t
end