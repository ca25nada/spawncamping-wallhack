local update = false -- don't update if not visible on screen.
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0);
	OnCommand=cmd(bouncebegin,0.2;xy,0,0);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:queuecommand("On");
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	TabChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,55)
		self:valign(0)
		self:zoomto(capWideScale(get43size(384),384)+10,capWideScale(get43size(120),120)+30)
		self:diffuse(color("#000000"))
		self:diffusealpha(0.8)		
	end
}

-- Song banner
t[#t+1] = Def.Banner{
	InitCommand=cmd(x,SCREEN_CENTER_X/2;y,60;valign,0);
	SetMessageCommand=function(self)
		if update then
			local top = SCREENMAN:GetTopScreen()
			if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" then
				local song = GAMESTATE:GetCurrentSong()
				local course = GAMESTATE:GetCurrentCourse()
				local group = top:GetMusicWheel():GetSelectedSection()
				if song then
					self:LoadFromSong(song)
				elseif course then
					self:LoadFromCourse(song)
				elseif group then
					self:LoadFromSongGroup(group)
				end;
			end;
		end;
		self:scaletoclipped(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};

-- Song title // Artist on top of the banner
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5, 72+capWideScale(get43size(120),120))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffusealpha(0.8)		
	end;
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if update then
			local song = GAMESTATE:GetCurrentSong()
			if song ~= nil then
				self:settext(song:GetDisplayMainTitle().." // "..song:GetDisplayArtist())
			else
				self:settext("")
			end
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};

-- Song length (todo: take rates into account..?)
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songLength";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2-5, 72+capWideScale(get43size(120),120))
		self:halign(1)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffusealpha(0.8)		
	end;	
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if update then
			local song = GAMESTATE:GetCurrentSong()
			local seconds = 0
			if song ~= nil then
				seconds = song:GetStepsSeconds()
				self:settext(SecondsToMSS(seconds))
				self:diffuse(getSongLengthColor(seconds))
			else
				self:settext("")
			end
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};


return t