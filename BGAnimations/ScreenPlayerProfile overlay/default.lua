local function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end
		if tonumber(event.char) == 1 then
			SCREENMAN:AddNewScreenToTop("ScreenGoalManager")
		end
	end

	return false

end

local top
local sentSong

local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
	end,
	TriggerExitFromPSMessageCommand = function(self, params)
		self:sleep(0.05)
		sentSong = params.song
		self:queuecommand("DelayedExitPS")
	end,
	DelayedExitPSCommand = function(self)
		SCREENMAN:GetTopScreen():Cancel()
		MESSAGEMAN:Broadcast("MoveMusicWheelToSong",{song = sentSong})
	end
}

t[#t+1] = LoadActor("../_mouse")

t[#t+1] = LoadActor("../_frame")

local tab = TAB:new({"Goals", "", ""})
t[#t+1] = tab:makeTabActors() .. {
	OnCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
		self:easeOut(0.5)
		self:y(SCREEN_HEIGHT-tab.height/2)
	end,
	OffCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
	end,
	TabPressedMessageCommand = function(self, params)
		if params.name == "Goals" then
			SCREENMAN:AddNewScreenToTop("ScreenGoalManager")
		end
	end
}

t[#t+1] = LoadActor("../_cursor")

return t
