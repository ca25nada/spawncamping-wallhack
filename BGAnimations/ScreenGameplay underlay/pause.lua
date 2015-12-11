local t = Def.ActorFrame{
	Name="SpeedChange";
	CodeMessageCommand = function(self, params)
		if params.Name == "Pause" then
			local screen = SCREENMAN:GetTopScreen()
			local paused = screen:IsPaused()
			if paused then
				SCREENMAN:GetTopScreen():PauseGame(not paused)
				SCREENMAN:SystemMessage("Game Unpaused")
			else
				SCREENMAN:GetTopScreen():PauseGame(not paused)
				SCREENMAN:SystemMessage("Game Paused")
			end
		end;
	end
}

return t