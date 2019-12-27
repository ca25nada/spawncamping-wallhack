local inCustomize = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local inPractice = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingPractice()
local inReplay = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerController() == "PlayerController_Replay"

local t = Def.ActorFrame {}

local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)
local steps = GAMESTATE:GetCurrentSteps(pn)

t[#t+1] = LoadActor("scoretracking")

t[#t+1] = LoadActor("judgecount")

--t[#t+1] = LoadActor("pacemaker")
t[#t+1] = LoadActor("npscalc")
--t[#t+1] = LoadActor("lifepercent")
t[#t+1] = LoadActor("lanecover")
t[#t+1] = LoadActor("WifeJudgmentSpotting")
if themeConfig:get_data().global.ProgressBar ~= 0 then
	t[#t+1] = LoadActor("progressbar")
end
t[#t+1] = LoadActor("leaderboard")
t[#t+1] = LoadActor("avatar")
t[#t+1] = LoadActor("title")

if inCustomize then
	t[#t+1] = LoadActor("messagebox")
end

if not inCustomize and not inPractice and not inReplay then
	HOOKS:ShowCursor(false)
else
	t[#t+1] = LoadActor("../_cursor")
	t[#t+1] = LoadActor("../_mouse", ToGameplay())
end

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