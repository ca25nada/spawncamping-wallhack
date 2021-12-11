function SMOnlineScreen()
	if not IsNetSMOnline() then
		return "ScreenSelectMusic"
	end
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		if not IsSMOnlineLoggedIn(pn) then
			return "ScreenSMOnlineLogin"
		end
	end
	if not IsSMOnlineLoggedIn(pn) then
		return "ScreenSMOnlineLogin"
	end
	return "ScreenNetRoom"
end

Branch.PlayerOptions= function()

	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return "ScreenPlayerOptions"
	else
		return "ScreenStageInformation"
	end
end

Branch.AfterSelectProfile = function()
	return "ScreenSelectMusic"
end

Branch.AfterNetSelectProfile = function()
	return SMOnlineScreen()
end

Branch.AfterProfileLoad = function()
	return "ScreenSelectMusic"
end

Branch.AfterTitleMenu = function()
	return Branch.StartGame()
end

Branch.MultiScreen = function()
	if IsNetSMOnline() then
		return "ScreenNetSelectProfile"
	else
		return "ScreenNetworkOptions"
	end
end