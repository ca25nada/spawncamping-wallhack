local t = Def.ActorFrame{
	InitCommand = function(self) 
		self:delayedFadeIn(6)
	end,
	OffCommand = function(self)
		self:sleep(0.05)
		self:smooth(0.2)
		self:diffusealpha(0) 
	end
}

local frameX = SCREEN_CENTER_X/2
local frameY = SCREEN_CENTER_Y+86
local maxMeter = 30
local frameWidth = capWideScale(get43size(390),390)
local frameHeight = 110
local frameHeightShort = 61
local song
local course
local ctags = {}
local filterTags = {}

local function wheelSearch()
	local search = GHETTOGAMESTATE:getMusicSearch()
	GHETTOGAMESTATE:getSSM():GetMusicWheel():SongSearch(search)
end

local function updateTagFilter(tag)
	local ptags = tags:get_data().playerTags
	local charts = {}

	local playertags = {}
	for k,v in pairs(ptags) do
		playertags[#playertags+1] = k
	end

	local filterTags = tag
	if filterTags then
		local toFilterTags = {}
		toFilterTags[1] = filterTags
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
	end
	local out = {}
	if tag ~= nil then out[tag] = 1	end
	GHETTOGAMESTATE:setFilterTags(out)
	GHETTOGAMESTATE:getSSM():GetMusicWheel():FilterByStepKeys(charts)
	wheelSearch()
end

local steps = {
	PlayerNumber_P1
}

local trail = {
	PlayerNumber_P1
}

local profile = {
	PlayerNumber_P1
}

local topScore = {
	PlayerNumber_P1
}

local hsTable = {
	PlayerNumber_P1
}

local function generalFrame(pn)
	local t = Def.ActorFrame{
		SetCommand = function(self)
			self:xy(frameX,frameY)
			self:visible(GAMESTATE:IsPlayerEnabled(pn))
		end,

		UpdateInfoCommand = function(self)
			song = GAMESTATE:GetCurrentSong()
			for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
				profile[pn] = GetPlayerOrMachineProfile(pn)
				steps[pn] = GAMESTATE:GetCurrentSteps(pn)
				topScore[pn] = getBestScore(pn, 0, getCurRate())
				if song and steps[pn] then
					ptags = tags:get_data().playerTags
					chartkey = steps[pn]:GetChartKey()
					ctags = {}
					for k,v in pairs(ptags) do
						if ptags[k][chartkey] then
							ctags[#ctags + 1] = k
						end
					end
				end
			end
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,

		BeginCommand = function(self) self:playcommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		PlayerUnjoinedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		CurrentSongChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		CurrentStepsP1ChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		CurrentRateChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end
	}

	--Upper Bar
	t[#t+1] = quadButton(2) .. {
		InitCommand = function(self)
			self:zoomto(frameWidth,frameHeight)
			self:valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	}

	if not IsUsingWideScreen() then
		t[#t+1] = Def.Quad {
			InitCommand = function(self)
				self:halign(0):valign(0)
				self:xy(frameX-14,frameHeight/2)
				self:zoomto(65,frameHeight/2)
				self:diffuse(getMainColor("frame"))
				self:diffusealpha(0.8)
			end
		}
	end

	-- Avatar background frame
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			self:stoptweening()
			self:smooth(0.5)
			self:diffuse(getBorderColor())
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffusealpha(0.8)
		end,
		BeginCommand = function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end
	}

	t[#t+1] = quadButton(3) .. {
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(50,50)
			self:visible(false)
		end,
		MouseDownCommand = function(self, params)
			if params.button == "DeviceButton_left mouse button" then
				SCREENMAN:AddNewScreenToTop("ScreenPlayerProfile")
			end
		end
	}

	-- Avatar
	t[#t+1] = Def.Sprite {
		InitCommand = function (self) self:xy(25+10-(frameWidth/2),5):playcommand("ModifyAvatar") end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end,
		PlayerUnjoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end,
		AvatarChangedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end,
		ModifyAvatarCommand = function(self)
			self:visible(true)
			self:Load(getAvatarPath(PLAYER_1))
			self:zoomto(50,50)
		end
	}

	-- Player name
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,9)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local text = ""
			if profile[pn] ~= nil then
				text = getCurrentUsername(pn)
				if text == "" then
					text = pn == PLAYER_1 and "Player 1" or "Player 2"
				end
			end
			self:settext(text)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end,
		LoginMessageCommand = function(self) self:queuecommand('Set') end,
		LogOutMessageCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,20)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local rating = 0
			local rank = 0
			local localrating = 0

			if DLMAN:IsLoggedIn() then
				rank = DLMAN:GetSkillsetRank("Overall")
				rating = DLMAN:GetSkillsetRating("Overall")
				localrating = profile[pn]:GetPlayerRating()

				self:settextf("Skill Rating: %0.2f  (%0.2f #%d Online)", localrating, rating, rank)
				self:AddAttribute(#"Skill Rating:", {Length = 7, Zoom =0.3 ,Diffuse = getMSDColor(localrating)})
				self:AddAttribute(#"Skill Rating: 00.00  ", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(rating)})
			else
				if profile[pn] ~= nil then
					localrating = profile[pn]:GetPlayerRating()
					self:settextf("Skill Rating: %0.2f",localrating)
					self:AddAttribute(#"Skill Rating:", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(localrating)})
				end

			end

		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end,
		LoginMessageCommand = function(self) self:queuecommand('Set') end,
		LogOutMessageCommand = function(self) self:queuecommand('Set') end,
		OnlineUpdateMessageCommand = function(self) self:queuecommand('Set') end
	}

	-- Level and exp
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,29)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			if profile[pn] ~= nil then
				local level = getLevel(getProfileExp(pn))
				local currentExp = getProfileExp(pn) - getLvExp(level)
				local nextExp = getNextLvExp(level)
				self:settextf("Lv.%d (%d/%d)",level, currentExp, nextExp)
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end
	}

	--Score Date
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-5,3)
			self:zoom(0.35)
		    self:halign(1):valign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText)):diffusealpha(0.5)
		end,
		SetCommand = function(self)
			if getScoreDate(topScore[pn]) == "" then
				self:settext("Date Achieved: 0000-00-00 00:00:00")
			else
				self:settext("Date Achieved: "..getScoreDate(topScore[pn]))
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	-- Steps info
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(5-frameWidth/2,40)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local diff,stype
			local notes,holds,rolls,mines,lifts = 0
			local difftext = ""

			if steps[pn] ~= nil then
				notes = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Notes")
				holds = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Holds")
				rolls = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Rolls")
				mines = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Mines")
				lifts = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Lifts")
				diff = steps[pn]:GetDifficulty()

			

				stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				self:settextf("Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",notes,holds,rolls,mines,lifts)
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="StepsAndMeter",
		InitCommand = function(self)
			self:xy(frameWidth/2-5,38)
			self:zoom(0.5)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			if steps[pn] ~= nil then

				local diff = steps[pn]:GetDifficulty()
				local stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				local meter = steps[pn]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[pn]:GetMeter()
				end
				meter = math.max(0,meter)

				local difftext
				if diff == 'Difficulty_Edit' and IsUsingWideScreen() then
					difftext = steps[pn]:GetDescription()
					difftext = difftext == '' and getDifficulty(diff) or difftext
				else
					difftext = getDifficulty(diff)
				end
				if IsUsingWideScreen() then
					self:settextf("%s %s %5.2f", stype, difftext, meter)
				else
					self:settextf("%s %5.2f", difftext, meter)
				end
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			else
				self:settext("")
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability",
		InitCommand = function(self)
			self:xy(frameWidth/2-5,27)
			self:zoom(0.3)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			if steps[pn] ~= nil then

				local meter = math.floor(steps[pn]:GetMSD(getCurRateValue(),1))
				if meter == 0 then
					self:settext("Default")
					self:diffuse(color(colorConfig:get_data().main.disabled))
				else
					self:settext("MSD")
					self:diffuse(color(colorConfig:get_data().main.enabled))
				end
			else
				self:settext("")
			end
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(5-(frameWidth/2),50)
			self:zoomto(frameWidth-10,10)
			self:halign(0)
			self:diffusealpha(1)
			self:diffuse(getMainColor("background"))
		end
	}

	-- Stepstype and Difficulty meter
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-10-frameWidth/2-2,50)
			self:zoom(0.3)
			self:settext(maxMeter)
		end,
		SetCommand = function(self)
			if steps[pn] ~= nil then
				local diff = getDifficulty(steps[pn]:GetDifficulty())
				local stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			end
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(5-(frameWidth/2),50)
			self:halign(0)
			self:zoomy(10)
			self:diffuse(getMainColor("highlight"))
		end,
		SetCommand = function(self)
			self:stoptweening()
			self:decelerate(0.5)
			local meter = 0
			local enabled = GAMESTATE:IsPlayerEnabled(pn)
			if enabled and steps[pn] ~= nil then
				meter = steps[pn]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[pn]:GetMeter()
				end
				self:zoomx((math.min(1,meter/maxMeter))*(frameWidth-10))
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			else
				self:zoomx(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,18)
			self:settext("Negative BPMs")
			self:zoom(0.4)
			self:halign(1)
			self:visible(false)
		end,
		SetCommand = function(self)
			if song and steps and steps[pn] then
				if steps[pn]:GetTimingData():HasWarps() then
					self:visible(true)
					return
				end
			end
			self:visible(false)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:y(50):zoom(0.3)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self) 
			self:stoptweening()
			self:decelerate(0.5)
			local meter = 0
			local enabled = GAMESTATE:IsPlayerEnabled(pn)
			if enabled and steps[pn] ~= nil then
				meter = steps[pn]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[pn]:GetMeter()
				end
				meter = math.max(1,meter)
				self:settextf("%0.2f", meter)
				self:x((math.min(1,meter/maxMeter))*(frameWidth-15)-frameWidth/2-3)
			else
				self:settext(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	--Grades
	t[#t+1] = LoadFont("Common BLarge")..{
		InitCommand = function(self)
			self:xy(60-frameWidth/2,frameHeight-35)
			self:zoom(0.6)
		    self:maxwidth(110/0.6)
		end,
		SetCommand = function(self)
			local grade = 'Grade_None'
			if topScore[pn] ~= nil then
				grade = topScore[pn]:GetWifeGrade()
			end
			self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
			self:diffuse(getGradeColor(grade))
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	--ClearType
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(60-frameWidth/2,frameHeight-15)
			self:zoom(0.4)
			self:maxwidth(110/0.4)
		end,
		SetCommand = function(self)
			self:stoptweening()

			local scoreList
			local clearType
			if profile[pn] ~= nil and song ~= nil and steps[pn] ~= nil then
				scoreList = getScoreTable(pn, getCurRate())
				clearType = getHighestClearType(pn,steps[pn],scoreList,0)
				self:settext(getClearTypeText(clearType))
				self:diffuse(getClearTypeColor(clearType))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	-- Percentage Score
	t[#t+1] = LoadFont("Common BLarge")..{
		InitCommand= function(self)
			self:xy(190-frameWidth/2,frameHeight-36)
			self:zoom(0.45):halign(1):maxwidth(75/0.45)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local scorevalue = 0
			if topScore[pn] ~= nil then
				scorevalue = getScore(topScore[pn], steps[pn], true)
			end
			self:settextf("%.2f%%",math.floor((scorevalue)*10000)/100)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}


	--Player DP/Exscore / Max DP/Exscore
	t[#t+1] = LoadFont("Common Normal")..{
		Name = "score", 
		InitCommand= function(self)
			self:xy(177-frameWidth/2,frameHeight-18)
			self:zoom(0.5):halign(1):maxwidth(26/0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self) 
			self:settext(getMaxScore(pn,0))
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(177-frameWidth/2,frameHeight-18)
			self:zoom(0.5):halign(1):maxwidth(50/0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self) 
			self:x(self:GetParent():GetChild("score"):GetX()-(math.min(self:GetParent():GetChild("score"):GetWidth(),27/0.5)*0.5))

			local scoreValue = 0
			if topScore[pn] ~= nil then
				scoreValue = getScore(topScore[pn], steps[pn], false)
			end
			self:settextf("%.0f/",scoreValue)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	--ScoreType superscript(?)
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(178-frameWidth/2,frameHeight-19)
			self:zoom(0.3)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		BeginCommand = function(self)
			self:settext(getScoreTypeText(1))
		end
	}

	--MaxCombo
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-40)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local score = getBestMaxCombo(pn,0, getCurRate())
			local maxCombo = 0
			maxCombo = getScoreMaxCombo(score)
			self:settextf("Max Combo: %d",maxCombo)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}


	--MissCount
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-28)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local score = getBestMissCount(pn, 0, getCurRate())
			if score ~= nil then
				self:settext("Miss Count: "..getScoreMissCount(score))
			else
				self:settext("Miss Count: -")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}


	-- EO rank placeholder
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-16)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			self:settextf("Ranking: %d/%d",0,0)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3,0)
			self:valign(1)
			self:halign(1)
			self:zoomto((frameWidth-75)/3,16)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0)
		end,
		SetCommand = function(self)
			if song and ctags[3] then
				if ctags[3] == GHETTOGAMESTATE.SSMTag then
					self:diffusealpha(0.6)
				else
					self:diffusealpha(0.8)
				end
			else
				self:diffusealpha(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		MouseDownCommand = function(self, params)
			if song and ctags[3] then
				if ctags[3] == GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_right mouse button" then
					GHETTOGAMESTATE.SSMTag = nil
					self:linear(0.1):diffusealpha(0.8)
					updateTagFilter(nil)
				elseif ctags[3] ~= GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_left mouse button" then
					GHETTOGAMESTATE.SSMTag = ctags[3]
					self:linear(0.1):diffusealpha(0.6)
					updateTagFilter(ctags[3])
				end
			end
		end
		
	}
	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3 - 2,0)
			self:valign(1)
			self:halign(1)
			self:zoomto((frameWidth-75)/3,16)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0)
		end,
		SetCommand = function(self)
			if song and ctags[2] then
				if ctags[2] == GHETTOGAMESTATE.SSMTag then
					self:diffusealpha(0.6)
				else
					self:diffusealpha(0.8)
				end
			else
				self:diffusealpha(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		MouseDownCommand = function(self, params)
			if song and ctags[2] then
				if ctags[2] == GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_right mouse button" then
					GHETTOGAMESTATE.SSMTag = nil
					self:linear(0.1):diffusealpha(0.8)
					updateTagFilter(nil)
				elseif ctags[2] ~= GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_left mouse button" then
					GHETTOGAMESTATE.SSMTag = ctags[2]
					self:linear(0.1):diffusealpha(0.6)
					updateTagFilter(ctags[2])
				end
			end
		end
		
	}
	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3*2 - 4,0)
			self:valign(1)
			self:halign(1)
			self:zoomto((frameWidth-75)/3,16)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0)
		end,
		SetCommand = function(self)
			if song and ctags[1] then
				if ctags[1] == GHETTOGAMESTATE.SSMTag then
					self:diffusealpha(0.6)
				else
					self:diffusealpha(0.8)
				end
			else
				self:diffusealpha(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		MouseDownCommand = function(self, params)
			if song and ctags[1] then
				if ctags[1] == GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_right mouse button" then
					GHETTOGAMESTATE.SSMTag = nil
					self:linear(0.1):diffusealpha(0.8)
					updateTagFilter(nil)
				elseif ctags[1] ~= GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_left mouse button" then
					GHETTOGAMESTATE.SSMTag = ctags[1]
					self:linear(0.1):diffusealpha(0.6)
					updateTagFilter(ctags[1])
				end
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(260 - frameWidth/5, frameHeight-40)
			self:zoom(0.4)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(200)
		end,
		SetCommand = function(self)
			if song and steps[pn] then
				self:settext(steps[pn]:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 1))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(260 - frameWidth/5, frameHeight-28)
			self:zoom(0.4)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(200)
		end,
		SetCommand = function(self)
			if song and steps[pn] then
				self:settext(steps[pn]:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 2))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(260 - frameWidth/5, frameHeight-16)
			self:zoom(0.4)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(200)
		end,
		SetCommand = function(self)
			if song and steps[pn] then
				self:settext(steps[pn]:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 3))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3*2 - 4 - (frameWidth-75)/6, -8)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(((frameWidth-75)/3-capWideScale(5,10))/0.4)
		end,
		SetCommand = function(self)
			if song and ctags[1] then
				self:settext(ctags[1])
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3 - 2 - (frameWidth-75)/6, -8)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(((frameWidth-75)/3-capWideScale(5,10))/0.4)
		end,
		SetCommand = function(self)
			if song and ctags[2] then
				self:settext(ctags[2])
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/6, -8)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(((frameWidth-75)/3-capWideScale(5,10))/0.4)
		end,
		SetCommand = function(self)
			if song and ctags[3] then
				self:settext(ctags[3])
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	return t
end

t[#t+1] = generalFrame(PLAYER_1)

return t