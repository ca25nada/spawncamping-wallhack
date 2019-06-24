local inputting = false
local activeField = {}
local filterFields = {}
filterFields["Lower"] = {}
filterFields["Upper"] = {}

local boundSection
local everything


local maxTags = 20
local maxPages = 1
local curPage = 1
local ptags = tags:get_data().playerTags
local playertags = {}
local filterTags = GHETTOGAMESTATE:getFilterTags()
local tagName
local tagFilterMode = GHETTOGAMESTATE:getTagFilterMode()
local packlistFiltered

for i = 1, #ms.SkillSets + 1 do -- the +1 is for the length field
	filterFields["Lower"][i] = FILTERMAN:GetSSFilter(i, 0)
	filterFields["Upper"][i] = FILTERMAN:GetSSFilter(i, 1)
end

local function updateTagsFromData()
	ptags = tags:get_data().playerTags
	playertags = {}
	for k,v in pairs(ptags) do
		playertags[#playertags+1] = k
	end
	table.sort(playertags, function(left, right)
		if filterTags[left] == filterTags[right] then
			return left:lower() < right:lower()
		else
			return filterTags[left] ~= nil and filterTags[right] == nil
		end
	end)
	curPage = 1
	maxPages = math.ceil(#playertags/maxTags)
end

local function movePage(n)
	if maxPages > 1 then
		if n > 0 then 
			curPage = ((curPage+n-1) % maxPages + 1)
		else
			curPage = ((curPage+n+maxPages-1) % maxPages+1)
		end
	end
	MESSAGEMAN:Broadcast("UpdateList")
end

local function wheelSearch()
	local search = GHETTOGAMESTATE:getMusicSearch()
	GHETTOGAMESTATE:getSSM():GetMusicWheel():SongSearch(search)
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

-- From Til Death: The "OR" and "AND" filter for tags
local function updateTagFilter()
	ptags = tags:get_data().playerTags
	local charts = {}
	if next(filterTags) then
		toFilterTags = {}
		for k, v in pairs(filterTags) do
			toFilterTags[#toFilterTags + 1] = k
		end
		if tagFilterMode then
			local inCharts = {}
			for k, v in pairs(ptags[toFilterTags[1]]) do
				inCharts[k] = 1
			end
			toFilterTags[1] = nil
			for k, v in pairs(toFilterTags) do
				for key, val in pairs(inCharts) do
					if ptags[v][key] == nil then
						inCharts[key] = nil
					end
				end
			end
			for k, v in pairs(inCharts) do
				charts[#charts + 1] = k
			end
		else
			for k, v in pairs(toFilterTags) do
				for key, val in pairs(ptags[v]) do
					if charts[key] == nil then
						charts[#charts + 1] = key
					end
				end
			end
		end
	end
	GHETTOGAMESTATE:setFilterTags(filterTags)
	GHETTOGAMESTATE:getSSM():GetMusicWheel():FilterByStepKeys(charts)
	wheelSearch()
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
		if not inputting then
			if not inputting and (event.button == "Back" or event.button == "Start") then
				SCREENMAN:GetTopScreen():Cancel()	
			elseif event.DeviceInput.button == "DeviceButton_mousewheel up" then
				MESSAGEMAN:Broadcast("WheelUpSlow")
			elseif event.DeviceInput.button == "DeviceButton_mousewheel down" then
				MESSAGEMAN:Broadcast("WheelDownSlow")
			elseif event.button == "MenuLeft" then
				movePage(-1)
			elseif event.button == "MenuRight" then
				movePage(1)
			end
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
local rightSectionWidth = SCREEN_WIDTH/2 - capWideScale(10,-95)
local rightSectionHeight = SCREEN_HEIGHT - 60

local verticalSpacing = 7
local horizontalSpacing = 10


local t = Def.ActorFrame {
	OnCommand = function(self)
		everything = self
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
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
			MouseDownCommand = function(self)
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
			MouseDownCommand = function(self)
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

t[#t+1] = LoadActor("../_mouse", "ScreenFiltering")

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
			finalString = finalString .. "\n\nTagging:\nLeft click a Tag to enable or disable filtering\nRight click a Tag to delete it permanently"
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
			self:settext("Filter Files")
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
		MouseDownCommand = function(self)
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
		MouseDownCommand = function(self)
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
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - (numBoxWidth + boundHorizontalSpacing)/2 - 15, boxHeight * (#ms.SkillSets+1) + boundVerticalSpacing * #ms.SkillSets)
			self:settext("Matches")
			self:zoom(0.4)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - (numBoxWidth + boundHorizontalSpacing)/2 - 15, boxHeight * (#ms.SkillSets+1) + boundVerticalSpacing * #ms.SkillSets + 10)
			self:settext("?? / ??")
			self:zoom(0.35)
		end,
		FilterResultsMessageCommand = function(self, msg)
			self:settextf("%d / %d", msg.Matches, msg.Total)
		end
	},
	quadButton(6) .. {
		Name = "ModeButton",
		InitCommand = function(self)
			self:xy(20, 45 + (boxHeight + boundVerticalSpacing)*(#ms.SkillSets+1))
			self:zoomto(numBoxWidth, 20)
			self:diffusealpha(0.2)
			self:halign(0):valign(0)
		end,
		MouseDownCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			FILTERMAN:ToggleFilterMode()
			self:GetParent():queuecommand("Set")
			wheelSearch()
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ModeText",
		InitCommand = function(self)
			self:xy(20 + numBoxWidth/10, 50 + (boxHeight + boundVerticalSpacing)*(#ms.SkillSets+1))
			self:zoom(0.4)
			self:valign(0):halign(0)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			if FILTERMAN:GetFilterMode() then
				self:settext("Mode: And")
			else
				self:settext("Mode: Or")
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ModeExplanation",
		InitCommand = function(self)
			self:xy(20 + numBoxWidth + 5, 50 + (boxHeight + boundVerticalSpacing)*(#ms.SkillSets+1))
			self:zoom(0.4)
			self:valign(0):halign(0)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			if FILTERMAN:GetFilterMode() then
				self:settext("Must match all set bounds")
			else
				self:settext("May match any set bound")
			end
		end
	},
	quadButton(6) .. {
		Name = "ApplyButton",
		InitCommand = function(self)
			packlistFiltered = FILTERMAN:GetFilteringCommonPacks()
			self:xy(leftSectionWidth - numBoxWidth - boundHorizontalSpacing, leftLowerSectionHeight - boxHeight - 5)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(numBoxWidth, 20)
			self:visible( IsNetSMOnline() and IsSMOnlineLoggedIn(PLAYER_1) and NSMAN:IsETTP() )
		end,
		MouseDownCommand = function(self)
			if IsNetSMOnline() and IsSMOnlineLoggedIn(PLAYER_1) and NSMAN:IsETTP() then
				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
				--updateFilter()
				packlistFiltered = GHETTOGAMESTATE:getMusicWheel():SetPackListFiltering(not packlistFiltered)
				MESSAGEMAN:Broadcast("FilterModeChanged")
			end
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - (numBoxWidth + boundHorizontalSpacing)/2 - 5, leftLowerSectionHeight - boxHeight - 5)
			self:zoom(0.4)
			if IsNetSMOnline() and IsSMOnlineLoggedIn(PLAYER_1) and NSMAN:IsETTP() then
				self:playcommand("Set")
			else
				self:visible(false)
			end
		end,
		SetCommand = function(self)
			self:settext(packlistFiltered and "On" or "Off")
		end,
		FilterModeChangedMessageCommand = function(self)
			self:queuecommand("Set")
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(leftSectionWidth - (numBoxWidth + boundHorizontalSpacing)/2 - 5, leftLowerSectionHeight - boxHeight*2 - 7)
			self:zoom(0.4)
			if IsNetSMOnline() and IsSMOnlineLoggedIn(PLAYER_1) and NSMAN:IsETTP() then
				self:playcommand("Set")
			else
				self:visible(false)
			end
		end,
		SetCommand = function(self)
			self:settext("Common Pack\nFilter")
		end
	},
}

for i = 1, #filterFields["Lower"] do
	t[#t+1] = boundBoxes(i)	
end


-- The right container (The Tags Menu)
local function rightContainer()

	local boxHeight = 25
	local boxWidth = rightSectionWidth / 3

	local t = Def.ActorFrame {
		InitCommand = function(self)
			self:xy(20 + leftSectionWidth,30)
			updateTagsFromData()
			MESSAGEMAN:Broadcast("UpdateList")
		end,
		SaveNewTagCommand = function(self)
			if tagName ~= "" and ptags[tagName] == nil then
				tags:get_data().playerTags[tagName] = {}
				tags:set_dirty()
				tags:save()
				updateTagsFromData()
				MESSAGEMAN:Broadcast("UpdateList")
			end
		end,

		-- The container quad
		Def.Quad {
			InitCommand = function (self)
				self:zoomto(rightSectionWidth,rightSectionHeight)
				self:halign(0):valign(0)
				self:diffuse(getMainColor("frame"))
				self:diffusealpha(0.8)
			end,
			WheelUpSlowMessageCommand = function(self)
				if self:isOver() then
					movePage(-1)
				end
			end,
			WheelDownSlowMessageCommand = function(self)
				if self:isOver() then
					movePage(1)
				end
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(5,10)
				self:zoom(0.4)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("Manage Tags")
			end
		},
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(25, rightSectionHeight - 30)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(numBoxWidth + 15, 35)
			end,
			MouseDownCommand = function(self)
				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
				local tagname = function(ans) 
					tagName = ans
					self:GetParent():queuecommand("SaveNewTag")
				end
				easyInputStringWithFunction("Tag Name:", 255, false, tagname)
			end
		},
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(25 + (numBoxWidth+15)/2,rightSectionHeight - 30)
				self:zoom(0.4)
				self:settext("Create Tag")
			end
		},
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(25 + horizontalSpacing + numBoxWidth + 15, rightSectionHeight - 30)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(numBoxWidth + 15, 35)
			end,
			MouseDownCommand = function(self)
				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
				filterTags = {}
				GHETTOGAMESTATE.SSMTag = nil
				updateTagFilter()
				updateTagsFromData()
				MESSAGEMAN:Broadcast("UpdateList")
			end
		},
		LoadFont("Common Normal") .. {
			Name = "TagModeButtonText",
			InitCommand = function(self)
				self:xy(25 + horizontalSpacing + numBoxWidth + 15 + (numBoxWidth+15)/2,rightSectionHeight - 30)
				self:zoom(0.4)
				self:settext("Reset\nTag Filter")
			end
		},
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(25 + horizontalSpacing*2 + (numBoxWidth + 15)*2, rightSectionHeight - 30)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(numBoxWidth + 15, 35)
			end,
			MouseDownCommand = function(self)
				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
				if tagFilterMode then
					tagFilterMode = false
					GHETTOGAMESTATE:setTagFilterMode(false)
				else
					tagFilterMode = true
					GHETTOGAMESTATE:setTagFilterMode(true)
				end
				self:GetParent():queuecommand("Set")
			end
		},
		LoadFont("Common Normal") .. {
			Name = "TagModeButtonText",
			InitCommand = function(self)
				self:xy(25 + horizontalSpacing*2 + (numBoxWidth + 15)*2 + (numBoxWidth+15)/2,rightSectionHeight - 30)
				self:zoom(0.4)
				self:queuecommand("Set")
			end,
			SetCommand = function(self)
				if tagFilterMode then
					self:settext("Mode: And")
				else
					self:settext("Mode: Or")
				end
			end
		},
		LoadFont("Common Normal") .. {
			Name = "TagModeExplanation",
			InitCommand = function(self)
				local xpos = capWideScale(25 + horizontalSpacing + numBoxWidth + 15 + (numBoxWidth+15)/2, 25 + horizontalSpacing*3 + (numBoxWidth + 15)*3) -- hilarious hack
				local ypos = rightSectionHeight - capWideScale(55,30) -- no really lmao
				self:xy(xpos, ypos)
				self:zoom(0.4)
				self:halign(0)
				self:queuecommand("Set")
				self:maxwidth(numBoxWidth * 5)
			end,
			SetCommand = function(self)
				if tagFilterMode then
					self:settext("Matches have all chosen Tags")
				else
					self:settext("Matches have any chosen Tag")
				end
			end
		}
	}

	-- this is copied straight from the pack downloader screen
	-- theming is so easy lol
	local function tagItem(i)
		local tagIndex = (curPage-1)*20+i

		local r = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(25 + boxWidth*1.5*((tagIndex-1) % maxTags >= 10 and 1 or 0), 30 + ((i-1) % math.floor(maxTags/2))*(boxHeight+verticalSpacing)-10)
				if playertags[tagIndex] then
					self:playcommand("Show")
				end
			end,
			ShowCommand = function(self)
				self:y(30 + ((i-1) % math.floor(maxTags/2))*(boxHeight+verticalSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(30 + ((i-1) % math.floor(maxTags/2))*(boxHeight+verticalSpacing)+25)
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:finishtweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self)
				tagIndex = (curPage-1)*20+i
				if playertags[tagIndex] ~= nil then
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end
		}

		-- Tag index number
		r[#r+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				self:settextf("%d", tagIndex)
			end
		}

		-- The tag button
		r[#r+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(boxWidth, boxHeight)
			end,
			MouseDownCommand = function(self, params)
				if playertags[tagIndex] ~= nil then
					self:finishtweening()
					if params.button == "DeviceButton_left mouse button" then
						self:diffusealpha(0.4)
						self:smooth(0.3)
						self:diffusealpha(0.2)
						if filterTags[playertags[tagIndex]] then
							filterTags[playertags[tagIndex]] = nil
							if playertags[tagIndex] == GHETTOGAMESTATE.SSMTag then
								GHETTOGAMESTATE.SSMTag = nil
							end
						else
							filterTags[playertags[tagIndex]] = 1
						end
						updateTagFilter()
						self:GetParent():GetChild("Status"):queuecommand("Set")
					elseif params.button == "DeviceButton_right mouse button" then
						tags:get_data().playerTags[playertags[tagIndex]] = nil
						playertags[tagIndex] = nil
						tags:set_dirty()
						tags:save()
						updateTagsFromData()
						MESSAGEMAN:Broadcast("UpdateList")
					end
				end
			end
		}

		-- Tag name
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(10,0):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				self:settextf("%s",playertags[tagIndex])
				self:maxwidth(boxWidth * 2)
			end
		}

		-- Color for the button to show filter status
		r[#r+1] = Def.Quad{
			Name = "Status",
			InitCommand = function(self)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().main.highlight))
				self:diffusealpha(0.8)
				self:xy(0, 0)
				self:zoomto(4, boxHeight)
			end,
			SetCommand = function(self)
				if filterTags[playertags[tagIndex]] then
					self:diffuse(getMiscColor("TagPositive")):diffusealpha(0.8)
				else
					self:diffuse(getMiscColor("TagNegative")):diffusealpha(0.8)
				end
			end
		}

		return r
	end

	for i = 1, maxTags do
		t[#t+1] = tagItem(i)
	end

	return t
end

t[#t+1] = rightContainer()

t[#t+1] = LoadActor("../_cursor")

return t
