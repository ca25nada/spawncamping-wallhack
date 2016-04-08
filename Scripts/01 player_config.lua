
local defaultConfig = {
	--Avatar = "_fallback.png",
	ScreenFilter = 0,
	JudgeType = 0,
	AvgScoreType = 0,
	GhostScoreType = 0,
	GhostTarget = 0,
	ErrorBar = false,
	ErrorBarDuration = 1,
	ErrorBarMaxCount = 100,
	PaceMaker = false,
	LaneCover = 0, -- soon to be changed to: 0=off, 1=sudden, 2=hidden
	LaneCoverHeight = 0,
	NPSDisplay = false,
	NPSGraph = false,
	NPSUpdateRate = 0.1,
	NPSMaxVerts = 300,
	CBHighlight = false,
	FCEffect = true,
}

playerConfig = create_lua_config({name = "playerConfig", file = "playerConfig.lua", default = defaultConfig, match_depth =-1})
--playerConfig:load()

add_standard_lua_config_save_load_hooks(playerConfig)