--Banner and song info that shows before the gameplay starts.
--SongStartingMessageCommand is sent from progressbar.lua

local bannerWidth = 256
local bannerHeight = 80
local borderWidth = 5

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
		self:diffusealpha(0)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:easeOut(1)
		self:diffusealpha(0.8)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-30)
	end;
	SongStartingMessageCommand = function(self)
		self:stoptweening()
		self:bouncyOut(0.7)
		self:zoomy(0.5):zoomx(0.5)
		self:diffusealpha(0)
	end
}


t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(15)
		self:zoomto(bannerWidth+borderWidth*2+8,bannerHeight+borderWidth*2+38)
		self:diffuse(color("#000000"))
		self:diffusealpha(0)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:diffuse(getDifficultyColor(GAMESTATE:GetHardestStepsDifficulty()))
	end;
};

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(15)
		self:zoomto(bannerWidth+borderWidth*2,bannerHeight+borderWidth*2+30)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end;
}

t[#t+1] = Def.Banner{
	CurrentSongChangedMessageCommand = function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song then
			self:LoadFromSong(song)
		end
		self:scaletoclipped(bannerWidth,bannerHeight)
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:y(50)
		self:zoom(0.6)
		self:diffusealpha(1)
		self:maxwidth(bannerWidth/0.6)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:y(65)
		self:zoom(0.4)
		self:diffusealpha(1)
		self:maxwidth(bannerWidth/0.4)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist())
	end;
}


return t