local profile = GetPlayerOrMachineProfile(PLAYER_1)
profile:SetFromAll()
local maxGoals = 11
local curPage = 1
local song = GAMESTATE:GetCurrentSong()
local goaltable = profile:GetGoalTable()
local maxPages = math.ceil(#goaltable/maxGoals)
local inDetail = false

local function updateGoalsFromData()
	profile:SortByName()
	goaltable = profile:GetGoalTable()
	GHETTOGAMESTATE:resetGoalTable()
	curPage = 1
	maxPages = math.ceil(#goaltable/maxGoals)
end

local function byAchieved(scoregoal)
	if not scoregoal or scoregoal:IsAchieved() then
		return getMainColor("positive")
	end
	if scoregoal:IsVacuous() then
		return color("#ffcccc")
	end
	return color("#cccccc")
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
local leftLowerSectionHeight = SCREEN_HEIGHT / 1.5 - 10
local rightSectionWidth = SCREEN_WIDTH - 330
local rightSectionHeight = SCREEN_HEIGHT - 60

local verticalSpacing = 7
local horizontalSpacing = 10


local t = Def.ActorFrame {
	OnCommand = function(self)
		everything = self
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
	end,
	DFRFinishedMessageCommand = function(self) -- not sure this would even normally happen on this screen but just in case
		profile:SetFromAll()
		updateGoalsFromData()
		self:queuecommand("UpdateList")
	end
}

local boxHeight = 20
local numBoxWidth = leftSectionWidth / 2

t[#t+1] = LoadActor("../_mouse", "ScreenGoalManager")

t[#t+1] = LoadActor("../_frame")

local frameWidth = 430
local frameHeight = 340

-- The upper left container (Minimal Profile Card)
local function upperLeftContainer()

	local t = Def.ActorFrame {
		Name = "ProfileCard",
		InitCommand = function(self)
			self:xy(10,30)
		end,

		Def.Quad {
			InitCommand = function(self)
				self:halign(0):valign(0)
				self:zoomto(300,100)
				self:diffuse(color(colorConfig:get_data().main.frame)):diffusealpha(0.85)
			end
		}
	}

	t[#t+1] = LoadActor("../ScreenPlayerProfile decorations/avatar") .. {
		InitCommand = function(self)
			self:xy(50,50)
		end
	}

	t[#t+1] = LoadFont("Common BLarge") .. {
		InitCommand = function(self)
			self:xy(100,25)
			self:zoom(0.35)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			self:settext(getCurrentUsername(PLAYER_1))
		end
	}

	t[#t+1] = LoadActor("../ScreenPlayerProfile decorations/expbar") .. {
		InitCommand = function(self)
			self:xy(100,55)
		end
	}

	return t
end

-- The lower left container (The Tag Editor)
local function lowerLeftContainer()

	local goalIndex -- im really killing the scope here haha

	local t = Def.ActorFrame {
		Name = "EditorContainer",
		InitCommand = function(self)
			self:xy(10, leftUpperSectionHeight)
		end,
		HideGoalDetailMessageCommand = function(self)
		end,

		-- The container quad
		Def.Quad {
			InitCommand = function(self)
				self:zoomto(leftSectionWidth, leftLowerSectionHeight)
				self:halign(0):valign(0)
				self:diffuse(getMainColor("frame"))
				self:diffusealpha(0.85)
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(5,10)
				self:zoom(0.4)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("Edit Goal")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(leftSectionWidth/2,25)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("Title")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(leftSectionWidth/2,50)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("MSD")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(leftSectionWidth/2,75)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("Current PB")
			end
		},
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(leftSectionWidth/2,34)
				self:zoom(0.35)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("")
				self:maxwidth(leftSectionWidth * 2.3)
			end,
			SetCommand = function(self)
				local ck = goaltable[goalIndex]:GetChartKey()
				local goalsong = SONGMAN:GetSongByChartKey(ck)
				if goalsong then
					self:settextf("%s",goalsong:GetDisplayMainTitle())
				else
					self:settextf("%s", ck)
				end
			end,
			ShowGoalDetailMessageCommand = function(self, params)
				goalIndex = params.goalIndex
				self:queuecommand("Set")
			end,
			HideGoalDetailMessageCommand = function(self)
				self:settext("")
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(leftSectionWidth/2,59)
				self:zoom(0.35)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("")
				self:maxwidth(leftSectionWidth * 2.3)
			end,
			SetCommand = function(self)
				local ck = goaltable[goalIndex]:GetChartKey()
				local goalsong = SONGMAN:GetSongByChartKey(ck)
				local goalsteps = SONGMAN:GetStepsByChartKey(ck)
				if goalsteps and goaltable[goalIndex] then
					local msd = goalsteps:GetMSD(goaltable[goalIndex]:GetRate(), 1)
					self:settextf("%5.1f", msd)
					self:diffuse(byMSD(msd))
				else
					self:settext("??")
				end
			end,
			ShowGoalDetailMessageCommand = function(self, params)
				goalIndex = params.goalIndex
				self:queuecommand("Set")
			end,
			HideGoalDetailMessageCommand = function(self)
				self:settext("")
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(leftSectionWidth/2,84)
				self:zoom(0.35)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("")
				self:maxwidth(leftSectionWidth * 2.3)
			end,
			SetCommand = function(self)
				local pb = goaltable[goalIndex]:GetPBUpTo()
				if pb then
					if pb:GetMusicRate() < goaltable[goalIndex]:GetRate() then
						local ratestring = string.format("%.2f", pb:GetMusicRate()):gsub("%.?0$", "") .. "x"
						self:settextf("Best: %5.2f%% (%s)", pb:GetWifeScore() * 100, ratestring)
					else
						self:settextf("Best: %5.2f%%", pb:GetWifeScore() * 100)
					end
					self:diffuse(getGradeColor(pb:GetWifeGrade()))
					self:visible(true)
				else
					self:settextf("(Best: %5.2f%%)", 0)
					self:diffuse(byAchieved(goaltable[goalIndex]))
				end
			end,
			ShowGoalDetailMessageCommand = function(self, params)
				goalIndex = params.goalIndex
				self:queuecommand("Set")
			end,
			HideGoalDetailMessageCommand = function(self)
				self:settext("")
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:queuecommand("Set")
			end
		}
	}
	local function rateChangeButton()
		local topRowFrameWidth = SCREEN_WIDTH - 20
		local topRowFrameHeight = 40
		local frameWidth = 150
		local frameHeight = 25
		local goalIndex
		local t = Def.ActorFrame {
			Name = "RateChangeButton",
			InitCommand = function(self)
				self:xy(leftSectionWidth/2 + frameWidth/2,150)
			end,
			ShowGoalDetailMessageCommand = function(self, params)
				goalIndex = params.goalIndex
				self:queuecommand("Set")
			end
		}

		t[#t+1] = LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(-frameWidth/2, -22)
				self:zoom(0.35)
				self:settext("Change Rate")
			end
		}

		t[#t+1] = Def.Quad{
			InitCommand = function(self)
				self:zoomto(frameWidth, 25)
				self:diffuse(color("#000000")):diffusealpha(0.8)
				self:halign(1)
			end
		}

		t[#t+1] = quadButton(6)..{
			InitCommand = function(self)
				self:zoomto(frameWidth/2, frameHeight)
				self:x(-frameWidth/2)
				self:diffuse(color("#FFFFFF")):diffusealpha(0)
				self:halign(1)
				self:faderight(0.5)
			end,
			MouseDownCommand = function(self)
				if inDetail then
					goaltable[goalIndex]:SetRate(goaltable[goalIndex]:GetRate() - 0.05)
					MESSAGEMAN:Broadcast("UpdateGoalDetails")
					self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")

					self:finishtweening()
					self:diffusealpha(0.2)
					self:smooth(0.3)
					self:diffusealpha(0)
				end
			end
		}
		t[#t+1] = quadButton(6)..{
			InitCommand = function(self)
				self:zoomto(frameWidth/2, frameHeight)
				self:diffuse(color("#FFFFFF")):diffusealpha(0)
				self:halign(1)
				self:fadeleft(0.5)
			end,
			MouseDownCommand = function(self)
				if inDetail then
					goaltable[goalIndex]:SetRate(goaltable[goalIndex]:GetRate() + 0.05)
					MESSAGEMAN:Broadcast("UpdateGoalDetails")
					self:GetParent():GetChild("TriangleRight"):playcommand("Tween")

					self:finishtweening()
					self:diffusealpha(0.2)
					self:smooth(0.3)
					self:diffusealpha(0)
				end
			end
		}


		t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
			Name = "TriangleLeft",
			InitCommand = function(self)
				self:zoom(0.15)
				self:x(-frameWidth + 10)
				self:diffusealpha(0.8)
				self:rotationz(-90)
			end,
			TweenCommand = function(self)
				self:finishtweening()
				self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
				self:smooth(0.5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
			end
		}

		t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
			Name = "TriangleRight",
			InitCommand = function(self)
				self:zoom(0.15)
				self:x(-10)
				self:diffusealpha(0.8)
				self:rotationz(90)
			end,
			TweenCommand = function(self)
				self:finishtweening()
				self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
				self:smooth(0.5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
			end
		}

		t[#t+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:x(-frameWidth/2)
				self:zoom(0.3)
				self:queuecommand("Set")
			end,
			SetCommand = function(self, params)
				if goaltable[goalIndex] then
					local ratestring = string.format("%.2f", goaltable[goalIndex]:GetRate()):gsub("%.?0$", "") .. "x"
					self:settext(ratestring)
				end
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:playcommand("Set")
			end,
			HideGoalDetailMessageCommand = function(self)
				self:settext("")
			end
		}

		return t
	end

	local function percentChangeButton()
		local topRowFrameWidth = SCREEN_WIDTH - 20
		local topRowFrameHeight = 40
		local frameWidth = 150
		local frameHeight = 25
		local goalIndex
		local t = Def.ActorFrame {
			Name = "PercentChangeButton",
			InitCommand = function(self)
				self:xy(leftSectionWidth/2 + frameWidth/2,200)
			end,
			ShowGoalDetailMessageCommand = function(self, params)
				goalIndex = params.goalIndex
				self:queuecommand("Set")
			end
		}

		t[#t+1] = LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(-frameWidth/2, -22)
				self:zoom(0.35)
				self:settext("Change Goal Percent")
			end
		}

		t[#t+1] = Def.Quad{
			InitCommand = function(self)
				self:zoomto(frameWidth, 25)
				self:diffuse(color("#000000")):diffusealpha(0.8)
				self:halign(1)
			end
		}

		t[#t+1] = quadButton(6)..{
			InitCommand = function(self)
				self:zoomto(frameWidth/2, frameHeight)
				self:x(-frameWidth/2)
				self:diffuse(color("#FFFFFF")):diffusealpha(0)
				self:halign(1)
				self:faderight(0.5)
			end,
			MouseDownCommand = function(self)
				if inDetail then
					goaltable[goalIndex]:SetPercent(goaltable[goalIndex]:GetPercent() - 0.01)
					MESSAGEMAN:Broadcast("UpdateGoalDetails")
					self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")

					self:finishtweening()
					self:diffusealpha(0.2)
					self:smooth(0.3)
					self:diffusealpha(0)
				end
			end
		}
		t[#t+1] = quadButton(6)..{
			InitCommand = function(self)
				self:zoomto(frameWidth/2, frameHeight)
				self:diffuse(color("#FFFFFF")):diffusealpha(0)
				self:halign(1)
				self:fadeleft(0.5)
			end,
			MouseDownCommand = function(self)
				if inDetail then
					goaltable[goalIndex]:SetPercent(goaltable[goalIndex]:GetPercent() + 0.01)
					MESSAGEMAN:Broadcast("UpdateGoalDetails")
					self:GetParent():GetChild("TriangleRight"):playcommand("Tween")

					self:finishtweening()
					self:diffusealpha(0.2)
					self:smooth(0.3)
					self:diffusealpha(0)
				end
			end
		}


		t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
			Name = "TriangleLeft",
			InitCommand = function(self)
				self:zoom(0.15)
				self:x(-frameWidth + 10)
				self:diffusealpha(0.8)
				self:rotationz(-90)
			end,
			TweenCommand = function(self)
				self:finishtweening()
				self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
				self:smooth(0.5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
			end
		}

		t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
			Name = "TriangleRight",
			InitCommand = function(self)
				self:zoom(0.15)
				self:x(-10)
				self:diffusealpha(0.8)
				self:rotationz(90)
			end,
			TweenCommand = function(self)
				self:finishtweening()
				self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
				self:smooth(0.5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
			end
		}

		t[#t+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:x(-frameWidth/2)
				self:zoom(0.3)
				self:queuecommand("Set")
			end,
			SetCommand = function(self, params)
				if goaltable[goalIndex] then
					local perc = math.floor(goaltable[goalIndex]:GetPercent() * 10000) / 100
					if perc < 99 then
						self:settextf("%.f%%", perc)
					else
						self:settextf("%.2f%%", perc)
					end
				end
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:playcommand("Set")
			end,
			HideGoalDetailMessageCommand = function(self)
				self:settext("")
			end
		}

		return t
	end

	local function deleteButton()
		local goalIndex
		local t = Def.ActorFrame {
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(15, leftLowerSectionHeight/2 - 30)
					self:halign(0)
					self:diffusealpha(0.2)
					self:zoomto(numBoxWidth + 15, 35)
				end,
				ShowGoalDetailMessageCommand = function(self, params)
					goalIndex = params.goalIndex
				end,
				MouseDownCommand = function(self)
					if goaltable[goalIndex] and inDetail then
						goaltable[goalIndex]:Delete()
						profile:SetFromAll()
						updateGoalsFromData()
						MESSAGEMAN:Broadcast("HideGoalDetail")
						MESSAGEMAN:Broadcast("UpdateList")
						self:finishtweening()
						self:diffusealpha(0.4)
						self:smooth(0.3)
						self:diffusealpha(0.2)
					end
				end
			},
			LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(15 + (numBoxWidth+15)/2,leftLowerSectionHeight/2 - 30)
					self:zoom(0.4)
					self:settext("Delete Goal")
				end
			}
		}
		return t
	end

	t[#t+1] = deleteButton() .. {
		InitCommand = function(self)
			self:xy(-15 + leftSectionWidth/2 - (numBoxWidth+15)/2, leftLowerSectionHeight/2)
		end
	}

	t[#t+1] = rateChangeButton()

	t[#t+1] = percentChangeButton()

	return t
end

-- The right container (The Tags Menu)
local function rightContainer()

	local boxHeight = 25
	local boxWidth = rightSectionWidth - 40

	local t = Def.ActorFrame {
		Name = "GoalContainer",
		InitCommand = function(self)
			self:xy(20 + leftSectionWidth,30)
			MESSAGEMAN:Broadcast("UpdateList")
		end,

		-- The container quad
		quadButton(1) .. {
			InitCommand = function (self)
				self:zoomto(rightSectionWidth,rightSectionHeight)
				self:halign(0):valign(0)
				self:diffuse(getMainColor("frame"))
				self:diffusealpha(0.85)
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
			end,
			MouseRightClickMessageCommand = function(self)
				if inDetail and self:isOver() then
					self:sleep(0.05)
					self:queuecommand("DelayedHide")
				end
			end,
			DelayedHideCommand = function(self)
				MESSAGEMAN:Broadcast("HideGoalDetail")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(5,10)
				self:zoom(0.4)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:settext("Manage Goals")
			end
		},
		LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(7,25)
			self:zoom(0.35)
			self:halign(0)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:maxwidth((rightSectionWidth-15)/0.35)
			self:settext("Left click a Goal to jump to the song for it. Right click a Goal to edit it in the left section.")
		end
		},
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(100,10)
				self:zoom(0.35)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:maxwidth((rightSectionWidth-110)/0.35)
				self:settext("Create a goal for a song by pressing Ctrl + G while on it.")
			end
		}
	}

	-- this is copied straight from the filter screen which is copied from the downloader screen
	-- theming is so easy lol
	local function goalItem(i)
		local goalIndex = (curPage-1)*10+i
		local goalsong
		local goalsteps
		local ck
		local theDetail

		local r = Def.ActorFrame{
			Name = "GoalItem"..i,
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(25, 30 + ((i-1) *(boxHeight+verticalSpacing)-10))
				self:playcommand("Show")
			end,
			ShowCommand = function(self)
				self:y(30 + ((i-1)*(boxHeight+verticalSpacing)-10))
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.01)
				self:easeOut(0.3)
				self:y(30 + ((i-1)*(boxHeight+verticalSpacing)+25))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:finishtweening()
				self:easeOut(0.2)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self)
				goalIndex = (curPage-1)*10+i
				theDetail = false
				inDetail = false
				if goaltable[goalIndex] ~= nil then
					ck = goaltable[goalIndex]:GetChartKey()
					goalsong = SONGMAN:GetSongByChartKey(ck)
					goalsteps = SONGMAN:GetStepsByChartKey(ck)
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end,
			ShowGoalDetailMessageCommand = function(self, params)
				if params.index == i then
					theDetail = true
					self:diffusealpha(1)
				else
					if goaltable[goalIndex] ~= nil then
						self:diffusealpha(0.5)
					end
				end
			end,
			HideGoalDetailMessageCommand = function(self)
				theDetail = false
				inDetail = false
				if goaltable[goalIndex] ~= nil then
					self:finishtweening()
					self:easeOut(0.5)
					self:diffusealpha(1)
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
				self:settextf("%d", goalIndex)
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
				if goaltable[goalIndex] ~= nil then
					if params.button == "DeviceButton_left mouse button" then
						if goaltable[goalIndex] and goalsong and goalsteps and ((inDetail and theDetail) or not inDetail) then
							MESSAGEMAN:Broadcast("TriggerExitFromPS",{song = goalsong})
							GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(goaltable[goalIndex]:GetRate())
							GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(goaltable[goalIndex]:GetRate())
							GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(goaltable[goalIndex]:GetRate())
							SCREENMAN:GetTopScreen():Cancel()
						end
					elseif params.button == "DeviceButton_right mouse button" then
						if goaltable[goalIndex] and not inDetail then
							inDetail = true
							MESSAGEMAN:Broadcast("ShowGoalDetail", {index = i, goalIndex = goalIndex})
						end
					end
				end
			end
		}

		-- File name
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(45,-5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
				self:maxwidth((boxWidth - capWideScale(90,135) - 50)/0.4)
			end,
			SetCommand = function(self)
				if goalsong then
					self:settextf("%s",goalsong:GetDisplayMainTitle())
				else
					self:settextf("%s", ck)
				end
			end
		}

		-- Goal percent
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(10,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
				self:maxwidth(boxWidth / 6)
			end,
			SetCommand = function(self)
				if goaltable[goalIndex] then
					local perc = math.floor(goaltable[goalIndex]:GetPercent() * 10000) / 100
					if perc < 99 then
						self:settextf("%.f%%", perc)
					else
						self:settextf("%.2f%%", perc)
					end
				end
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:queuecommand("Set")
			end
		}

		-- Best percent
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(45,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				local pb = goaltable[goalIndex]:GetPBUpTo()
				if pb then
					if pb:GetMusicRate() < goaltable[goalIndex]:GetRate() then
						local ratestring = string.format("%.2f", pb:GetMusicRate()):gsub("%.?0$", "") .. "x"
						self:settextf("Best: %5.2f%% (%s)", pb:GetWifeScore() * 100, ratestring)
					else
						self:settextf("Best: %5.2f%%", pb:GetWifeScore() * 100)
					end
					self:diffuse(getGradeColor(pb:GetWifeGrade()))
					self:visible(true)
				else
					self:settextf("(Best: %5.2f%%)", 0)
					self:diffuse(byAchieved(goaltable[goalIndex]))
				end
			end
		}

		-- Assigned date
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(boxWidth - capWideScale(90,135),5):halign(0)
				self:maxwidth(boxWidth / 2 + 25)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				self:settextf("Assigned: %s", goaltable[goalIndex]:WhenAssigned())
				self:diffuse(byAchieved(goaltable[goalIndex]))
			end
		}

		-- Achieved date
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(boxWidth - capWideScale(90,135),-5):halign(0)
				self:maxwidth(boxWidth / 2 + 25)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				if goaltable[goalIndex]:IsAchieved() then
					self:settextf("Achieved: %s", goaltable[goalIndex]:WhenAchieved())
				elseif goaltable[goalIndex]:IsVacuous() then
					self:settext("Vacuous goal")
				else
					self:settext("")
				end
				self:diffuse(byAchieved(goaltable[goalIndex]))
			end
		}

		-- MSD
		r[#r+1] = LoadFont("Common Bold")..{
			Name = "MSDString",
			InitCommand  = function(self)
				self:xy(boxWidth - 25,0):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				if goalsteps and goaltable[goalIndex] then
					local msd = goalsteps:GetMSD(goaltable[goalIndex]:GetRate(), 1)
					self:settextf("%5.1f", msd)
					self:diffuse(byMSD(msd))
				else
					self:settext("??")
				end
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:queuecommand("Set")
			end
		}

		-- Rate
		r[#r+1] = LoadFont("Common Bold")..{
			Name = "RateString",
			InitCommand  = function(self)
				self:xy(10,-5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				if goaltable[goalIndex] then
					local ratestring = string.format("%.2f", goaltable[goalIndex]:GetRate()):gsub("%.?0$", "") .. "x"
					self:settext(ratestring)
				end
			end,
			UpdateGoalDetailsMessageCommand = function(self)
				self:queuecommand("Set")
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
				if goalsteps and goalsong then
					local diff = goalsteps:GetDifficulty()
					self:diffuse(byDifficulty(diff))
				else
					self:diffuse(getMainColor("negative"))
				end
			end
		}

		return r
	end

	for i = 1, maxGoals do
		t[#t+1] = goalItem(i)
	end

	return t
end

t[#t+1] = upperLeftContainer()

t[#t+1] = lowerLeftContainer()

t[#t+1] = rightContainer()

t[#t+1] = LoadActor("../_cursor")

return t