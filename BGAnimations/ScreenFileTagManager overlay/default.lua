local maxTags = 16
local maxPages = 1
local curPage = 1
local ptags = tags:get_data().playerTags
local playertags = {}
local filterTags = GHETTOGAMESTATE:getFilterTags()
local tagName
local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
local ck = steps:GetChartKey()
local song = GAMESTATE:GetCurrentSong()

local function updateTagsFromData()
	ptags = tags:get_data().playerTags
	playertags = {}
	for k,v in pairs(ptags) do
		playertags[#playertags+1] = k
	end
	table.sort(playertags, function(left, right)
		if ptags[left][ck] == ptags[right][ck] then
			return left:lower() < right:lower()
		else
			return ptags[left][ck] ~= nil and ptags[right][ck] == nil
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
local rightSectionWidth = SCREEN_WIDTH/2 - capWideScale(10,-95)
local rightSectionHeight = SCREEN_HEIGHT - 140

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

t[#t+1] = LoadActor("../_mouse", "ScreenFileTagManager")

t[#t+1] = LoadActor("../_frame")

local function topRow()
	local frameWidth = SCREEN_WIDTH - 20
	local frameHeight = 40

	local t = Def.ActorFrame{
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth, frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
		end
	}

	t[#t+1] = Def.Sprite {
		Name = "Banner",
		InitCommand = function(self)
			self:x(-frameWidth/2 + 5)
			self:halign(0)
			local bnpath = song:GetBannerPath()
			if not bnpath then
				bnpath = THEME:GetPathG("Common", "fallback banner")
			end
			self:LoadBackground(bnpath)
			self:scaletoclipped(96, 30)
		end
	}

	t[#t+1] = LoadFont("Common BLarge") .. {
		Name = "SongTitle",
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, -9)
			self:zoom(0.25)
			self:halign(0)
			self:settext(song:GetMainTitle())
			if #song:GetDisplaySubTitle() == 0 then
				self:zoom(0.35):y(-5)
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			local actor = self:GetParent():GetChild("SongTitle")
			local x = actor:GetX() + actor:GetWidth()*actor:GetZoomX() + 2
			local y = actor:GetY() - 2

			self:xy(x,y)
			self:zoom(0.3)
			self:halign(0)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			local length = song:GetStepsSeconds()/getCurRateValue()
			self:settextf("%s",SecondsToMSS(length))
			self:diffuse(getSongLengthColor(length))
		end,
		CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end
	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, 1)
			self:zoom(0.35)
			self:halign(0)
			self:settext(song:GetDisplaySubTitle())
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, 9)
			self:zoom(0.35)
			self:halign(0)
			self:settext("// "..song:GetDisplayArtist())
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-1)
			self:zoom(0.5)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end,
		SetCommand = function(self, params)
			local curSteps = params.steps
			local diff = curSteps:GetDifficulty()
			local stype = curSteps:GetStepsType()
			local meter = math.floor(curSteps:GetMSD(getCurRateValue(),1))
			if meter == 0 then
				meter = curSteps:GetMeter()
			end

			local difftext
			if diff == 'Difficulty_Edit' then
				difftext = curSteps:GetDescription()
				difftext = difftext == '' and getDifficulty(diff) or difftext
			else
				difftext = getDifficulty(diff)
			end

			self:settext(ToEnumShortString(stype):gsub("%_"," ").." "..difftext.." "..meter)
			self:diffuse(getDifficultyColor(GetCustomDifficulty(stype,diff)))
		end,
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end

	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,9)
			self:zoom(0.35)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end,
		SetCommand = function(self, params)
			local curSteps = params.steps
			local notes = 0
			if curSteps ~= nil then
				notes = curSteps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			end
			self:settextf("%d Notes", notes)
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(curSteps:GetStepsType(),curSteps:GetDifficulty())),0.3))
		end,
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability",
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-11)
			self:zoom(0.30)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end,
		SetCommand = function(self, params)
			local curSteps = params.steps
			if curSteps ~= nil then

				local meter = math.floor(curSteps:GetMSD(getCurRateValue(),1))
				if meter == 0 then
					self:settext("Default")
					self:diffuse(color(colorConfig:get_data().main.disabled))
				else
					self:settext("MSD")
					self:diffuse(color(colorConfig:get_data().main.enabled))
				end
			end
		end,
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2+1,-frameHeight/2+1)
			self:zoom(0.3)
			self:wag()
			self:diffuse(Color.Yellow)

			if not song:IsFavorited() then
				self:visible(false)
			end
		end
	}

	return t
end

-- The lower left container (The Filter Menu)
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(10,30 + leftUpperSectionHeight + verticalSpacing)
	end,

	Def.Quad {
		InitCommand = function (self)
			self:zoomto(leftSectionWidth,leftLowerSectionHeight/2)
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
			self:settext("Left click a Tag to assign this file that tag.\nRight click a Tag to unassign the tag.\nYou can filter songs by Tag in the Filtering menu.\nAssigned tags have a distinct color from others.")
		end
	},
	quadButton(6) .. {
		InitCommand = function(self)
			self:xy(15, leftLowerSectionHeight/2 - 30)
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
				self:GetParent():GetParent():GetChild("TagContainer"):queuecommand("SaveNewTag")
			end
			easyInputStringWithFunction("Tag Name:", 255, false, tagname)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(15 + (numBoxWidth+15)/2,leftLowerSectionHeight/2 - 30)
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
				self:settext("Assign Tags")
			end
		}
	}

	-- this is copied straight from the pack downloader screen
	-- theming is so easy lol
	local function tagItem(i)
		local tagIndex = (curPage-1)*maxTags+i

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
				self:sleep((i-1)*0.01)
				self:easeOut(0.3)
				self:y(30 + ((i-1) % math.floor(maxTags/2))*(boxHeight+verticalSpacing)+25)
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self)
				tagIndex = (curPage-1)*maxTags+i
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
					if params.button == "DeviceButton_left mouse button" then
						if not ptags[playertags[tagIndex]][ck] then
							tags:get_data().playerTags[playertags[tagIndex]][ck] = 1
							tags:set_dirty()
							tags:save()
							updateTagsFromData()
							MESSAGEMAN:Broadcast("UpdateList")
						end
					elseif params.button == "DeviceButton_right mouse button" then
						if ptags[playertags[tagIndex]][ck] then
							tags:get_data().playerTags[playertags[tagIndex]][ck] = nil
							tags:set_dirty()
							tags:save()
							updateTagsFromData()
							MESSAGEMAN:Broadcast("UpdateList")
						end
					end
				end
			end,
			SetCommand = function(self)
				if ptags[playertags[tagIndex]][ck] then
					self:diffusealpha(0.4)
				else
					self:diffusealpha(0.2)
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

		-- Color for the button to show assign status
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
				if ptags[playertags[tagIndex]][ck] then
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

t[#t+1] = topRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
		self:delayedFadeIn(0)
	end
}

t[#t+1] = rightContainer()

t[#t+1] = LoadActor("../_cursor")

return t
