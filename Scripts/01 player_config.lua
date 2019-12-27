local defaultGameplayCoordinates = {
	JudgeX = 0,
	JudgeY = 40,
	ComboX = 30,
	ComboY = -20,
	ErrorBarX = SCREEN_CENTER_X,
	ErrorBarY = SCREEN_CENTER_Y + 53,
	TargetTrackerX = SCREEN_CENTER_X + 26,
	TargetTrackerY = SCREEN_CENTER_Y + 30,
	JudgeCounterX = 0,
	JudgeCounterY = SCREEN_CENTER_Y - 80,
	DisplayPercentX = 80,
	DisplayPercentY = SCREEN_CENTER_Y - 92,
	NPSDisplayX = 5,
	NPSDisplayY = SCREEN_BOTTOM - 170,
	NPSGraphX = 0,
	NPSGraphY = SCREEN_BOTTOM - 160,
	NotefieldX = 0,
	NotefieldY = 0,
	LeaderboardX = SCREEN_WIDTH - (SCREEN_WIDTH * (IsUsingWideScreen() and 0.275 or 0.25)),
	LeaderboardY = 20,
	PlayerInfoP1X = 2,
	PlayerInfoP1Y = 20,
	PracticeCDGraphX = 0,
	PracticeCDGraphY = SCREEN_HEIGHT - 35,
	BPMTextX = SCREEN_CENTER_X,
	BPMTextY = SCREEN_BOTTOM - 30,
	MusicRateX = SCREEN_CENTER_X,
	MusicRateY = SCREEN_BOTTOM - 20,
	DisplayMeanX = 80,
	DisplayMeanY = SCREEN_CENTER_Y - 105,
}

local defaultGameplaySizes = {
	JudgeZoom = 1.0,
	ComboZoom = 0.6,
	ErrorBarWidth = 240,
	ErrorBarHeight = 10,
	TargetTrackerZoom = 0.4,
	DisplayPercentZoom = 1,
	NPSDisplayZoom = 0.4,
	NPSGraphWidth = 1.0,
	NPSGraphHeight = 1.0,
	NotefieldWidth = 1.0,
	NotefieldHeight = 1.0,
	LeaderboardWidth = 1.0,
	LeaderboardHeight = 1.0,
	LeaderboardSpacing = 0.0,
	PlayerInfoP1Width = 1.0,
	PlayerInfoP1Height = 1.0,
	PracticeCDGraphWidth = 0.8,
	PracticeCDGraphHeight = 1,
	PracticeCDGraphHeight = 1,
	MusicRateZoom = 1.0,
	BPMTextZoom = 1.0,
	DisplayMeanZoom = 1
}


local defaultConfig = {
	ScreenFilter = 0,
	JudgeType = 2, -- type for the judge counter
	AvgScoreType = 0,
	GhostScoreType = 0,
	GhostTarget = 0,
	TargetTracker = true,
	TargetTrackerMode = 0,
	TargetGoal = 93,
	ErrorBar = 0,
	--ErrorBarDuration = 1,
	--ErrorBarMaxCount = 100,
	leaderboardEnabled = false,
	PaceMaker = false,
	LaneCover = 0, -- soon to be changed to: 0=off, 1=sudden, 2=hidden
	LaneCoverHeight = 0,
	--LaneCoverLayer = 350, -- notefield_draw_order.under_explosions
	DisplayPercent = true,
	DisplayMean = false,
	NPSDisplay = false,
	NPSGraph = false,
	--NPSUpdateRate = 0.1,
	--NPSMaxVerts = 300,
	ReceptorSize = 100,
	CBHighlight = false,
	FCEffect = true,
	Username = "",
	Password = "",
	CBHighlightMinJudge = "TapNoteScore_W4",
	CustomizeGameplay = false,
	GameplayXYCoordinates = {
		["3K"] = DeepCopy(defaultGameplayCoordinates),
		["4K"] = DeepCopy(defaultGameplayCoordinates),
		["5K"] = DeepCopy(defaultGameplayCoordinates),
		["6K"] = DeepCopy(defaultGameplayCoordinates),
		["7K"] = DeepCopy(defaultGameplayCoordinates),
		["8K"] = DeepCopy(defaultGameplayCoordinates),
		["10K"] = DeepCopy(defaultGameplayCoordinates),
		["12K"] = DeepCopy(defaultGameplayCoordinates),
		["16K"] = DeepCopy(defaultGameplayCoordinates)
	},
	GameplaySizes = {
		["3K"] = DeepCopy(defaultGameplaySizes),
		["4K"] = DeepCopy(defaultGameplaySizes),
		["5K"] = DeepCopy(defaultGameplaySizes),
		["6K"] = DeepCopy(defaultGameplaySizes),
		["7K"] = DeepCopy(defaultGameplaySizes),
		["8K"] = DeepCopy(defaultGameplaySizes),
		["10K"] = DeepCopy(defaultGameplaySizes),
		["12K"] = DeepCopy(defaultGameplaySizes),
		["16K"] = DeepCopy(defaultGameplaySizes)
	}
}

playerConfig = create_setting("playerConfig", "playerConfig.lua", defaultConfig, -1)
local tmp2 = playerConfig.load
playerConfig.load = function(self, slot)
	local tmp = force_table_elements_to_match_type
	force_table_elements_to_match_type = function()
	end
	local x = create_setting("playerConfig", "playerConfig.lua", {}, -1)
	x = x:load(slot)
	local coords = x.GameplayXYCoordinates
	local sizes = x.GameplaySizes
	if sizes and not sizes["4K"] then
		defaultConfig.GameplaySizes["3K"] = sizes
		defaultConfig.GameplaySizes["4K"] = sizes
		defaultConfig.GameplaySizes["5K"] = sizes
		defaultConfig.GameplaySizes["6K"] = sizes
		defaultConfig.GameplaySizes["7K"] = sizes
		defaultConfig.GameplaySizes["8K"] = sizes
		defaultConfig.GameplaySizes["10K"] = sizes
		defaultConfig.GameplaySizes["12K"] = sizes
		defaultConfig.GameplaySizes["16K"] = sizes
	end
	if coords and not coords["4K"] then
		defaultConfig.GameplayXYCoordinates["3K"] = coords
		defaultConfig.GameplayXYCoordinates["4K"] = coords
		defaultConfig.GameplayXYCoordinates["5K"] = coords
		defaultConfig.GameplayXYCoordinates["6K"] = coords
		defaultConfig.GameplayXYCoordinates["7K"] = coords
		defaultConfig.GameplayXYCoordinates["8K"] = coords
		defaultConfig.GameplayXYCoordinates["10K"] = coords
		defaultConfig.GameplayXYCoordinates["12K"] = coords
		defaultConfig.GameplayXYCoordinates["16K"] = coords
	end
	force_table_elements_to_match_type = tmp
	return tmp2(self, slot)
end
playerConfig:load()

function LoadProfileCustom(profile, dir)
	local players = GAMESTATE:GetEnabledPlayers()
	local playerProfile
	local pn
	for k,v in pairs(players) do
		playerProfile = PROFILEMAN:GetProfile(v)
		if playerProfile:GetGUID() == profile:GetGUID() then
			pn = v
		end
	end

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
		end
	end

	if pn then
		playerConfig:set_dirty(pn_to_profile_slot(pn))
		playerConfig:save(pn_to_profile_slot(pn))
	end
end