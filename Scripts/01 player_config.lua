local defaultConfig = {
	global = {
		DefaultScoreType = 2, -- 1 = MAX2 DP, 2 = Oni Percent Score, 3 = MIGS
		TipType = 1, -- 1 = Tips, 2= random quotes phrases, 3 = hide
		SongBGEnabled = true,
		SongBGMouseEnabled = true,
		--AvatarEnabled = true, -- Unused
	}
	eval = {
		CurrentTimeEnabled = true,
		JudgmentBarEnabled = true,
		JudgmentBarCellCount = 100, --Will be halved for 2p
		ScoreBoardEnabled = true,
		ScoreBoardMaxEntry = math.min(10,PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer")),
	}
}

playerConfig = create_setting("playerConfig", "playerConfig.lua", defaultConfig, -1)
playerConfig:load()

local slot_conversion= {
	[PLAYER_1]= "ProfileSlot_Player1", [PLAYER_2]= "ProfileSlot_Player2",}
function pn_to_profile_slot(pn)
	return slot_conversion[pn] or "ProfileSlot_Invalid"
end

function LoadProfileCustom(profile, dir)
	local players = GAMESTATE:GetEnabledPLayers()
	local playerProfile
	local pn
	for k,v in pairs(players) do
		playerProfile = PROFILEMAN:GetProfile(v)
		if playerProfile:GetGUID() == profile:GetGUID() then
			pn = v
		end;
	end; 

	if pn then
		local config = playerConfig:get_data(pn_to_profile_slot(pn))
	end
end

function SaveProfileCustom(profile, dir)
	local players = GAMESTATE:GetEnabledPLayers()
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
