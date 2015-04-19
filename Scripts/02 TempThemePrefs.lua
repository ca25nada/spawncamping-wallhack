--Temporary theme prefs page.
--Will be either removed or changed when I eventually add a screen for changing theme prefs ingame.
--No prefs for screengameplay are here since they're added already.

local preferences = {
	DefaultScoreType = 2, -- 1 = MAX2 DP, 2 = Oni Percent Score, 3 = MIGS
	TipType = 1, -- 1 = Tips, 2= random quotes phrases, 3 = hide
	SongBGEnabled = true,
	SongBGMouseEnabled = true,
	--AvatarEnabled = true, -- Unused
}

local evalPreferences = {
	CurrentTimeEnabled = true,
	JudgmentBarEnabled = true,
	JudgmentBarCellCount = 100, --Will be halved for 2p
	ScoreBoardEnabled = true,
	ScoreBoardMaxEntry = math.min(10,PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer")),

}

function getTempThemePref(prefs)
	return preferences[prefs]
end;

function getTempEvalPref(prefs)
	return evalPreferences[prefs]
end;

local defautCustomPrefs = {
	GlobalScoreType = 2, -- 1 = MAX2 DP, 2 = Oni Percent Score, 3 = MIGS
	GlobalTipType = 1, -- 1 = Tips, 2= random quotes phrases, 3 = hide
	--AvatarEnabled = true, -- Unused
	EvalCurrentTimeEnabled = true,
	EvalJudgmentBarEnabled = true,
	EvalJudgmentBarCellCount = 100, --Will be halved for 2p
	EvalScoreBoardEnabled = true,
	EvalScoreBoardMaxEntry = math.min(10,PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer")),

}