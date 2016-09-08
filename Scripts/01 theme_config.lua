local defaultConfig = {
	global = {
		DefaultScoreType = 2, -- 1 = MAX2 DP, 2 = Oni Percent Score, 3 = MIGS
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

--[[ Unused, to be used after a future overhaul.
local fallbackScoreType = "DP"
local scoreType = {
	DP = {
		Name = "MAX2 DP",
		ScoreWeight = {
			TapNoteScore_W1				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW1"),					--  2
			TapNoteScore_W2				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW2"),					--  2
			TapNoteScore_W3				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW3"),					--  1
			TapNoteScore_W4				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW4"),					--  0
			TapNoteScore_W5				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW5"),					-- -4
			TapNoteScore_Miss			= THEME:GetMetric("ScoreKeeperNormal","GradeWeightMiss"),				-- -8
			HoldNoteScore_Held			= THEME:GetMetric("ScoreKeeperNormal","GradeWeightHeld"),				--  6
			TapNoteScore_HitMine		= THEME:GetMetric("ScoreKeeperNormal","GradeWeightHitMine"),				-- -8
			HoldNoteScore_LetGo			= THEME:GetMetric("ScoreKeeperNormal","GradeWeightLetGo"),				--  0
			HoldNoteScore_MissedHold	 = THEME:GetMetric("ScoreKeeperNormal","GradeWeightMissedHold"),
			TapNoteScore_AvoidMine		= 0,
			TapNoteScore_CheckpointHit	= THEME:GetMetric("ScoreKeeperNormal","GradeWeightCheckpointHit"),		--  0
			TapNoteScore_CheckpointMiss = THEME:GetMetric("ScoreKeeperNormal","GradeWeightCheckpointMiss"),		--  0
		},
		GradeCutoff = {
			Grade_Tier01 = THEME:GetMetric("PlayerStageStats","GradePercentTier01"),
			Grade_Tier02 = THEME:GetMetric("PlayerStageStats","GradePercentTier02"),
			Grade_Tier03 = THEME:GetMetric("PlayerStageStats","GradePercentTier03"),
			Grade_Tier04 = THEME:GetMetric("PlayerStageStats","GradePercentTier04"),
			Grade_Tier05 = THEME:GetMetric("PlayerStageStats","GradePercentTier05"),
			Grade_Tier06 = THEME:GetMetric("PlayerStageStats","GradePercentTier06"),
			Grade_Tier07 = -100
		},
		GradeNames = {
			Grade_Tier01 = "AAAA",
			Grade_Tier02 = "AAA",
			Grade_Tier03 = "AA",
			Grade_Tier04 = "A",
			Grade_Tier05 = "B",
			Grade_Tier06 = "C",
			Grade_Tier07 = "D",
			Grade_Failed = "F"
		}
	},
	ITGDP = {
		Name = "ITG DP",
		ScoreWeight = {
			TapNoteScore_W1				= 5,
			TapNoteScore_W2				= 4,
			TapNoteScore_W3				= 2,					--  1
			TapNoteScore_W4				= 0,					--  0
			TapNoteScore_W5				= -6,					-- -4
			TapNoteScore_Miss			= -12,				-- -8
			HoldNoteScore_Held			= 5,				--  6
			TapNoteScore_HitMine		= -6,				-- -8
			HoldNoteScore_LetGo			= 0,				--  0
			HoldNoteScore_MissedHold	= 0,
			TapNoteScore_AvoidMine		= 0,
			TapNoteScore_CheckpointHit	= 0,		--  0
			TapNoteScore_CheckpointMiss = 0,		--  0
		},
		GradeCutoff = {
			Grade_Tier01 = 1.00,
			Grade_Tier02 = 0.99,
			Grade_Tier03 = 0.98,
			Grade_Tier04 = 0.96,
			Grade_Tier05 = 0.94,
			Grade_Tier06 = 0.92,
			Grade_Tier07 = 0.89,
			Grade_Tier08 = 0.86,
			Grade_Tier09 = 0.83,
			Grade_Tier10 = 0.80,
			Grade_Tier11 = 0.76,
			Grade_Tier12 = 0.72,
			Grade_Tier13 = 0.68,
			Grade_Tier14 = 0.64,
			Grade_Tier15 = 0.60,
			Grade_Tier16 = 0.55,
			Grade_Tier17 = -100,
		},
		GradeNames = {
			Grade_Tier01 = "★★★★",
			Grade_Tier02 = "★★★",
			Grade_Tier03 = "★★",
			Grade_Tier04 = "★",
			Grade_Tier05 = "S+",
			Grade_Tier06 = "S",
			Grade_Tier07 = "S-",
			Grade_Tier08 = "A+",
			Grade_Tier09 = "A",
			Grade_Tier10 = "A-",
			Grade_Tier11 = "B+",
			Grade_Tier12 = "B",
			Grade_Tier13 = "B-",
			Grade_Tier14 = "C+",
			Grade_Tier15 = "C",
			Grade_Tier16 = "C-",
			Grade_Tier17 = "D",
			Grade_Failed = "F"
		}
	},
	PS = {
		Name = "EX-Oni PS",
		ScoreWeight = {
			TapNoteScore_W1			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW1"),
			TapNoteScore_W2			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW2"),
			TapNoteScore_W3			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW3"),
			TapNoteScore_W4			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW4"),
			TapNoteScore_W5			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW5"),
			TapNoteScore_Miss			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightMiss"),
			HoldNoteScore_Held			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightHeld"),
			TapNoteScore_HitMine			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightHitMine"),
			HoldNoteScore_LetGo			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightLetGo"),
			HoldNoteScore_MissedHold	 = THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightMissedHold"),
			TapNoteScore_AvoidMine		= 0,
			TapNoteScore_CheckpointHit		= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightCheckpointHit"),
			TapNoteScore_CheckpointMiss 	= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightCheckpointMiss"),
		},
		GradeCutoff = nil, -- Default to DP
		GradeNames = nil, -- default to DP
	},
	MIGS = {
		Name = "MIGS",
		ScoreWeight = {
			TapNoteScore_W1					= 3,
			TapNoteScore_W2					= 2,
			TapNoteScore_W3					= 1,
			TapNoteScore_W4					= 0,
			TapNoteScore_W5					= -4,
			TapNoteScore_Miss				= -8,
			HoldNoteScore_Held				= IsGame("pump") and 0 or 6,
			TapNoteScore_HitMine			= -8,
			HoldNoteScore_LetGo				= 0,
			HoldNoteScore_MissedHold 		= 0,
			TapNoteScore_AvoidMine			= 0,
			TapNoteScore_CheckpointHit		= 2,
			TapNoteScore_CheckpointMiss 	= -8,
		},
		GradeCutoff = nil, -- Default to DP
		GradeNames = nil, -- default to DP
	},
	OMPS = {
		Name = "osu!mania PS",
		ScoreWeight = {
			TapNoteScore_W1				= 300,
			TapNoteScore_W2				= 300,
			TapNoteScore_W3				= 200,					
			TapNoteScore_W4				= 100,					
			TapNoteScore_W5				= 50,					
			TapNoteScore_Miss			= 0,				
			HoldNoteScore_Held			= 300,				
			TapNoteScore_HitMine		= 0,
			HoldNoteScore_LetGo			= 0,
			HoldNoteScore_MissedHold	= 0,
			TapNoteScore_AvoidMine		= 0,
			TapNoteScore_CheckpointHit	= 0,
			TapNoteScore_CheckpointMiss = 0
		},
		GradeCutoff = {
			Grade_Tier01 = 1,
			Grade_Tier02 = 0.95,
			Grade_Tier03 = 0.90,
			Grade_Tier04 = 0.80,
			Grade_Tier05 = 0.70,
			Grade_Tier06 = 0
		},
		GradeNames = {
			Grade_Tier01 = "SS",
			Grade_Tier02 = "S",
			Grade_Tier03 = "A",
			Grade_Tier04 = "B",
			Grade_Tier05 = "C",
			Grade_Tier06 = "D",
			Grade_Failed = "F"
		}
	},
	IIDX = {
		Name = "IIDX EX-Score",
		ScoreWeight = {
			TapNoteScore_W1				= 2,
			TapNoteScore_W2				= 1,
			TapNoteScore_W3				= 0,					
			TapNoteScore_W4				= 0,					
			TapNoteScore_W5				= 0,					
			TapNoteScore_Miss			= 0,				
			HoldNoteScore_Held			= 2,				
			TapNoteScore_HitMine		= 0,
			HoldNoteScore_LetGo			= 0,
			HoldNoteScore_MissedHold	= 0,
			TapNoteScore_AvoidMine		= 0,
			TapNoteScore_CheckpointHit	= 0,
			TapNoteScore_CheckpointMiss = 0
		},
		GradeCutoff = {
			Grade_Tier01 = 8/9,
			Grade_Tier02 = 7/9,
			Grade_Tier03 = 6/9,
			Grade_Tier04 = 5/9,
			Grade_Tier05 = 4/9,
			Grade_Tier06 = 3/9,
			Grade_Tier07 = 2/9,
			Grade_Tier08 = 0,
		},
		GradeNames = {
			Grade_Tier01 = "AAA",
			Grade_Tier02 = "AA",
			Grade_Tier03 = "A",
			Grade_Tier04 = "B",
			Grade_Tier05 = "C",
			Grade_Tier06 = "D",
			Grade_Tier07 = "E",
			Grade_Tier08 = "F",
			Grade_Failed = "F"
		}
	},
}

--]]