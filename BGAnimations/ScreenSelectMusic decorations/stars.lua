local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;diffusealpha,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;diffusealpha,1;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:queuecommand("On");
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	TabChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
};

-- ohlookpso2stars
-- this became a mess rather quickly

local approachSecond = 0.2

local starsX = 10
local starsY = 110+capWideScale(get43size(120),120)
local maxStars = 18
local starDistX = capWideScale(get43size(23)-1,23)
local starDistY = 0
local starSize = 0.55
local playerDistY = 95
local frameWidth = capWideScale(get43size(455),455)
	
local song
local course

local steps = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

local trails = {
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

local function stars(ind,pn)
	return LoadActor("ossstar")..{
		InitCommand = function(self)
			self:xy(43+(ind*starDistX),2+(ind*starDistY))
			self:zoom(0);
		end;
		SetCommand=function(self)
			if update then
				local diff = 0;
				self:stoptweening();
				self:stopeffect();

				if steps[pn] ~= nil then
					diff = steps[pn]:GetMeter() or 0;
					self:visible(true);
					self:rotationz(0);

					if ind < diff then
						self:diffuse(color("#FFFFFF"))
						self:sleep((ind/math.min(diff,maxStars))/2);
						self:decelerate(0.5);
						self:rotationz(360);
						self:zoom(starSize)
					else
						self:sleep(((maxStars-ind)/maxStars)/2);
						self:accelerate(0.5);
						self:rotationz(360);
						self:zoom(0)
					end

					if ind < 3 then
						self:diffuse(getVividDifficultyColor('Difficulty_Beginner'))
					elseif ind < 6 then
						self:diffuse(getVividDifficultyColor('Difficulty_Easy'))
					elseif ind < 9 then
						self:diffuse(getVividDifficultyColor('Difficulty_Medium'))
					elseif ind < 12 then
						self:diffuse(getVividDifficultyColor('Difficulty_Hard'))
					elseif ind < 15 then
						self:diffuseshift()
						self:effectcolor1(color("#eeddff"))
						self:effectcolor2(color("#EE82EE"))
						self:effectperiod(2)
					else
						self:diffuse(color("#FFFFFF"))
						self:effectcolor1(color("#FFFFFF"))
						self:effectcolor2(color('Difficulty_Challenge'))
						self:glowshift()
						self:effectperiod(0.5)
					end
				else
					self:visible(false);
				end
			end
		end;
		BeginCommand = function(self) self:playcommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:playcommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) 
			if pn == PLAYER_1 then self:playcommand('Set') end end;
		CurrentStepsP2ChangedMessageCommand = function(self)
			if pn == PLAYER_2 then self:playcommand('Set') end end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then self:playcommand("Set") end end;
		PlayerUnjoinedMessageCommand=function(self, params)
			if params.Player == pn then self:visible(false) end end;
	};
end


local function generalFrame(pn)
	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(starsX,pn == PLAYER_1 and starsY or starsY+playerDistY)
		end;
		VisibleCommand = function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(pn))
		end;
		BeginCommand = function(self) self:playcommand('Visible') end;
		PlayerJoinedMessageCommand = function(self) self:playcommand('Visible') end;
		PlayerUnjoinedMessageCommand = function(self) self:playcommand('Visible') end;
	}


	--Upper Bar
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(-18)
			self:zoomto(frameWidth,30)
			self:halign(0):valign(0)
			self:diffuse(color("#333333CC"))
		end
	}


	--Lower Bar
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(18)
			self:zoomto(frameWidth,50)
			self:halign(0):valign(0)
			self:diffuse(color("#333333CC"))
		end
	}


	-- Clear Lamps
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(-18)
			self:zoomto(8,30)
			self:halign(0):valign(0)
			self:diffuse(color("#FFFFFF"))
		end;
		SetCommand = function(self)
			if update then
				self:diffuse(getHighestClearType(pn,0,2))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}


	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(-18)
			self:zoomto(8,30)
			self:halign(0):valign(0)
			self:diffuse(color("#FFFFFF"))
		end;
		BeginCommand=function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end;
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(13,-12)
			self:zoom(0.3)
			self:halign(0)
		end;
		SetCommand = function(self)
			if update then
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

					if diff == 'Difficulty_Edit' then
						difftext = steps[pn]:GetDescription()
						difftext = difftext == '' and getDifficulty(diff) or difftext
					else
						difftext = getDifficulty(diff)
					end

					stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
					self:settextf("%s %s // Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",stype,difftext,notes,holds,rolls,mines,lifts);
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
		InitCommand  = function(self)
			self:xy(frameWidth-5,-12)
			self:zoom(0.3)
			self:halign(1)
		end;
		SetCommand = function(self)
			local text = pn == PLAYER_1 and "Player 1" or "Player 2"
			if profile[pn] ~= nil then
				text = profile[pn]:GetDisplayName()
			end
			self:settext(text)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end;
	}


	t[#t+1] = Def.RollingNumbers{
		Font = "Common Normal";
		InitCommand = function(self)
			self:xy(21,2)
			self:zoom(0.6)
		    self:set_chars_wide(1):set_approach_seconds(approachSecond)
		end;
		SetCommand = function(self) 
			if update then
				local diff = 0
				local enabled = GAMESTATE:IsPlayerEnabled(pn)
				if enabled and steps[pn] ~= nil then
					diff = steps[pn]:GetMeter() or 0
					self:target_number(diff)
				else
					self:target_number(0)
				end
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
			self:xy(60,35)
			self:zoom(0.6)
		    self:maxwidth(110/0.6)
		end;
		SetCommand = function(self)
			if update then
				self:settext(THEME:GetString("Grade",ToEnumShortString(getBestGrade(pn,0))))
				self:diffuse(getGradeColor(getBestGrade(pn,0)))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}


	--ClearType
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(60,58)
			self:zoom(0.5)
		    self:maxwidth(110/0.6)
		end;
		SetCommand = function(self)
			if update then
				self:settext(getHighestClearType(pn,0,0))
				self:diffuse(getHighestClearType(pn,0,2))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}


	-- Percentage Score
	t[#t+1] = Def.RollingNumbers{
		Font= "Common Large";
		InitCommand= function(self)
			self:xy(195,30)
			self:zoom(0.45):halign(1):maxwidth(75/0.45)
		    self:set_chars_wide(6):set_text_format("%.2f%%"):set_approach_seconds(approachSecond)
		    self:set_leading_attribute{Diffuse= getMainColor('disabled')}
		end;
		SetCommand = function(self)
			if update then
				local score = getBestScore(pn,0,0)
				local maxscore = getMaxScore(pn,0)
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end
				local pscore = (score/maxscore)
				self:target_number(math.floor((pscore)*10000)/100)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}


	--Player DP/Exscore / Max DP/Exscore
	t[#t+1] = Def.RollingNumbers{
		Font = "Common Normal";
		Name = "score"; 
		InitCommand= function(self)
			self:xy(182,48)
			self:zoom(0.5):halign(1):maxwidth(26/0.5)
		    self:set_chars_wide(4):set_approach_seconds(approachSecond)
		    self:set_leading_attribute{Diffuse= getMainColor('disabled')}
		end;
		SetCommand = function(self) 
			if update then
				self:target_number(getMaxScore(pn,0))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = Def.RollingNumbers{
		Font = "Common Normal";
		InitCommand= function(self)
			self:xy(182,48)
			self:zoom(0.5):halign(1):maxwidth(34/0.5)
		    self:set_chars_wide(5):set_text_format("%.0f/"):set_approach_seconds(approachSecond)
		    self:set_leading_attribute{Diffuse= getMainColor('disabled')}
		end;
		SetCommand = function(self) 
			if update then
				self:x(self:GetParent():GetChild("score"):GetX()-(math.min(self:GetParent():GetChild("score"):GetWidth(),27/0.5)*0.5))
				self:target_number(getBestScore(pn,0,0))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

	--ScoreType superscript(?)
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(183,47)
			self:zoom(0.3)
		    self:halign(0)
		end;
		BeginCommand = function(self)
			self:settext(getScoreTypeText(0))
		end;
	}

	--MaxCombo
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210,25)
			self:zoom(0.4)
		    self:halign(0)
		end;
		SetCommand = function(self)
			if update then
				local maxCombo = getBestMaxCombo(pn,0)
				self:settextf("Max Combo: %d",maxCombo)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};


	--MissCount
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210,37)
			self:zoom(0.4)
		    self:halign(0)
		end;
		SetCommand = function(self)
			if update then
				local missCount = getBestMissCount(pn,0)
				if missCount ~= nil then
					self:settext("Miss Count: "..missCount)
				else
					self:settext("Miss Count: -")
				end
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};


	--Score Date
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210,49)
			self:zoom(0.4)
		    self:halign(0)
		end;
		SetCommand = function(self)
			if update then
				if IsUsingWideScreen() then
					self:settext("Date Achieved: "..getScoreDate(topScore[pn]))
				else
					self:settext(getScoreDate(topScore[pn]))
				end
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

	-- Stars
	local index = 0
	while index < maxStars do
		t[#t+1] = stars(index,pn)
		index = index + 1
	end

	return t
end

-- TODO: course mode stuff
t[#t+1] = Def.Actor{
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		if update then
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

t[#t+1] = LoadActor("bargraph");


return t