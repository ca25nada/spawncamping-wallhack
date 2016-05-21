local t = Def.ActorFrame{}
local height = 20

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,0)
		self:valign(0)
		self:zoomto(SCREEN_WIDTH,height)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
	OnCommand = function(self)
		self:zoomy(0)
		self:smooth(0.5)
		self:zoomy(height)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:zoomy(0)
	end;
}

t[#t+1] = LoadFont("Common Normal")..{
	Name = "HeaderTitle";
	Text = Screen.String("HeaderText");
	InitCommand = function (self)
		self:diffuse(color("#FFFFFF"))
		self:zoom(0.5)
		self:halign(0)
		self:xy(10,height/2)
	end;
	OnCommand = function(self)
		self:y(-height/2)
		self:smooth(0.5)
		self:y(height/2)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-height/2)
	end;
	UpdateScreenHeaderMessageCommand = function(self,param)
		self:settext(param.Header)
	end;
};

return t