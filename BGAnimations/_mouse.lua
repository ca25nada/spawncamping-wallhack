local top

-- Actor for handling most mouse interactions.
local function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			MESSAGEMAN:Broadcast("MouseLeftClick")
		end
		if event.DeviceInput.button == "DeviceButton_right mouse button" then
			MESSAGEMAN:Broadcast("MouseRightClick")
		end
	end

	return false

end

local t = Def.ActorFrame{
	OnCommand = function(self)
		BUTTON:resetPressedActors()

		for _, pn in pairs({PLAYER_1, PLAYER_2}) do
			SCREENMAN:set_input_redirected(pn, false)
		end

		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
	end;
	OffCommand = function(self)
		BUTTON:resetPressedActors()
	end;
	MouseLeftClickMessageCommand = function(self)
		self:queuecommand("PlayTopPressedActor")
	end;
	MouseRightClickMessageCommand = function(self)
		self:queuecommand("PlayTopPressedActor")
	end;
	PlayTopPressedActorCommand = function(self)
		BUTTON:playTopPressedActor()
		BUTTON:resetPressedActors()
	end;
	ExitScreenMessageCommand = function(self, params)
		if params.screen == top:GetName() then
			top:StartTransitioningScreen("SM_GoToPrevScreen")
		end
	end
}

return t