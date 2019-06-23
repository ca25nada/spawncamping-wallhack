local t = Def.ActorFrame{}
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)
local steps = GAMESTATE:GetCurrentSteps(pn)


t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_mouse", "ScreenEvaluation")

--Group folder name
local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH-10
local frameY = 10

t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end,
	OnCommand = function(self)
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
	end,
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end,
	Def.Quad{
		InitCommand=function(self)
			self:halign(1):zoomto(frameWidth,frameHeight):diffuse(getMainColor('highlight')):diffusealpha(0.8)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:x(-frameWidth+5):halign(0):zoom(0.45):maxwidth((frameWidth-10)/0.45)
		end,
		BeginCommand=function(self)
			self:diffuse(color(colorConfig:get_data().main.headerFrameText))
			local song = GAMESTATE:GetCurrentSong()
			if song ~= nil then
				self:settext(song:GetGroupName())
			end
		end
	}
}

t[#t+1] = LoadActor("../_cursor")



local largeImageText = string.format("%s: %5.2f",profile:GetDisplayName(), profile:GetPlayerRating())

-- Max 64 for title, 32 for artist.
local title = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
title = #title < 64 and title or string.format("%s...", string.sub(title, 1, 60))

local artist = GAMESTATE:GetCurrentSong():GetDisplayArtist()
artist = #artist < 32 and artist or string.format("%s...", string.sub(artist, 1, 28))

local detail = string.format("Results: %s - %s (%s)", artist, title, string.gsub(getCurRateDisplayString(), "Music", ""))

local difficulty = getDifficulty(steps:GetDifficulty())
local stepsType = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
local MSD = steps:GetMSD(getCurRateValue(),1)
MSDString = MSD > 0 and string.format("(%5.2f)", MSD) or "(Unranked)"

local state = string.format("%s %s %s",stepsType, difficulty, MSDString)

GAMESTATE:UpdateDiscordPresence(largeImageText, detail, state, 0)


return t