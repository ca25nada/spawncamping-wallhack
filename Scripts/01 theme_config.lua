local defaultConfig = {
	global = {
		DefaultScoreType = 1, -- 1 = WIFE, other scoring methods no longer supported.
		TipType = 2, -- 1 = Hide,2=tips 3= random quotes phrases,
		SongBGEnabled = true, 
		SongBGMouseEnabled = true,
		Particles = true,
		RateSort = true,
		ScoreBoardNag = true,
		MeasureLines = false,
		ProgressBar = 1, -- 0 = off, 1 bottom , 2 top
		SongPreview = 3, -- 1 = SM style, 2 = osu! Style (new), 3 = osu! style (old)
		BannerWheel = true,
		JudgmentEnabled = true,
		JudgmentTween = true,
		ComboTween = true,
		ComboWords = true,
		LeaderboardSlots = 8,
		AnimatedLeaderboard = true,
		BareBone = false, -- Still can't beat jousway lel
		EvalScoreboard = true,
		SimpleEval = true, -- false means use classic eval
		ShowScoreboardOnSimple = false,
		PlayerInfoType = true, -- true is full, false is minimal (lifebar only)
		InstantSearch = true, -- true = search per press, false = search on enter button
	},
	NPSDisplay = {
		DynamicWindow = false, -- unused
		MaxWindow = 2,
		MinWindow = 1, -- unused.
	},
	eval = {
		CurrentTimeEnabled = true,
		JudgmentBarEnabled = true,
		ScoreBoardEnabled = true,
		ScoreBoardMaxEntry = 10,
		SongBGType = 1, -- 1 = song bg, 2 = grade+common, 3 = grade only
	},
}

themeConfig = create_setting("themeConfig", "themeConfig.lua", defaultConfig,-1)
themeConfig:load()

function getSongPreviewMode()
	if themeConfig:get_data().global.SongPreview == 1 then
		return 'SampleMusicPreviewMode_Normal'
	else
		return 'SampleMusicPreviewMode_ScreenMusic'
	end
end

function isBareBone()
	return themeConfig:get_data().global.BareBone
end

function useJudgmentTween()
	return themeConfig:get_data().global.JudgmentTween
end

function isJudgmentEnabled()
	return themeConfig:get_data().global.JudgmentEnabled
end