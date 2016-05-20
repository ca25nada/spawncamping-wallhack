--Banner and song info that shows before the gameplay starts.
--SongStartingMessageCommand is sent from progressbar.lua

local bannerWidth = 256
local bannerHeight = 80
local borderWidth = 5

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-30)
	end
}


t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(15)
		self:zoomto(bannerWidth+borderWidth*2+8,bannerHeight+borderWidth*2+38)
		self:diffuse(color("#000000"))
		self:diffusealpha(0)
	end;
	SetCommand = function(self)
		self:smooth(0.5)
		self:diffuse(getDifficultyColor(GAMESTATE:GetHardestStepsDifficulty()))
		self:diffusealpha(0.3)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand('Init')
		self:queuecommand('Set')
	end;
	SongStartingMessageCommand = function(self)
		self:smooth(0.3)
		self:zoomy(0.5)
		self:diffusealpha(0)
	end
};

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(15)
		self:zoomto(bannerWidth+borderWidth*2,bannerHeight+borderWidth*2+30)
		self:diffuse(color("#000000"))
		self:diffusealpha(0)
	end;
	SetCommand = function(self)
		self:smooth(0.5)
		self:diffusealpha(0.8)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand('Init')
		self:queuecommand('Set')
	end;
	SongStartingMessageCommand = function(self)
		self:smooth(0.3)
		self:zoomy(0.5)
		self:diffusealpha(0)
	end
}

t[#t+1] = Def.Banner{
	InitCommand = function(self)
		self:diffusealpha(0)
	end;
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song then
			self:LoadFromSong(song)
		end
		self:smooth(0.5)
		self:diffusealpha(0.8)
		self:scaletoclipped(bannerWidth,bannerHeight)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand('Init')
		self:queuecommand('Set')
	end;
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:zoomy(0.5)
		self:diffusealpha(0)
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:y(50)
		self:zoom(0.6)
		self:diffusealpha(0)
		self:maxwidth(bannerWidth/0.6)
	end;
	SetCommand = function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
		self:smooth(0.5)
		self:diffusealpha(1)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand('Init')
		self:queuecommand('Set')
	end;
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:addy(-40)
		self:diffusealpha(0)
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:y(65)
		self:zoom(0.4)
		self:diffusealpha(0)
		self:maxwidth(bannerWidth/0.4)
	end;
	SetCommand = function(self)
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist())
		self:smooth(0.5)
		self:diffusealpha(1)
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand('Init')
		self:queuecommand('Set')
	end;
	SongStartingMessageCommand=function(self)
		self:smooth(0.3)
		self:addy(-40)
		self:diffusealpha(0)
	end
}


return t