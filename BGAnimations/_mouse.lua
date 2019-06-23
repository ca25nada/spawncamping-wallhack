local top
local whee
local sName = ...

BUTTON:ResetButtonTable(sName)

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
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			BUTTON:SetMouseDown(event.DeviceInput.button)
		end
		if event.DeviceInput.button == "DeviceButton_right mouse button" then
			BUTTON:SetMouseDown(event.DeviceInput.button)
		end
	end
	if event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
            BUTTON:SetMouseUp(event.DeviceInput.button)
		end
		if event.DeviceInput.button == "DeviceButton_right mouse button" then
            BUTTON:SetMouseUp(event.DeviceInput.button)
        end
    end

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	if whee and mouseX > capWideScale(370, 500) and mouseX < SCREEN_WIDTH - 32 then
		if event.DeviceInput.button == "DeviceButton_left mouse button" and event.type == "InputEventType_FirstPress" then
			local n = 0
			local m = 1
			if mouseY > 212 and mouseY < 264 then
				m = 0
			elseif mouseY > 264 and mouseY < 312 then
				m = 1
				n = 1
			elseif mouseY > 312 and mouseY < 360 then
				m = 1
				n = 2
			elseif mouseY > 360 and mouseY < 408 then
				m = 1
				n = 3
			elseif mouseY > 408 and mouseY < 456 then
				m = 1
				n = 4
			elseif mouseY > 164 and mouseY < 212 then
				m = -1
				n = 1
			elseif mouseY > 112 and mouseY < 164 then
				m = -1
				n = 2
			elseif mouseY > 68 and mouseY < 112 then
				m = -1
				n = 3
			elseif mouseY > 22 and mouseY < 68 then
				m = -1
				n = 4
			end

			local type = whee:MoveAndCheckType(m * n)
			whee:Move(0)
			if m == 0 then
				top:SelectCurrent(0)
			end
		end
	end

	return false

end

local function updater()
	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()
	BUTTON:UpdateMouseState()

	return false
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:SetUpdateFunction(updater):SetUpdateFunctionInterval(0.01)
	end,
	OnCommand = function(self)

		SCREENMAN:set_input_redirected(PLAYER_1, false)

		top = SCREENMAN:GetTopScreen()
		if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" or top:GetName() == "ScreenNetRoom" then
			whee = top:GetMusicWheel()
		end
		top:AddInputCallback(input)
	end,
	OffCommand = function(self)
		self:playcommand("Cancel")
	end,
	CancelCommand = function(self)
		BUTTON:ResetButtonTable(top:GetName())
	end,
	ExitScreenMessageCommand = function(self, params)
		if params.screen == top:GetName() then
			top:StartTransitioningScreen("SM_GoToPrevScreen")
		end
	end
}

return t