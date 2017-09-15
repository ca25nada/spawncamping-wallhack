function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			MESSAGEMAN:Broadcast("MouseLeftClick")
		end

		if event.DeviceInput.button == "DeviceButton_right mouse button" then
			SCREENMAN:GetTopScreen():Cancel()
		end

		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end
	end

	return true

end

local t = Def.ActorFrame {
	OnCommand = function(self)
	SCREENMAN:GetTopScreen():AddInputCallback(input)
	end;
	MouseLeftClickMessageCommand = function(self)
		self:queuecommand("PlayTopPressedActor")
	end;
	PlayTopPressedActorCommand = function(self)
		playTopPressedActor()
		resetPressedActors()
	end;
}

t[#t+1] = LoadActor("../_frame")

t[#t+1] = LoadActor("../_cursor")

return t