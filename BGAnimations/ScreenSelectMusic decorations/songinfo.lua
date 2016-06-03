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
		self:xy(SCREEN_CENTER_X/2,120)
		self:zoomto(capWideScale(get43size(384),384)+10,capWideScale(get43size(120),120)+50)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)		
	end
}

-- Song banner
t[#t+1] = Def.Banner{
	InitCommand=cmd(xy,SCREEN_CENTER_X/2,120;);
	SetMessageCommand=function(self)
		if update then
			local top = SCREENMAN:GetTopScreen()
			if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" then
				self:stoptweening()
				self:sleep(0.5)
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

t[#t+1] = Def.Sprite {
	InitCommand = function(self)
		self:x(SCREEN_CENTER_X/2+(capWideScale(get43size(384),384)/2)-40)
		self:y(120-(capWideScale(get43size(120),120)/2)+30)
		self:wag():effectmagnitude(0,0,5)
	end;
	Name="CDTitle";
	SetCommand=function(self)
		if update then
			self:finishtweening()
			self:sleep(0.5)
			local song = GAMESTATE:GetCurrentSong()	
			if song then
				if song:HasCDTitle() then
					self:visible(true)
					self:Load(song:GetCDTitlePath())
				else
					self:visible(false)
				end
			else
				self:visible(false)
			end;
			local height = self:GetHeight()
			local width = self:GetWidth()
			
			if height >= 60 and width >= 80 then
				if height*(80/60) >= width then
					self:zoom(60/height)
				else
					self:zoom(80/width)
				end
			elseif height >= 60 then
				self:zoom(60/height)
			elseif width >= 80 then
				self:zoom(80/width)
			else
				self:zoom(1)
			end
			self:smooth(0.5)
			self:diffusealpha(0.8)
		end
	end;
	BeginCommand=cmd(queuecommand,"Set");
	CurrentSongChangedMessageCommand=cmd(finishtweening;smooth,0.5;diffusealpha,0;queuecommand,"Set");
};

-- Song title // Artist on top of the banner
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5,132+capWideScale(get43size(60),60))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
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
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2-5,132+capWideScale(get43size(60),60))
		self:halign(1)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)	
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