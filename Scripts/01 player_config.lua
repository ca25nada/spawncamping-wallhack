
local defaultConfig = {
	ScreenFilter = 0,
	JudgeType = 0,
	AvgScoreType = 0,
	GhostScoreType = 0,
	GhostTarget = 1,
	ErrorBar = false,
	PaceMaker = false,
	LaneCover = false,
	LaneCoverHeight = 0,
}

playerConfig = create_setting("playerConfig", "playerConfig.lua", defaultConfig, -1)
--playerConfig:load()

function LoadProfileCustom(profile, dir)
	local players = GAMESTATE:GetEnabledPlayers()
	local playerProfile
	local pn
	for k,v in pairs(players) do
		playerProfile = PROFILEMAN:GetProfile(v)
		if playerProfile:GetGUID() == profile:GetGUID() then
			pn = v
		end;
	end; 

	if pn then
		playerConfig:load(pn_to_profile_slot(pn))
	end
end

function SaveProfileCustom(profile, dir)
	local players = GAMESTATE:GetEnabledPlayers()
	local playerProfile
	local pn
	for k,v in pairs(players) do
		playerProfile = PROFILEMAN:GetProfile(v)
		if playerProfile:GetGUID() == profile:GetGUID() then
			pn = v
		end;
	end; 

	if pn then
		playerConfig:set_dirty(pn_to_profile_slot(pn))
		playerConfig:save(pn_to_profile_slot(pn))
	end
end
