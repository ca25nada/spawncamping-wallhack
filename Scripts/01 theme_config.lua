local defaultConfig = {
	global = {
		DefaultScoreType = 2, -- 1 = MAX2 DP, 2 = Oni Percent Score, 3 = MIGS
		TipType = 2, -- 1 = Hide,2=tips 3= random quotes phrases,
		SongBGEnabled = true,
		SongBGMouseEnabled = true,
		Particles = true,
		--AvatarEnabled = true, -- Unused
		RateSort = false,
	},
	eval = {
		CurrentTimeEnabled = true,
		JudgmentBarEnabled = true,
		JudgmentBarCellCount = 100, --Will be halved for 2p
		ScoreBoardEnabled = true,
		ScoreBoardMaxEntry = 10,
	},
	mainColor = color("#00AEEF"),
}

themeConfig = create_setting("themeConfig", "themeConfig.lua", defaultConfig,-1)
themeConfig:load()