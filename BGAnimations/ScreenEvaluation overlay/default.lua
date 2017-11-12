local t = Def.ActorFrame{}
t[#t+1] = LoadActor("../_frame");
t[#t+1] = LoadActor("../_mouse");

local curTab = 1
local function input(event)
	if event.type == "InputEventType_FirstPress" then
		-- For swapping back and forth between scoreboard and offset display.
		for i=1,2 do
			if event.DeviceInput.button == "DeviceButton_"..i then
				if i ~= curTab then
					curTab = i
					MESSAGEMAN:Broadcast("TabChanged",{index = i})
					SOUND:PlayOnce(THEME:GetPathS("","whoosh"),true)
				end
			end
		end

	end
	return false
end


--Group folder name
local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH-10
local frameY = 10

t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end;
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end;
	Def.Quad{
		InitCommand=function(self)
			self:halign(1):zoomto(frameWidth,frameHeight):diffuse(getMainColor('highlight')):diffusealpha(0.8)
		end;
	};
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:x(-frameWidth+5):halign(0):zoom(0.45):maxwidth((frameWidth-10)/0.45)
		end;
		BeginCommand=function(self)
			self:diffuse(color(colorConfig:get_data().main.headerFrameText))
			local song = GAMESTATE:GetCurrentSong()
			if song ~= nil then
				self:settext(song:GetGroupName())
			end;
		end;
	};
}

t[#t+1] = LoadActor("../_cursor");

return t