local t = Def.ActorFrame{};

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand=cmd(xy,100,200;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
	end;
	SetCommand=function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayFullTitle())
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songArtist";
	InitCommand=cmd(xy,100,210;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
	end;
	SetCommand=function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist())
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songGroup";
	InitCommand=cmd(xy,100,190;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
	end;
	SetCommand=function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetGroupName())
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};


t[#t+1] = LoadFont("Common Normal") .. {
	Name="songGroup";
	InitCommand=cmd(xy,100,220;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
	end;
	SetCommand=function(self)
		self:settext(tostring(GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty())..tostring(GAMESTATE:GetCurrentSteps(PLAYER_1):GetMeter()))
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
};


return t