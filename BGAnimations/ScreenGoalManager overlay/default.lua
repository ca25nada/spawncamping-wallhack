local profile = PROFILEMAN:GetProfile(PLAYER_1)
local maxGoals = 11
local curPage = 1
local song = GAMESTATE:GetCurrentSong()
local goaltable = profile:GetGoalTable()
local maxPages = math.ceil(#goaltable/maxGoals)

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
local leftLowerSectionHeight = leftSectionHeight / 2 + 63
local rightSectionWidth = SCREEN_WIDTH - 330
local rightSectionHeight = SCREEN_HEIGHT - 60

local verticalSpacing = 7
local horizontalSpacing = 10


local t = Def.ActorFrame {
	OnCommand = function(self)
		everything = self
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
	end,
	DFRFinishedMessageCommand = function(self) -- not sure this would even normally happen on this screen but just in case
		profile:SetFromAll()
		updateGoalsFromData()
		self:queuecommand("UpdateList")
	end
}

local boxHeight = 20
local numBoxWidth = leftSectionWidth / 5
local boundHorizontalSpacing = 8
local boundVerticalSpacing = 2

t[#t+1] = LoadActor("../_mouse")

t[#t+1] = LoadActor("../_frame")

local frameWidth = 430
local frameHeight = 340

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
			self:settext("Left click a Goal to jump to the song for it. Right click a Goal to modify it.")
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

		local r = Def.ActorFrame{
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
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self)
				goalIndex = (curPage-1)*10+i
				if goaltable[goalIndex] ~= nil then
					ck = goaltable[goalIndex]:GetChartKey()
					goalsong = SONGMAN:GetSongByChartKey(ck)
					goalsteps = SONGMAN:GetStepsByChartKey(ck)
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
			TopPressedCommand = function(self, params)
				if goaltable[goalIndex] ~= nil then
					if params.input == "DeviceButton_left mouse button" then
						if goaltable[goalIndex] and goalsong and goalsteps then
							MESSAGEMAN:Broadcast("TriggerExitFromPS",{song = goalsong})
							GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(goaltable[goalIndex]:GetRate())
							GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(goaltable[goalIndex]:GetRate())
							GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(goaltable[goalIndex]:GetRate())
							SCREENMAN:GetTopScreen():Cancel()
						end
					elseif params.input == "DeviceButton_right mouse button" then
						if goaltable[goalIndex] then
							
							MESSAGEMAN:Broadcast("UpdateList")
						end
					end
				end
			end,
			SetCommand = function(self)
				
			end
		}

		-- File name
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(45,-5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				if goalsong then
					self:settextf("%s",goalsong:GetDisplayMainTitle())
				else
					self:settextf("%s", ck)
				end
				self:maxwidth(boxWidth * 2)
			end
		}

		-- Goal percent
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(10,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				local perc = math.floor(goaltable[goalIndex]:GetPercent() * 10000) / 100
				if perc < 99 then
					self:settextf("%.f%%", perc)
				else
					self:settextf("%.2f%%", perc)
				end
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
				self:xy(boxWidth - 135,5):halign(0)
				self:maxwidth(boxWidth / 2)
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
				self:xy(boxWidth - 135,-5):halign(0)
				self:maxwidth(boxWidth / 2)
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
			InitCommand  = function(self)
				self:xy(boxWidth - 25,0):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				if goalsteps then
					local msd = goalsteps:GetMSD(goaltable[goalIndex]:GetRate(), 1)
					self:settextf("%5.1f", msd)
					self:diffuse(byMSD(msd))
				else
					self:settext("??")
				end
			end
		}

		-- Rate
		r[#r+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(10,-5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				local ratestring = string.format("%.2f", goaltable[goalIndex]:GetRate()):gsub("%.?0$", "") .. "x"
				self:settext(ratestring)
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

t[#t+1] = rightContainer()

t[#t+1] = LoadActor("../ScreenPlayerProfile decorations/profilecard") .. {
	InitCommand = function(self)
		self:xy(10,80)
		self:delayedFadeIn(0)
	end
}

t[#t+1] = LoadActor("../ScreenPlayerProfile decorations/ssrbreakdown") .. {
	InitCommand = function(self)
		self:xy(160,295)
		self:delayedFadeIn(1)
	end
}

t[#t+1] = LoadActor("../_cursor")

return t
