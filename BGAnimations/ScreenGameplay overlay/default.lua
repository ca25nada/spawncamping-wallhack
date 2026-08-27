local inCustomize = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local inPractice = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingPractice()
local inReplay = GAMESTATE:GetPlayerState():GetPlayerController() == "PlayerController_Replay"

local t = Def.ActorFrame {}

local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)
local steps = GAMESTATE:GetCurrentSteps()

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


return t