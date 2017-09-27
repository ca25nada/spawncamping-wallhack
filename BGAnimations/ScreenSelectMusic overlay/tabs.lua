local function input(event)

	if event.type == "InputEventType_FirstPress" then
		
		for i=1,getTabSize() do
			if event.DeviceInput.button == "DeviceButton_"..i then
				setTabIndex(i)
			end
		end

		if event.button == "EffectUp" then
			changeMusicRate(0.05)
		end

		if event.button == "EffectDown" then
			changeMusicRate(-0.05)
		end

	end

return false

end

local top
local t = Def.ActorFrame{
	BeginCommand=function(self) resetTabIndex() end;
	PlayerJoinedMessageCommand=function(self) resetTabIndex() end;
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
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

function tabs(index)
	local t = Def.ActorFrame{
		Name="Tab"..index;
		InitCommand=cmd(xy,frameX+((index-1)*frameWidth),frameY;);
		SetCommand = function(self)
			self:finishtweening()
			self:linear(0.1)
			--show tab if it's the currently selected one
			if getTabIndex() == index then
				self:y(frameY)
				self:diffusealpha(1)
			else -- otherwise "Hide" them
				self:y(frameY)
				self:diffusealpha(0.5)
			end;
		end;
		BeginCommand = function(self) self:queuecommand("Set") end;
		TabChangedMessageCommand = function(self) self:queuecommand("Set") end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand("Set") end;
	}

	t[#t+1] = quadButton(3)..{
		Name="TabBG";
		InitCommand=cmd(valign,1;zoomto,frameWidth,20;diffusealpha,0.5);
		TopPressedCommand = function(self, params)
			if params.input == "DeviceButton_left mouse button" then
				setTabIndex(index)
			end
		end;
		SetCommand = function(self)
			self:finishtweening()
			self:linear(0.1)
			--show tab if it's the currently selected one
			if getTabIndex() == index then
				self:diffuse(color("#111111"))
			else
				self:diffuse(color("#333333"))
			end;
		end;
		BeginCommand = function(self) self:queuecommand("Set") end;
		TabChangedMessageCommand = function(self) self:queuecommand("Set") end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand("Set") end;
	};
		
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(y,-5;valign,1;zoom,0.4;);
		SetCommand=function(self)
			self:settext(getTabName(index))
			if isTabEnabled(index) then
				self:diffuse(color("#FFFFFF"))
			else
				self:diffuse(getMainColor('disabled'))
			end;
		end;
		BeginCommand = function(self) self:queuecommand("Set") end;
		TabChangedMessageCommand = function(self) self:queuecommand("Set") end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand("Set") end;
	};
	return t
end;

for i=1,getTabSize() do
	t[#t+1] =tabs(i)
end;

return t