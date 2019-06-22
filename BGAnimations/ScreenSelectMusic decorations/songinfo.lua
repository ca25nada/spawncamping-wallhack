local topScreen
local song
local group
local wheel


local t = Def.ActorFrame{
	InitCommand = function(self) 
		self:delayedFadeIn(4)
	end,
	OffCommand = function(self)
		self:stoptweening()
		self:smooth(0.2)
		self:diffusealpha(0)
	end,
	OnCommand = function(self) 
		topScreen = SCREENMAN:GetTopScreen()
		song = GAMESTATE:GetCurrentSong()
		if topScreen then
			wheel = topScreen:GetMusicWheel()
		end
		self:playcommand("Set")
	end,
	SetCommand = function(self)
		song = GAMESTATE:GetCurrentSong()
		group = wheel:GetSelectedSection()
		GHETTOGAMESTATE:setLastSelectedFolder(group)

		self:GetChild("Banner"):playcommand("Set")
		self:GetChild("CDTitle"):playcommand("Set")
		self:GetChild("songTitle"):playcommand("Set")
		self:GetChild("songLength"):playcommand("Set")
	end,
	PlayerJoinedMessageCommand = function(self) self:queuecommand("Set") end,
	CurrentSongChangedMessageCommand = function(self) self:queuecommand("Set") end,
	DisplayLanguageChangedMessageCommand = function(self) self:queuecommand("Set") end
}

-- The frame around the banner
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
		self:zoomto(capWideScale(get43size(384),384)+10,capWideScale(get43size(120),120)+50)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)		
	end
}

-- This makes the banner a button to access song info
t[#t+1] = quadButton(1)..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
		self:zoomto(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
		self:visible(false)
	end,
	MouseDownCommand = function(self, params)
		if params.button ~= "DeviceButton_left mouse button" then
			return
		end
		if song ~= nil then 
			SCREENMAN:AddNewScreenToTop("ScreenMusicInfo")

		elseif group ~= nil and GAMESTATE:GetSortOrder() == "SortOrder_Group" then
			SCREENMAN:AddNewScreenToTop("ScreenGroupInfo")
		end

	end
}

-- Song banner
t[#t+1] = Def.Sprite {
	Name = "Banner",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
	end,
	SetCommand = function(self)
		if topScreen:GetName() == "ScreenSelectMusic" or topScreen:GetName() == "ScreenNetSelectMusic" then
			local bnpath = nil
			if song then
				bnpath = song:GetBannerPath()
			elseif group then
				bnpath = SONGMAN:GetSongGroupBannerPath(group)
			end
			if not bnpath or bnpath == "" then
				bnpath = THEME:GetPathG("Common", "fallback banner")
			end
			self:LoadBackground(bnpath)
			self:scaletoclipped(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
		end
	end
}

-- The CD title
t[#t+1] = Def.Sprite {
	Name = "CDTitle",
	InitCommand = function(self)
		self:x(SCREEN_CENTER_X/2+(capWideScale(get43size(384),384)/2)+40)
		self:y(120-(capWideScale(get43size(120),120)/2)+30)
		self:wag():effectmagnitude(0,0,5)
		self:diffusealpha(0.8)
	end,
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
		end
		self:playcommand("AdjustSize")
		self:smooth(0.5)
		self:diffusealpha(1)
	end,
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
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:finishtweening()
		self:smooth(0.5)
		self:diffusealpha(0)
	end
}

-- Label for how many stages we have played
t[#t+1] = LoadFont("Common Bold") .. {
	Name="curStage",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5,120-12-capWideScale(get43size(60),60))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
	end,
	SetCommand = function(self)
		self:settextf("%s Stage",FormatNumberAndSuffix(GAMESTATE:GetCurrentStageIndex()+1))
	end
}

-- Song title // Artist on top of the banner
t[#t+1] = LoadFont("Common Bold") .. {
	Name="songTitle",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5,132+capWideScale(get43size(60),60))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
	end,
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



-- Song length
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songLength",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2-5,132+capWideScale(get43size(60),60))
		self:halign(1)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)	
	end,	
	SetCommand = function(self)
		local length = 0
		if song then
			length = song:GetStepsSeconds()/getCurRateValue()
		end
		self:settextf("%s",SecondsToMSS(length))
		self:diffuse(getSongLengthColor(length))
	end,
	CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end
}

-- Gradient over banner when rate is not 1.0
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2,120+capWideScale(get43size(60),60))
		self:zoomto(capWideScale(get43size(384),384),40)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.6)
		self:halign(1)
		self:valign(1)
		self:fadetop(1)
	end,
	SetCommand = function(self)
		if getCurRateValue() == 1 then
			self:stoptweening()
			self:smooth(0.2)
			self:diffusealpha(0)
		else
			self:stoptweening()
			self:smooth(0.2)
			self:diffusealpha(0.6)
		end
	end,
	CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end
}

-- Rate text
t[#t+1] = LoadFont("Common Bold") .. {
	Name="songTitle",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2-5,110+capWideScale(get43size(60),60))
		self:halign(1)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
	end,
	SetCommand = function(self)
		if getCurRateValue() == 1 then
			self:settext("")
		else
			self:settext(getCurRateDisplayString())
		end
	end,
	CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end
}


return t