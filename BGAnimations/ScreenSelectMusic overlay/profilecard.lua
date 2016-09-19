local t = Def.ActorFrame{
	InitCommand = function(self) self:xy(0,-100):diffusealpha(0) end;
	OffCommand = function(self) self:finishtweening() self:bouncy(0.3) self:xy(0,100):diffusealpha(0) end;
	OnCommand = function(self) self:bouncy(0.3) self:xy(0,0):diffusealpha(1) end;
	TabChangedMessageCommand = function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:finishtweening()
			MESSAGEMAN:Broadcast("Expand")
		else 
			self:finishtweening()
			MESSAGEMAN:Broadcast("Contract")
		end
	end;
	PlayerJoinedMessageCommand = function(self)
		self:queuecommand("TabChangedMessage")
		MESSAGEMAN:Broadcast("Expand")
	end
};

local approachSecond = 0.2

local frameX = SCREEN_CENTER_X/2
local frameY = SCREEN_CENTER_Y+100
local maxMeter = 30
local starSize = 0.55
local frameWidth = capWideScale(get43size(390),390)
local frameHeight = 110
local frameHeightShort = 61
local song
local course

local steps = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

local trail = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

local profile = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

local topScore = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

local hsTable = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

local function generalFrame(pn)
	local t = Def.ActorFrame{
		SetCommand = function(self)
			self:xy(frameX,frameY)
			if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
				self:x(SCREEN_WIDTH-frameX)
			end
			self:visible(GAMESTATE:IsPlayerEnabled(pn))
		end;
		BeginCommand = function(self) self:playcommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:playcommand('Set') end;
		PlayerUnjoinedMessageCommand = function(self) self:playcommand('Set') end;
		ContractMessageCommand = function(self)
			self:stoptweening()
			self:bouncy(0.3)
			self:y(frameY+frameHeight-frameHeightShort)
		end;
		ExpandMessageCommand = function(self)
			self:stoptweening()
			self:bouncy(0.3)
			self:y(frameY)
		end;
	}

	--Upper Bar
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:z(2)
			self:zoomto(frameWidth,frameHeight)
			self:valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end;
		ContractMessageCommand = function(self)
			self:stoptweening()
			self:smooth(0.1)
			self:zoomy(frameHeightShort)
		end;
		ExpandMessageCommand = function(self)
			self:stoptweening()
			self:smooth(0.1)
			self:zoomy(frameHeight)
		end;
		MouseLeftClickMessageCommand = function(self)
			if isOver(self) and GAMESTATE:IsPlayerEnabled(pn) then
				addPressedActors(self)
			end
		end
	}

	-- Avatar background frame
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end;
		SetCommand = function(self)
			self:stoptweening()
			self:smooth(0.5)
			local scoreList
			if profile[pn] ~= nil and song ~= nil and steps[pn] ~= nil then
				scoreList = profile[pn]:GetHighScoreList(song,steps[pn]):GetHighScores()
			end
			local clearType = getHighestClearType(pn,steps[pn],scoreList,0)
			self:diffuse(getClearTypeColor(clearType))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffusealpha(0.8)
		end;
		BeginCommand = function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end;
	}

	-- Avatar
	t[#t+1] = Def.Sprite {
		InitCommand = function (self) self:xy(25+10-(frameWidth/2),5):z(3):playcommand("ModifyAvatar") end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end;
		PlayerUnjoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end;
		AvatarChangedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end;
		ModifyAvatarCommand = function(self)
			self:visible(true)
			self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(pn)));
			self:zoomto(50,50)
		end;
		MouseLeftClickMessageCommand = function(self)
			if isOver(self) and GAMESTATE:IsPlayerEnabled(pn) then
				addPressedActors(self)
			end
		end;
		TopPressedCommand = function(self)
			SCREENMAN:AddNewScreenToTop("ScreenAvatarSwitch")
		end;
	}

	-- Player name
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,10)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local text = ""
			if profile[pn] ~= nil then
				text = profile[pn]:GetDisplayName()
				if text == "" then
					text = pn == PLAYER_1 and "Player 1" or "Player 2"
				end
			end
			self:settext(text)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	-- Level and exp
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,23)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			if profile[pn] ~= nil then
				local level = getLevel(getProfileExp(pn))
				local currentExp = getProfileExp(pn) - getLvExp(level)
				local nextExp = getNextLvExp(level)
				self:settextf("Lv.%d (%d/%d)",level, currentExp, nextExp)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	--Score Date
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-150,3)
			self:zoom(0.35)
		    self:halign(0):valign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText)):diffusealpha(0.5)
		end;
		SetCommand = function(self)
			if getScoreDate(topScore[pn]) == "" then
				self:settext("Date Achieved: 0000-00-00 00:00:00")
			else
				self:settext("Date Achieved: "..getScoreDate(topScore[pn]))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

	-- Steps info
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(5-frameWidth/2,40)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local diff,stype
			local notes,holds,rolls,mines,lifts = 0
			local difftext = ""

			if GAMESTATE:IsCourseMode() then
				if course:AllSongsAreFixed() then
					if trail[pn] ~= nil then
						notes = trail[pn]:GetRadarValues(pn):GetValue("RadarCategory_Notes")
						holds = trail[pn]:GetRadarValues(pn):GetValue("RadarCategory_Holds")
						rolls = trail[pn]:GetRadarValues(pn):GetValue("RadarCategory_Rolls")
						mines = trail[pn]:GetRadarValues(pn):GetValue("RadarCategory_Mines")
						lifts = trail[pn]:GetRadarValues(pn):GetValue("RadarCategory_Lifts")
						diff = trail[pn]:GetDifficulty()
					end

					stype = ToEnumShortString(trail[pn]:GetStepsType()):gsub("%_"," ")
					self:settextf("%s %s // Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",stype,diff,notes,holds,rolls,mines,lifts);
				else
					self:settextf("Disabled for courses containing random songs.")
				end
			else
				if steps[pn] ~= nil then
					notes = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Notes")
					holds = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Holds")
					rolls = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Rolls")
					mines = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Mines")
					lifts = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Lifts")
					diff = steps[pn]:GetDifficulty()

				

					stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
					self:settextf("Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",notes,holds,rolls,mines,lifts);
				else
					self:settext("Disabled");
				end
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="StepsAndMeter";
		InitCommand = function(self)
			self:xy(frameWidth/2-5,38)
			self:zoom(0.5)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			if steps[pn] ~= nil then

				local diff = steps[pn]:GetDifficulty()
				local stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				local meter = steps[pn]:GetMeter()
				local difftext
				if diff == 'Difficulty_Edit' and IsUsingWideScreen() then
					difftext = steps[pn]:GetDescription()
					difftext = difftext == '' and getDifficulty(diff) or difftext
				else
					difftext = getDifficulty(diff)
				end
				if IsUsingWideScreen() then
					self:settext(stype.." "..difftext.." "..meter)
				else
					self:settext(difftext.." "..meter)
				end
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			end
		end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

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
		end;
		SetCommand = function(self)
			if steps[pn] ~= nil then
				local diff = getDifficulty(steps[pn]:GetDifficulty())
				local stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			end
		end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(5-(frameWidth/2),50)
			self:halign(0)
			self:zoomy(10)
			self:diffuse(getMainColor("highlight"))
		end;
		SetCommand = function(self)
			self:stoptweening()
			self:decelerate(0.5)
			local meter = 0
			local enabled = GAMESTATE:IsPlayerEnabled(pn)
			if enabled and steps[pn] ~= nil then
				meter = steps[pn]:GetMeter() or 0
				self:zoomx((math.min(1,meter/maxMeter))*(frameWidth-10))
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			else
				self:zoomx(0)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:y(50):zoom(0.3)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self) 
			self:stoptweening()
			self:decelerate(0.5)
			local meter = 0
			local enabled = GAMESTATE:IsPlayerEnabled(pn)
			if enabled and steps[pn] ~= nil then
				meter = steps[pn]:GetMeter() or 0
				self:settext(meter)
				self:x((math.min(1,meter/maxMeter))*(frameWidth-10)-frameWidth/2-3)
			else
				self:settext(0)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	--Grades
	t[#t+1] = LoadFont("Common Large")..{
		InitCommand = function(self)
			self:xy(60-frameWidth/2,frameHeight-35)
			self:zoom(0.6)
		    self:maxwidth(110/0.6)
		end;
		SetCommand = function(self)
			self:settext(THEME:GetString("Grade",ToEnumShortString(getBestGrade(pn,0))))
			self:diffuse(getGradeColor(getBestGrade(pn,0)))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	}

	--ClearType
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(60-frameWidth/2,frameHeight-15)
			self:zoom(0.4)
			self:maxwidth(110/0.4)
		end;
		SetCommand = function(self)
			self:stoptweening()
			local scoreList
			if profile[pn] ~= nil and song ~= nil and steps[pn] ~= nil then
				scoreList = profile[pn]:GetHighScoreList(song,steps[pn]):GetHighScores()
			end
			local clearType = getHighestClearType(pn,steps[pn],scoreList,0)
			self:settext(getClearTypeText(clearType))
			self:diffuse(getClearTypeColor(clearType))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	}

	-- Percentage Score
	t[#t+1] = LoadFont("Common Large")..{
		InitCommand= function(self)
			self:xy(190-frameWidth/2,frameHeight-36)
			self:zoom(0.45):halign(1):maxwidth(75/0.45)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local score = getBestScore(pn,0,0)
			local maxscore = getMaxScore(pn,0)
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end
			local pscore = (score/maxscore)
			self:settextf("%.2f%%",math.floor((pscore)*10000)/100)

		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	}


	--Player DP/Exscore / Max DP/Exscore
	t[#t+1] = LoadFont("Common Normal")..{
		Name = "score"; 
		InitCommand= function(self)
			self:xy(177-frameWidth/2,frameHeight-18)
			self:zoom(0.5):halign(1):maxwidth(26/0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self) 
			self:settext(getMaxScore(pn,0))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(177-frameWidth/2,frameHeight-18)
			self:zoom(0.5):halign(1):maxwidth(34/0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self) 
			self:x(self:GetParent():GetChild("score"):GetX()-(math.min(self:GetParent():GetChild("score"):GetWidth(),27/0.5)*0.5))
			self:settextf("%.0f/",getBestScore(pn,0,0))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	};

	--ScoreType superscript(?)
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(178-frameWidth/2,frameHeight-19)
			self:zoom(0.3)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		BeginCommand = function(self)
			self:settext(getScoreTypeText(0))
		end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	}

	--MaxCombo
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-40)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local maxCombo = getBestMaxCombo(pn,0)
			self:settextf("Max Combo: %d",maxCombo)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	};


	--MissCount
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-28)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local missCount = getBestMissCount(pn,0)
			if missCount ~= nil then
				self:settext("Miss Count: "..missCount)
			else
				self:settext("Miss Count: -")
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		ContractMessageCommand = function(self) self:visible(false) end;
		ExpandMessageCommand = function(self) self:visible(true) end;
	};

	return t
end

-- TODO: course mode stuff
t[#t+1] = Def.Actor{
	BeginCommand=cmd(playcommand,"Set");
	SetCommand = function(self)
		if GAMESTATE:IsCourseMode() then
			course = GAMESTATE:GetCurrentCourse()
			for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
				profile[pn] = GetPlayerOrMachineProfile(pn)
				trail[pn] = GAMESTATE:GetCurrentTrail(pn)
				hsTable[pn] = getScoreList(pn)
				if hsTable[pn] ~= nil then
					topScore[pn] = getScoreFromTable(hsTable[pn],1)
				end
			end
		else
			song = GAMESTATE:GetCurrentSong()
			for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
				profile[pn] = GetPlayerOrMachineProfile(pn)
				steps[pn] = GAMESTATE:GetCurrentSteps(pn)
				hsTable[pn] = getScoreList(pn)
				if hsTable[pn] ~= nil then
					topScore[pn] = getScoreFromTable(hsTable[pn],1)
				end
			end
		end
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set");
}

t[#t+1] = generalFrame(PLAYER_1)
t[#t+1] = generalFrame(PLAYER_2)



return t