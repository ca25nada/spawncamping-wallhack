local curInput = GHETTOGAMESTATE:getMusicSearch()
local inputting = false


local function input(event)
	
	if event.type == "InputEventType_FirstPress" then
		if inputting then
			local yeet = curInput
			local CtrlPressed = INPUTFILTER:IsBeingPressed("left ctrl") or INPUTFILTER:IsBeingPressed("right ctrl")
			if event.button == "Start" then
				inputting = false
			elseif event.button == "Back" then
				inputting = false
			elseif event.DeviceInput.button == "DeviceButton_v" and CtrlPressed then
				curInput = curInput .. HOOKS:GetClipboard()
			elseif event.DeviceInput.button == "DeviceButton_backspace" then
				curInput = curInput:sub(1, -2)
			elseif event.DeviceInput.button == "DeviceButton_delete" then
				curInput = ""
			elseif event.DeviceInput.button == "DeviceButton_space" then
				curInput = curInput .. " "
			elseif event.DeviceInput.button == "DeviceButton_left mouse button" or event.DeviceInput.button == "DeviceButton_right mouse button" then
				inputting = false
			else
				if event.char and event.char:match('[%%%+%-%!%@%#%$%^%&%*%(%)%=%_%.%,%:%;%\'%"%>%<%?%/%~%|%w]') and event.char ~= "" then
					curInput = curInput .. event.char
				end
			end
			MESSAGEMAN:Broadcast("UpdateText")
			GHETTOGAMESTATE:setMusicSearch(curInput)
			if yeet ~= curInput or curInput == "" then
				GHETTOGAMESTATE:getMusicWheel():SongSearch(curInput)
			end
			return true
		else
			if event.button == "Back" or event.button == "Start" then
				SCREENMAN:GetTopScreen():Cancel()
			end
		end
	end
	return false

end

local top
local leftSectionWidth = 300
local leftSectionHeight = SCREEN_HEIGHT - 60
local leftUpperSectionHeight = leftSectionHeight / 3
local leftLowerSectionHeight = leftSectionHeight / 2 + 63
local rightSectionWidth = 430
local rightSectionHeight = SCREEN_HEIGHT - 60

local verticalSpacing = 7
local horizontalSpacing = 10


local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
	end
}

t[#t+1] = LoadActor("../_mouse")

t[#t+1] = LoadActor("../_frame")

-- The top left container (The Search Menu)
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(10,30)
	end,

	Def.Quad {
		InitCommand = function (self)
			self:zoomto(leftSectionWidth,leftUpperSectionHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end,
	},
	LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:xy(5,10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Search for Installed Files")
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(5,leftUpperSectionHeight - 15)
			self:zoom(0.35)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("*Has Clipboard Support\n*Supports Standard US Layout Only")
		end
	},
	quadButton(6) .. {
		Name = "SearchBox",
		InitCommand = function(self)
			self:xy(5, leftUpperSectionHeight / 2)
			self:halign(0)
			self:zoomto(leftSectionWidth - 10, 30)
			self:diffusealpha(0.2)
		end,
		TopPressedCommand = function(self)
			self:diffusealpha(0.4)
			inputting = true
		end,
		UpdateTextMessageCommand = function(self)
			if inputting then
				self:diffusealpha(0.4)
			else
				self:diffusealpha(0.2)
			end
		end
	},
	LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:xy(7, leftUpperSectionHeight / 2)
			self:halign(0)
			self:zoom(0.4)
			if curInput == "" then
				self:settext("Click to Start Typing")
			else
				self:settextf("%s", curInput)
			end
			self:maxwidth(leftSectionWidth * 2.355)
		end,
		UpdateTextMessageCommand = function(self)
			if curInput ~= "" then
				self:settextf("%s", curInput)
			else
				self:settext("Click to Start Typing")
			end
		end
	}

}

-- The lower left container (The Filter Menu)
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(10,30 + leftUpperSectionHeight + verticalSpacing)
	end,

	Def.Quad {
		InitCommand = function (self)
			self:zoomto(leftSectionWidth,leftLowerSectionHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end,
	},
	LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:xy(5,10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Filter Files by Rating")
		end
	},
}

-- The right container (The Tags Menu)
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(20 + leftSectionWidth,30)
	end,

	Def.Quad {
		InitCommand = function (self)
			self:zoomto(rightSectionWidth,rightSectionHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end,
	},
	LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:xy(5,10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Tag Files and Organize")
		end
	},
}




t[#t+1] = LoadActor("../_cursor")

return t
