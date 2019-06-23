local function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end
		if tonumber(event.char) == 1 then
			SCREENMAN:AddNewScreenToTop("ScreenGoalManager")
		elseif tonumber(event.char) == 2 then
			SCREENMAN:AddNewScreenToTop("ScreenAssetSettings")
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
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
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

t[#t+1] = LoadActor("../_mouse", "ScreenPlayerProfile")

t[#t+1] = LoadActor("../_frame")

local tab = TAB:new({"Goals", "Assets"})
t[#t+1] = tab:makeTabActors() .. {
	OnCommand = function(self)
		if IsNetSMOnline() and IsSMOnlineLoggedIn(PLAYER_1) and NSMAN:IsETTP() then
			self:y(SCREEN_HEIGHT+tab.height/2 - 17)
			self:easeOut(0.5)
			self:y(SCREEN_HEIGHT-tab.height/2 - 17)
		else
			self:y(SCREEN_HEIGHT+tab.height/2)
			self:easeOut(0.5)
			self:y(SCREEN_HEIGHT-tab.height/2)
		end
	end,
	OffCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
	end,
	TabPressedMessageCommand = function(self, params)
		if params.name == "Goals" then
			SCREENMAN:AddNewScreenToTop("ScreenGoalManager")
		elseif params.name == "Assets" then
			SCREENMAN:AddNewScreenToTop("ScreenAssetSettings")
		end
	end
}

t[#t+1] = LoadActor("../_cursor")

return t
