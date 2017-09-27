

function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end

		if event.button == "EffectUp" then
			changeMusicRate(0.05)
		end

		if event.button == "EffectDown" then
			changeMusicRate(-0.05)
		end

	end

	return false

end

local top

local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
	end;
}

t[#t+1] = LoadActor("../_mouse")

t[#t+1] = LoadActor("../_frame")

t[#t+1] = LoadActor("../_cursor")

return t