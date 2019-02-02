local inputting = false
local activeField = {}
local filterFields = {}
filterFields["Lower"] = {}
filterFields["Upper"] = {}

local boundSection
local everything

local function wheelSearch()
	GHETTOGAMESTATE:getSSM():GetMusicWheel():SongSearch(GHETTOGAMESTATE:getMusicSearch())
end

local function updateFilter()
	for i = 1, #ms.SkillSets + 1 do
		FILTERMAN:SetSSFilter(tonumber(filterFields["Lower"][i]), i, 0)
		FILTERMAN:SetSSFilter(tonumber(filterFields["Upper"][i]), i, 1)
		--FILTERMAN:SetSSFilter(tonumber(filterFields[activeField[1]][activeField[2]]), tonumber(activeField[1]), activeField[2] == "Upper" and 1 or 0)
	end
	wheelSearch()
end

local function resetFilter()
	FILTERMAN:ResetSSFilters()
	for i = 1, #ms.SkillSets + 1 do -- the +1 is for the length field
		filterFields["Lower"][i] = FILTERMAN:GetSSFilter(i, 0)
		filterFields["Upper"][i] = FILTERMAN:GetSSFilter(i, 1)
	end
	wheelSearch()
end

for i = 1, #ms.SkillSets + 1 do -- the +1 is for the length field
	filterFields["Lower"][i] = FILTERMAN:GetSSFilter(i, 0)
	filterFields["Upper"][i] = FILTERMAN:GetSSFilter(i, 1)
end

local function updateSelected()
	local bound = activeField[1]
	local i = activeField[2]
	everything:GetChild("BoundContainer"..i):GetChild(bound):queuecommand("Set")
end

local function updateEverything()
	for i = 1, #ms.SkillSets + 1 do
		everything:GetChild("BoundContainer"..i):GetChild("Lower"):queuecommand("Set")
		everything:GetChild("BoundContainer"..i):GetChild("Upper"):queuecommand("Set")
	end
end

local function disableInput()
	inputting = false
	--activeField = {}
	MESSAGEMAN:Broadcast("FilterBoundSelect", {})
end

local function input(event)
	
	if event.type == "InputEventType_FirstPress" then
		if not inputting and (event.button == "Back" or event.button == "Start") then
			SCREENMAN:GetTopScreen():Cancel()
		elseif inputting then
			local slotValue = tostring(filterFields[activeField[1]][activeField[2]])
			if event.DeviceInput.button == "DeviceButton_left mouse button"  or event.DeviceInput.button == "DeviceButton_right mouse button" then
				if not boundSection:isOver() then
					disableInput()
				end
			elseif event.button == "Start" then
				disableInput()
				updateFilter()
			elseif event.button == "Back" then
				disableInput()
			elseif tonumber(event.char) ~= nil then
				if tonumber(slotValue .. event.char) ~= 0 and (slotValue .. event.char):len() < 6 then
					filterFields[activeField[1]][activeField[2]] = tostring(tonumber(slotValue .. event.char))
					updateSelected()
				end
			elseif event.DeviceInput.button == "DeviceButton_backspace" then
				local nextValue = slotValue:sub(1,-2)
				if nextValue ~= nil and tonumber(nextValue) ~= slotValue then
					if nextValue == "" then
						filterFields[activeField[1]][activeField[2]] = "0"
					else
						filterFields[activeField[1]][activeField[2]] = nextValue
					end
					updateSelected()
				end
			elseif event.DeviceInput.button == "DeviceButton_delete" then
				filterFields[activeField[1]][activeField[2]] = "0"
				updateSelected()
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
		everything = self
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
		Name = "BoundContainer"..i,
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
				inputting = true
				activeField = {"Lower", i}
				MESSAGEMAN:Broadcast("FilterBoundSelect", {bound = "Lower", selected = i})
			end,
			FilterBoundSelectMessageCommand = function(self, params)
				if params.selected ~= i  or params.bound ~= "Lower" then
					self:diffusealpha(0.2)
				end
			end
		},
		LoadFont("Common Normal") ..{
			Name = "Lower",
			InitCommand = function(self)
				self:xy(25 + numBoxWidth,leftUpperSectionHeight + verticalSpacing + 30 + 30 + (boxHeight + boundVerticalSpacing)*i)
				self:zoom(0.5)
				self:halign(0)
				self:settext("")
				self:queuecommand("Set")
			end,
			SetCommand = function(self)
				self:settext(filterFields["Lower"][i])
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
				inputting = true
				activeField = {"Upper", i}
				MESSAGEMAN:Broadcast("FilterBoundSelect", {bound = "Upper", selected = i})
			end,
			FilterBoundSelectMessageCommand = function(self, params)
				if params.selected ~= i or params.bound ~= "Upper" then
					self:diffusealpha(0.2)
				end
			end
		},
		LoadFont("Common Normal") ..{
			Name = "Upper",
			InitCommand = function(self)
				self:xy(25 + numBoxWidth*2 + boundHorizontalSpacing,leftUpperSectionHeight + verticalSpacing + 30 + 30 + (boxHeight + boundVerticalSpacing)*i)
				self:zoom(0.5)
				self:halign(0)
				self:settext("")
				self:queuecommand("Set")
			end,
			SetCommand = function(self)
				self:settext(filterFields["Upper"][i])
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
	Def.Quad {
		InitCommand = function(self)
			boundSection = self
			self:xy(10 + numBoxWidth,42)
			self:zoomto(numBoxWidth * 2 + boundHorizontalSpacing, boxHeight * (#ms.SkillSets+1) + boundVerticalSpacing * #ms.SkillSets)
			self:halign(0):valign(0)
			self:diffusealpha(0)
		end
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
		Name = "ApplyButton",
		InitCommand = function(self)
			self:xy(leftSectionWidth - numBoxWidth - boundHorizontalSpacing, 20)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(numBoxWidth, 20)
		end,
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			updateFilter()
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
		Name = "ResetButton",
		InitCommand = function(self)
			self:xy(leftSectionWidth - numBoxWidth - boundHorizontalSpacing, 50)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(numBoxWidth, 20)
		end,
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			resetFilter()
			updateEverything()
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
