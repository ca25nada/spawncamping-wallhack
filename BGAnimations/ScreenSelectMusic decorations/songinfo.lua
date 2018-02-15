local topScreen
local song
local group
local wheel


local t = Def.ActorFrame{
	BeginCommand = function(self)
		self:queuecommand("Set")
	end;
	InitCommand = function(self) self:xy(0,-100):diffusealpha(0) end;
	OffCommand = function(self) self:finishtweening() self:bouncy(0.3) self:xy(0,-100):diffusealpha(0) end;
	OnCommand = function(self) 
		self:bouncy(0.3)
		self:xy(0,0):diffusealpha(1)
		topScreen = SCREENMAN:GetTopScreen()
		song = GAMESTATE:GetCurrentSong()
		if topScreen then
			wheel = topScreen:GetMusicWheel()
		end
	end;
	SetCommand = function(self)
		song = GAMESTATE:GetCurrentSong()
		group = wheel:GetSelectedSection()
		GHETTOGAMESTATE:setLastSelectedFolder(group)

		self:GetChild("Banner"):queuecommand("Set")
		self:GetChild("CDTitle"):queuecommand("Set")
		self:GetChild("songTitle"):queuecommand("Set")
		self:GetChild("songLength"):queuecommand("Set")
	end;
	PlayerJoinedMessageCommand = function(self) self:queuecommand("Set") end;
	CurrentSongChangedMessageCommand = function(self) self:queuecommand("Set") end;
};

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
		self:zoomto(capWideScale(get43size(384),384)+10,capWideScale(get43size(120),120)+50)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)		
	end
}

t[#t+1] = quadButton(1)..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
		self:zoomto(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
		self:visible(false)
	end;
	TopPressedCommand = function(self, params)
		if params.input == "DeviceButton_left mouse button" then
					
			if song ~= nil then 
				SCREENMAN:AddNewScreenToTop("ScreenMusicInfo")

			elseif group ~= nil and GAMESTATE:GetSortOrder() == "SortOrder_Group" then
				SCREENMAN:AddNewScreenToTop("ScreenGroupInfo")
			end

		end


	end;
}

-- Song banner
t[#t+1] = Def.Banner{
	Name = "Banner";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
	end;
	SetCommand = function(self)
		if topScreen:GetName() == "ScreenSelectMusic" or topScreen:GetName() == "ScreenNetSelectMusic" then
			if song then
				self:LoadFromSong(song)
			elseif group then
				self:LoadFromSongGroup(group)
			end
			self:scaletoclipped(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
		end
	end;
}

t[#t+1] = Def.Sprite {
	Name = "CDTitle";
	InitCommand = function(self)
		self:x(SCREEN_CENTER_X/2+(capWideScale(get43size(384),384)/2)-40)
		self:y(120-(capWideScale(get43size(120),120)/2)+30)
		self:wag():effectmagnitude(0,0,5)
		self:diffusealpha(0.8)
	end;
	SetCommand = function(self)
		self:finishtweening()
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
		self:playcommand("AdjustSize")
		self:smooth(0.5)
		self:diffusealpha(1)
	end;
	AdjustSizeCommand = function(self)
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
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:finishtweening()
		self:smooth(0.5)
		self:diffusealpha(0)
	end
};

t[#t+1] = LoadFont("Common Bold") .. {
	Name="curStage";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5,120-12-capWideScale(get43size(60),60))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
	end;
	SetCommand = function(self)
		if GAMESTATE:IsEventMode() then
			self:settextf("%s Stage",FormatNumberAndSuffix(GAMESTATE:GetCurrentStageIndex()+1))
		else
			if topScreen then
				self:settextf("%s Stage",StageToLocalizedString(GAMESTATE:GetCurrentStage()))
				self:diffuse(StageToColor(GAMESTATE:GetCurrentStage()))
			end
		end
	end
};

-- Song title // Artist on top of the banner
t[#t+1] = LoadFont("Common Bold") .. {
	Name="songTitle";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5,132+capWideScale(get43size(60),60))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
	end;
	SetCommand = function(self)

		if song then
			self:settext(song:GetDisplayMainTitle().." // "..song:GetDisplayArtist())
		else
			if wheel then
				self:settext(wheel:GetSelectedSection())
			end
		end
	end
}



-- Song length (todo: take rates into account..?)
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songLength";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2-5,132+capWideScale(get43size(60),60))
		self:halign(1)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)	
	end;	
	SetCommand = function(self)
		local length = 0
		if song then
			length = song:GetStepsSeconds()/getCurRateValue()
		end
		self:settextf("%s",SecondsToMSS(length))
		self:diffuse(getSongLengthColor(length))
	end;
	CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end;
};


return t