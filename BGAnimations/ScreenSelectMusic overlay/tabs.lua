local function input(event)

	if event.type == "InputEventType_FirstPress" then

		if event.button == "EffectUp" then
			changeMusicRate(0.05)
		end

		if event.button == "EffectDown" then
			changeMusicRate(-0.05)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			wheel:Move(-1)
			wheel:Move(0)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			wheel:Move(1)
			wheel:Move(0)
		end

		if event.DeviceInput.button == "DeviceButton_middle mouse button" then
			lastY = INPUTFILTER:GetMouseY()
		end

	end

	if event.type == "InputEventType_Repeat" then
		if event.DeviceInput.button == "DeviceButton_middle mouse button" then
			curY = INPUTFILTER:GetMouseY()
			if curY-lastY > 0 then
				wheel:Move(math.floor((curY-lastY)/50))
			elseif curY-lastY < 0 then
				wheel:Move(math.ceil((curY-lastY)/50))
			end
			wheel:Move(0)
		end
	end

	return false

end

local lastY
local curY

local top
local wheel
local t = Def.ActorFrame{
	BeginCommand=function(self) resetTabIndex() end;
	PlayerJoinedMessageCommand=function(self) resetTabIndex() end;
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
		top:AddInputCallback(input)
		self:diffusealpha(0)
		self:smooth(0.5)
		self:diffusealpha(1)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:diffusealpha(0)
	end;
}

t[#t+1] = LoadActor("../_mouse")

local frameWidth = (SCREEN_WIDTH*(403/854))/(getTabSize()-1)
local frameX = frameWidth/2
local frameY = SCREEN_HEIGHT

local tab = TAB:new({"Profile", "Simfile", "Playlist", "Downloads", "Other"})
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
		if params.name == "Profile" then
			SCREENMAN:AddNewScreenToTop("ScreenPlayerProfile")
		elseif params.name == "Simfile" then
			SCREENMAN:AddNewScreenToTop("ScreenMusicInfo")
		end
	end
}

return t