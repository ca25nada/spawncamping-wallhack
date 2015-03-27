local t = Def.ActorFrame{};

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand=cmd(xy,10,200;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
		self:diffuse(getMainColor(1))
	end;
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song ~= nil then
			self:settext(song:GetDisplayFullTitle())
		else
			self:settext("")
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songArtist";
	InitCommand=cmd(xy,10,210;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
		self:diffuse(getMainColor(1))
	end;
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song ~= nil then
			self:settext(song:GetDisplayArtist())
		else
			self:settext("")
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};



t[#t+1] = LoadFont("Common Normal") .. {
	Name="songGroup";
	InitCommand=cmd(xy,10,220;visible,true;halign,0;zoom,0.45);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
		self:diffuse(getMainColor(1))
	end;
	SetCommand=function(self)
		local diff = GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty()
		local meter = GAMESTATE:GetCurrentSteps(PLAYER_1):GetMeter()
		if diff ~= nil and meter ~= nil then
			self:settext(tostring(diff)..tostring(meter))
		else
			self:settext("")
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
};


return t