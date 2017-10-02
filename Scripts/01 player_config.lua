
local defaultConfig = {
	--Avatar = "_fallback.png",
	ScreenFilter = 0,
	JudgeType = 0,
	AvgScoreType = 0,
	GhostScoreType = 0,
	GhostTarget = 0,
	ErrorBar = false,
	--ErrorBarDuration = 1,
	--ErrorBarMaxCount = 100,
	PaceMaker = false,
	LaneCover = 0, -- soon to be changed to: 0=off, 1=sudden, 2=hidden
	LaneCoverHeight = 0,
	--LaneCoverLayer = 350, -- notefield_draw_order.under_explosions
	NPSDisplay = false,
	NPSGraph = false,
	--NPSUpdateRate = 0.1,
	--NPSMaxVerts = 300,
	CBHighlight = false,
	FCEffect = true,
}

playerConfig = create_setting("playerConfig", "playerConfig.lua", defaultConfig, -1)

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