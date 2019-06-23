
local height = 20
local top

local t = Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
	end
}

t[#t+1] = quadButton(3)..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,0)
		self:valign(0)
		self:zoomto(SCREEN_WIDTH,height)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end,
	OnCommand = function(self)
		self:zoomy(0)
		self:easeOut(0.5)
		self:zoomy(height)
	end,
	OffCommand = function(self)
		self:easeOut(0.5)
		self:zoomy(0)
	end
}

t[#t+1] = quadButton(4)..{
	InitCommand = function(self)
		self:xy(0,0)
		self:valign(0):halign(0)
		self:zoomto(30,height)
		self:diffuse(getMainColor("frame")):diffusealpha(0.3)
	end,
	OnCommand = function(self)
		self:zoomy(0)
		self:easeOut(0.5)
		self:zoomy(height)
	end,
	OffCommand = function(self)
		self:easeOut(0.5)
		self:zoomy(0)
	end,
	MouseDownCommand = function(self, params)
		MESSAGEMAN:Broadcast("ExitScreen",{screen = top:GetName()})
	end
}

t[#t+1] = LoadFont("Common Bold")..{
	Name = "HeaderTitle",
	Text = Screen.String("HeaderText"),
	InitCommand = function (self)
		self:diffuse(color(colorConfig:get_data().main.headerText))
		self:zoom(0.3)
		self:xy(15,height/2)
		self:settext("Back")
	end,
	OnCommand = function(self)
		self:y(-height/2)
		self:easeOut(0.5)
		self:y(height/2)
	end,
	OffCommand = function(self)
		self:easeOut(0.5)
		self:y(-height/2)
	end
}

t[#t+1] = LoadFont("Common Bold")..{
	Name = "HeaderTitle",
	Text = Screen.String("HeaderText"),
	InitCommand = function (self)
		self:diffuse(color(colorConfig:get_data().main.headerText))
		self:zoom(0.5)
		self:halign(0)
		self:xy(35,height/2)
	end,
	OnCommand = function(self)
		self:y(-height/2)
		self:easeOut(0.5)
		self:y(height/2)
	end,
	OffCommand = function(self)
		self:easeOut(0.5)
		self:y(-height/2)
	end,
	UpdateScreenHeaderMessageCommand = function(self,param)
		self:settext(param.Header)
	end
}

return t