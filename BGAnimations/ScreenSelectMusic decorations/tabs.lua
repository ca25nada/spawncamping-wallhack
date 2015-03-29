local t = Def.ActorFrame{}

t[#t+1] = Def.Actor{
	BeginCommand=function(self)
		resetTabIndex()
	end;
	CodeMessageCommand=function(self,params)
		if params.Name == "SwitchTab" then
			incrementTabIndex()
		end;
	end;

}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,300,300;halign,0;zoom,2;diffuse,getMainColor(2));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext(getTabIndex())
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

tabNames = {
	[1] = "General"
	[2] = "Score"
	[3] = "Simfile"
	[4] = "Profile"
}

local FrameX = 50
local FrameY = SCREEN_HEIGHT-70

t[#t+1] = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:finishtweening()
		self:linear(0.1)
		if getTabIndex() == 0 then
			self:y(0)
			self:diffusealpha(2)
		else
			self:y(5)
			self:diffusealpha(0.9)
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
	Def.Quad{
		InitCommand=cmd(xy,50,SCREEN_HEIGHT-70;valign,0;zoomto,100,20);
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,50,SCREEN_HEIGHT-66;valign,0;zoom,0.45;diffuse,getMainColor(1));
		BeginCommand=cmd(settext,"General Info");
	};
};

t[#t+1] = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:finishtweening()
		self:linear(0.1)
		if getTabIndex() == 1 then
			self:y(0)
			self:diffusealpha(2)
		else
			self:y(5)
			self:diffusealpha(0.9)
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
	Def.Quad{
		InitCommand=cmd(xy,150,SCREEN_HEIGHT-70;valign,0;zoomto,100,20);
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,150,SCREEN_HEIGHT-66;valign,0;zoom,0.45;diffuse,getMainColor(1));
		BeginCommand=cmd(settext,"Score Info");
	};
};

t[#t+1] = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:finishtweening()
		self:linear(0.1)
		if getTabIndex() == 2 then
			self:y(0)
			self:diffusealpha(2)
		else
			self:y(5)
			self:diffusealpha(0.9)
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
	Def.Quad{
		InitCommand=cmd(xy,250,SCREEN_HEIGHT-70;valign,0;zoomto,100,20);
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,250,SCREEN_HEIGHT-66;valign,0;zoom,0.45;diffuse,getMainColor(1));
		BeginCommand=cmd(settext,"Simfile Info");
	};
};

t[#t+1] = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:finishtweening()
		self:linear(0.1)
		if getTabIndex() == 3 then
			self:y(0)
			self:diffusealpha(2)
		else
			self:y(5)
			self:diffusealpha(0.9)
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
	Def.Quad{
		InitCommand=cmd(xy,350,SCREEN_HEIGHT-70;valign,0;zoomto,100,20);
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,350,SCREEN_HEIGHT-66;valign,0;zoom,0.45;diffuse,getMainColor(1));
		BeginCommand=cmd(settext,"Profile Info");
	};
};

return t