Branch.PlayerOptions= function()
	local pm = GAMESTATE:GetPlayMode()
	local restricted = { PlayMode_Oni= true, PlayMode_Rave= true,
		--"PlayMode_Battle" -- ??
	}
	local optionsScreen = "ScreenNestyPlayerOptions"
	if restricted[pm] then
		optionsScreen = "ScreenNestyPlayerOptionsRestricted"
	end
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return optionsScreen
	else
		return "ScreenStageInformation"
	end
end

Branch.AfterSelectProfile = function()
	if (THEME:GetMetric("Common","AutoSetStyle") == true) then
		-- use SelectStyle in online...
		return IsNetConnected() and "ScreenSelectStyle" or "ScreenSelectMusic"
	else
		return "ScreenSelectMusic"
	end
end

Branch.AfterProfileLoad = function()
	return "ScreenSelectMusic"
end