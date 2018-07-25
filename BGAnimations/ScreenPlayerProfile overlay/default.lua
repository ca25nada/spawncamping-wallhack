

local function input(event)
	if event.type == "InputEventType_Release" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end
	end

	return false

end

local top

local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
	end;
}

t[#t+1] = LoadActor("../_mouse")

t[#t+1] = LoadActor("../_frame")

local tab = TAB:new({"Scores", "Stats", "Other"})
t[#t+1] = tab:makeTabActors() .. {
	OnCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
		self:easeOut(0.5)
		self:y(SCREEN_HEIGHT-tab.height/2)
	end;
	OffCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
	end;
	TabPressedMessageCommand = function(self, params)
	end
}

t[#t+1] = LoadActor("../_cursor")

return t
