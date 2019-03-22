local defaultConfig = {
	global = {
		DefaultScoreType = 1, -- 1 = WIFE, other scoring methods no longer supported.
		TipType = 2, -- 1 = Hide,2=tips 3= random quotes phrases,
		SongBGEnabled = true, 
		SongBGMouseEnabled = true,
		Particles = true,
		RateSort = true,
		ScoreBoardNag = true,
		MeasureLines = true,
		ProgressBar = 1, -- 0 = off, 1 bottom , 2 top
		SongPreview = 3, -- 1 = SM style, 2 = osu! Style (new), 3 = osu! style (old)
		BannerWheel = true,
		UseAssetsJudgements = false,
		JudgementTween = true,
		BareBone = false, -- Still can't beat jousway lel
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

function judgementTween()
	return themeConfig:get_data().global.JudgementTween
end

function useAssetsJudgements()
	return themeConfig:get_data().global.UseAssetsJudgements
end