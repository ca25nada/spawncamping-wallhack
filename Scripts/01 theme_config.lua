local defaultConfig = {
	global = {
		DefaultScoreType = 2, -- 1 = MAX2 DP, 2 = Oni Percent Score, 3 = MIGS
		TipType = 1, -- 1 = Tips, 2= random quotes phrases, 3 = hide
		SongBGEnabled = true,
		SongBGMouseEnabled = true,
		--AvatarEnabled = true, -- Unused
	},
	eval = {
		CurrentTimeEnabled = true,
		JudgmentBarEnabled = true,
		JudgmentBarCellCount = 100, --Will be halved for 2p
		ScoreBoardEnabled = true,
		ScoreBoardMaxEntry = math.min(10,PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer")),
	}
}

themeConfig = create_setting("themeConfig", "themeConfig.lua", defaultConfig, -1)
themeConfig:load()
themeConfig:set_dirty()
themeConfig:save()

local slot_conversion= {
	[PLAYER_1]= "ProfileSlot_Player1", [PLAYER_2]= "ProfileSlot_Player2",}
function pn_to_profile_slot(pn)
	return slot_conversion[pn] or "ProfileSlot_Invalid"
end

function LoadProfileCustom(profile, dir)
end

function SaveProfileCustom(profile, dir)
	themeConfig:set_dirty()
	themeConfig:save()
end
