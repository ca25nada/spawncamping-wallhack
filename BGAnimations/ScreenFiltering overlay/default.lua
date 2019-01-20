local curInput = GHETTOGAMESTATE:getMusicSearch()
local inputting = false


local function input(event)
	
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
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

-- The top left container (The Info Section)
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
			self:settext("General Information")
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(5, 75)
			self:zoom(0.35)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			local finalString = "Searching:\nSearch by clicking the sort in the top right or by pressing Ctrl + 4\nPress Start or Back to stop typing\nSupports clipboard"
			finalString = finalString .. "\n\nFiltering:\nEnter numbers only. The boxes create a range if both are filled"
			finalString = finalString .. "\n\nTagging:\nLeft click a Tag to enable or disable filtering\nRight click a Tag to delete"
			self:settext(finalString)
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
