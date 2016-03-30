-- Enables mid-game pauses
-- Number of pauses done during gameplay will show up on ScreenEvaluation

local t = Def.ActorFrame{
	Name="SpeedChange";
	CodeMessageCommand = function(self, params)
		if params.Name == "Pause" then
			pauseGame()
		end;
	end
}

return t