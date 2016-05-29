local t = Def.ActorFrame{}
t[#t+1] = LoadActor("../_frame");

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
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end;
	Def.Quad{
		InitCommand=cmd(halign,1;zoomto,frameWidth,frameHeight;diffuse,getMainColor('highlight');diffusealpha,0.8);
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(x,-frameWidth+5;halign,0;zoom,0.45;maxwidth,(frameWidth-10)/0.45);
		BeginCommand=function(self)
			self:diffuse(color(colorConfig:get_data().main.headerFrameText))
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
}

t[#t+1] = LoadActor("../_cursor");

return t