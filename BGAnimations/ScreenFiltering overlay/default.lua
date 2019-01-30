local inputting = false
local activeField
local filterFields = {}
filterFields["Lower"] = {}
filterFields["Upper"] = {}
for i = 1, #ms.SkillSets + 1 do -- the +1 is for the length field
	filterFields["Lower"][i] = "0"
	filterFields["Upper"][i] = "0"
end

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

local boxHeight = 20
local numBoxWidth = leftSectionWidth / 5
local boundHorizontalSpacing = 8
local boundVerticalSpacing = 2

-- make the boxes for lower and upper bounds
-- im gonna make this complicated and build an actorframe of 2 boxes
-- you cant stop me
local function boundBoxes(i)
	local r = Def.ActorFrame {
		-- Skillset name (or Length)
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(20,leftUpperSectionHeight + verticalSpacing + 30 + 30 + (boxHeight + boundVerticalSpacing)*i)
				self:zoom(0.4)
				self:halign(0)
				self:settext(i == #ms.SkillSets+1 and "Length" or ms.SkillSets[i])
			end
		},
		-- Lower bound box
		quadButton(3) .. {
			Name = "LowerBound"..(i == (#ms.SkillSets+1) and "Length" or ms.SkillSets[i]),
			InitCommand = function(self)
				self:xy(20 + numBoxWidth,leftUpperSectionHeight + verticalSpacing + 30 + 30 + (boxHeight + boundVerticalSpacing)*i)
				self:halign(0)
				self:zoomto(numBoxWidth,boxHeight)
				self:diffusealpha(0.2)
			end,
			TopPressedCommand = function(self)
				self:diffusealpha(0.4)
				MESSAGEMAN:Broadcast("FilterBoundSelect", {bound = "Lower", selected = i})
			end,
			FilterBoundSelectMessageCommand = function(self, params)
				if params.selected ~= i  or params.bound ~= "Lower" then
					self:diffusealpha(0.2)
				end
			end
		},
		-- Upper bound box
		quadButton(3) .. {
			Name = "UpperBound"..(i == (#ms.SkillSets+1) and "Length" or ms.SkillSets[i]),
			InitCommand = function(self)
				self:xy(20 + numBoxWidth*2 + boundHorizontalSpacing,leftUpperSectionHeight + verticalSpacing + 30 + 30 + (boxHeight + boundVerticalSpacing)*i)
				self:halign(0)
				self:zoomto(numBoxWidth,boxHeight)
				self:diffusealpha(0.2)
			end,
			TopPressedCommand = function(self)
				self:diffusealpha(0.4)
				MESSAGEMAN:Broadcast("FilterBoundSelect", {bound = "Upper", selected = i})
			end,
			FilterBoundSelectMessageCommand = function(self, params)
				if params.selected ~= i or params.bound ~= "Upper" then
					self:diffusealpha(0.2)
				end
			end
		}

	}

	return r
end

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
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(20 + numBoxWidth,35)
			self:halign(0)
			self:zoom(0.3)
			self:settext("Lower Bound")
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(20 + numBoxWidth*2 + boundHorizontalSpacing,35)
			self:halign(0)
			self:zoom(0.3)
			self:settext("Upper Bound")
		end
	},
	quadButton(6) .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - numBoxWidth - boundHorizontalSpacing, 20)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(numBoxWidth, 20)
		end,
		TopPressedCommand = function(self)
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - (numBoxWidth + boundHorizontalSpacing)/2 - 5, 20)
			self:zoom(0.4)
			self:settext("Apply")
		end
	},
	quadButton(6) .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - numBoxWidth - boundHorizontalSpacing, 50)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(numBoxWidth, 20)
		end,
		TopPressedCommand = function(self)
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - (numBoxWidth + boundHorizontalSpacing)/2 - 5, 50)
			self:zoom(0.4)
			self:settext("Reset")
		end
	}
}

for i = 1, #filterFields["Lower"] do
	t[#t+1] = boundBoxes(i)	
end

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
