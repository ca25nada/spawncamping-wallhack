local t = Def.ActorFrame{}
t[#t+1] = LoadActor("../_frame");

--what the settext says
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function (self)
		self:diffuse(color("#FFFFFF"))
		self:zoom(0.5)
		self:halign(0)
		self:xy(10,10)
		self:settext("Results")
	end;
	OnCommand = function(self)
		self:y(-10)
		self:smooth(0.5)
		self:y(10)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-10)
	end;
};


--Group folder name
local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH
local frameY = 10

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;halign,1;zoomto,frameWidth,frameHeight;diffuse,getMainColor('highlight'););
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,frameX-frameWidth+5,frameY;halign,0;zoom,0.45;maxwidth,(frameWidth-10)/0.45);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		local course = GAMESTATE:GetCurrentCourse()
		if song ~= nil and (not GAMESTATE:IsCourseMode()) then
			self:settext(song:GetGroupName())
		end;
		if course ~= nil and GAMESTATE:IsCourseMode() then
			self:settext(course:GetGroupName())
		end;
	end;
};

t[#t+1] = LoadActor("../_cursor");

return t