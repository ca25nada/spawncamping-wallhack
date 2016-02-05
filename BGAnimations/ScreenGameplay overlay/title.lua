local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y+7;zoomto,256,30;diffuse,getDifficultyColor(GAMESTATE:GetHardestStepsDifficulty());diffusealpha,0.8;fadeleft,0.2;faderight,0.2;diffusealpha,0);
	OnCommand=cmd(smooth,0.5;diffusealpha,0.7;);
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:addy(-40)
		self:diffusealpha(0)
	end
};

t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y;zoom,0.35;diffusealpha,0;maxwidth,256/0.35);
	BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayMainTitle(););
	OnCommand=cmd(smooth,0.5;diffusealpha,1;);
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:addy(-40)
		self:diffusealpha(0)
	end
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y+15;zoom,0.4;;diffusealpha,0;maxwidth,256/0.4);
	BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayArtist());
	OnCommand=cmd(smooth,0.5;diffusealpha,1;);
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:addy(-40)
		self:diffusealpha(0)
	end
};

t[#t+1] = Def.Banner{
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y-50;);
	OnCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song then
			self:LoadFromSong(song)
		end
		self:diffusealpha(0)
		self:smooth(0.5)
		self:diffusealpha(1)
		self:scaletoclipped(capWideScale(get43size(256),256),capWideScale(get43size(80),80))
	end;
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:addy(40)
		self:diffusealpha(0)
	end
};


return t