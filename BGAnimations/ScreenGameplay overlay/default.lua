local t = Def.ActorFrame{}
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)
local steps = GAMESTATE:GetCurrentSteps(pn)

t[#t+1] = LoadActor("scoretracking")

t[#t+1] = LoadActor("judgecount")

--t[#t+1] = LoadActor("pacemaker")
t[#t+1] = LoadActor("npscalc")
--t[#t+1] = LoadActor("lifepercent")

t[#t+1] = LoadActor("lanecover")
t[#t+1] = LoadActor("progressbar")
t[#t+1] = LoadActor("errorbar")
t[#t+1] = LoadActor("avatar")
--t[#t+1] = LoadActor("BPMDisplay")
t[#t+1] = LoadActor("title")




t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_BOTTOM-10):zoom(0.35):settext(GAMESTATE:GetSongOptions('ModsLevel_Song')):shadowlength(1)
	end;
}


local largeImageText = string.format("%s: %5.2f",profile:GetDisplayName(), profile:GetPlayerRating())

-- Max 64 for title, 32 for artist.
local title = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
title = #title < 64 and title or string.format("%s...", string.sub(title, 1, 60))

local artist = GAMESTATE:GetCurrentSong():GetDisplayArtist()
artist = #artist < 32 and artist or string.format("%s...", string.sub(artist, 1, 28))

local detail = string.format("Playing: %s - %s (%s)", artist, title, string.gsub(getCurRateDisplayString(), "Music", ""))

local difficulty = getDifficulty(steps:GetDifficulty())
local stepsType = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
local MSD = steps:GetMSD(getCurRateValue(),1)
MSDString = MSD > 0 and string.format("(%5.2f)", MSD) or "(Unranked)"

local state = string.format("%s %s %s",stepsType, difficulty, MSDString)

GAMESTATE:UpdateDiscordPresence(largeImageText, detail, state, 0)



return t