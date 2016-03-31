
local defaultConfig = {
	--Avatar = "_fallback.png",
	ScreenFilter = 0,
	JudgeType = 0,
	AvgScoreType = 0,
	GhostScoreType = 0,
	GhostTarget = 1,
	ErrorBar = false,
	PaceMaker = false,
	LaneCover = 0, -- soon to be changed to: 0=off, 1=sudden, 2=hidden
	LaneCoverHeight = 0,
	NPSDisplay = false,
	NPSGraph = false,
	CBHighlight = false,
}

playerConfig = create_lua_config({name = "playerConfig", file = "playerConfig.lua", default = defaultConfig, match_depth =-1})
--playerConfig:load()

add_standard_lua_config_save_load_hooks(playerConfig)