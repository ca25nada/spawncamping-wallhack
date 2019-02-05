local maxTags = 16
local maxPages = 1
local curPage = 1
local ptags = tags:get_data().playerTags
local playertags = {}
local filterTags = GHETTOGAMESTATE:getFilterTags()
local tagName
local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
local ck = steps:GetChartKey()

local function updateTagsFromData()
	ptags = tags:get_data().playerTags
	playertags = {}
	for k,v in pairs(ptags) do
		playertags[#playertags+1] = k
	end
	table.sort(playertags, function(left, right)
		return ptags[left][ck] ~= nil and ptags[right][ck] == nil
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

local function input(event)
	
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
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
	end


	return false
end

local top
local leftSectionWidth = 300
local leftSectionHeight = SCREEN_HEIGHT - 60
local leftUpperSectionHeight = leftSectionHeight / 3
local leftLowerSectionHeight = leftSectionHeight / 2 + 63
local rightSectionWidth = 430
local rightSectionHeight = SCREEN_HEIGHT - 140

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

t[#t+1] = LoadActor("../_mouse")

t[#t+1] = LoadActor("../_frame")

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
			self:settext("Tagging")
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(5,25)
			self:zoom(0.35)
			self:halign(0)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Left click a Tag to Assign this file that tag.\n\nRight click a Tag to delete.\n\nYou can filter songs by Tag in the Filtering menu.\n\nAssigned tags show up darker than others.")
		end
	},
	quadButton(6) .. {
		InitCommand = function(self)
			self:xy(25, leftLowerSectionHeight - 30)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(numBoxWidth + 15, 35)
		end,
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			local tagname = function(ans) 
				tagName = ans
				self:GetParent():GetParent():GetChild("TagContainer"):queuecommand("SaveNewTag")
			end
			easyInputStringWithFunction("Tag Name:", 255, false, tagname)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(25 + (numBoxWidth+15)/2,leftLowerSectionHeight - 30)
			self:zoom(0.4)
			self:settext("Create Tag")
		end
	}
}

-- The right container (The Tags Menu)
local function rightContainer()

	local boxHeight = 25
	local boxWidth = rightSectionWidth / 3

	local t = Def.ActorFrame {
		Name = "TagContainer",
		InitCommand = function(self)
			self:xy(20 + leftSectionWidth,110)
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
				movePage(-1)
			end,
			WheelDownSlowMessageCommand = function(self)
				movePage(1)
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(5,10)
				self:zoom(0.4)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("Assign Tags")
			end
		}
	}

	-- this is copied straight from the pack downloader screen
	-- theming is so easy lol
	local function tagItem(i)
		local tagIndex = (curPage-1)*10+i

		local r = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(25 + boxWidth*1.5*((tagIndex-1) % maxTags >= maxTags/2 and 1 or 0), 30 + ((i-1) % math.floor(maxTags/2))*(boxHeight+verticalSpacing)-10)
				self:playcommand("Show")
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
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self)
				tagIndex = (curPage-1)*10+i
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
			TopPressedCommand = function(self, params)
				if playertags[tagIndex] ~= nil then
					self:finishtweening()
					if params.input ~= "DeviceButton_left mouse button" then
						return
					end
					self:diffusealpha(0.4)
					self:smooth(0.3)
					self:diffusealpha(0.2)
					if ptags[playertags[tagIndex]][ck] then
						tags:get_data().playerTags[playertags[tagIndex]][ck] = nil
					else
						tags:get_data().playerTags[playertags[tagIndex]][ck] = 1
					end
					tags:set_dirty()
					tags:save()
					updateTagsFromData()
				end
			end,
			SetCommand = function(self)
				self:diffusealpha(0.2)
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
