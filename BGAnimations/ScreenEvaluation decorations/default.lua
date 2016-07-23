local t = Def.ActorFrame{}
local song = GAMESTATE:GetCurrentSong()
local course = GAMESTATE:GetCurrentCourse()

--ScoreBoard
local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}
local hjudges = {'HoldNoteScore_Held','HoldNoteScore_LetGo','HoldNoteScore_MissedHold'}
local frameX = SCREEN_CENTER_X/2
local frameY = 150
local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
local frameHeight = 300

setLastSecond(0)
local approachSecond = 0.5

if GAMESTATE:GetNumPlayersEnabled() == 1 and themeConfig:get_data().eval.ScoreBoardEnabled then
	t[#t+1] = LoadActor("scoreboard")
end;



t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,40)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Timing Difficulty: %d",GetTimingDifficulty())
	end
}

t[#t+1] = 	LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,55)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Life Difficulty: %d",GetLifeDifficulty())
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,70)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Music Rate: %s",getCurRate())
	end
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(256+10,80+10)
		self:xy(SCREEN_CENTER_X,70)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end
}

t[#t+1] = Def.Banner{
	BeginCommand = function(self)
		if song and not course then
			self:LoadFromSong(song)
		elseif course and not song then
			self:LoadFromCourse(course)
		end
		self:scaletofit(0,0,256,80)
		self:xy(SCREEN_CENTER_X,70)
	end;
}



t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X+5+(266/2),50)
		self:zoom(0.6)
		self:maxwidth(((SCREEN_WIDTH/2 -5 -266/2)/0.6) - 10)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:halign(0):valign(0)
	end;
	BeginCommand = function(self) 
		if GAMESTATE:IsCourseMode() then
			self:settext(course:GetDisplayFullTitle())
		else
			self:settext(song:GetDisplayMainTitle()) 
		end;
	end;
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X+5+(266/2),65)
		self:zoom(0.4)
		self:maxwidth(((SCREEN_WIDTH/2 -5 -266/2)/0.4) - 10)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:halign(0):valign(0)
	end;
	BeginCommand = function(self) 
		if GAMESTATE:IsCourseMode() then
			self:settext("//"..course:GetScripter())
		else
			if song:GetDisplaySubTitle() ~= "" then
				self:settextf("%s\n// %s",song:GetDisplaySubTitle(),song:GetDisplayArtist())
			else
				self:settext("//"..song:GetDisplayArtist())
			end
		end;
	end;
};


-- Life graph and the stuff that goes with it
local function GraphDisplay( pn )
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	if (PROFILEMAN:GetProfile(pn):GetDisplayName() ~= PROFILEMAN:GetMachineProfile():GetDisplayName()) and playerConfig:get_data(pn).SaveGhostScore then
		saveGhostData(pn,pss:GetHighScore())
	end


	local t = Def.ActorFrame {

		Def.GraphDisplay {
			InitCommand=cmd(Load,"GraphDisplay");
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set(ss,pss)
				self:diffusealpha(0.5);
				self:GetChild("Line"):diffusealpha(0)
				self:y(55)
			end
		};

		LoadFont("Common Large")..{
			Name = "Grade";
			InitCommand=cmd(xy,-frameWidth/2+35,55;zoom,0.7;maxwidth,70/0.8;);
			BeginCommand=function(self) 
				self:settext(THEME:GetString("Grade",ToEnumShortString(pss:GetGrade()))) 
			end;
		};

		Def.RollingNumbers{
			Font= "Common Normal", 
			InitCommand= function(self)
				self:y(55):zoom(0.6)
			    self:set_chars_wide(5):set_text_format("%.2f%%"):set_approach_seconds(approachSecond)
			end;
			BeginCommand=function(self) 
				local score = getCurScoreST(pn,0)
				local maxScore = getMaxScoreST(pn,0)
				self:halign(0)
				if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8,70/0.8))*0.6)
				else
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8,70/0.8))*0.6)
				end
				if maxScore > 0 then
					self:target_number(math.floor((score/maxScore)*10000)/100)
				else
					self:target_number(0)
				end
			end;
		};



		LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameWidth/2-5,60-25+5;zoom,0.4;halign,1;valign,0;diffusealpha,0.7;);
			BeginCommand=function(self)
				local text = ""
				text = string.format("Life: %.0f%%",pss:GetCurrentLife()*100)
				if pss:GetCurrentLife() == 0 then
					text = string.format("%s\n%.2fs Survived",text,pss:GetAliveSeconds())
				end
				if gameplay_pause_count > 0 then
					text = string.format("%s\nPaused %d Time(s)",text,gameplay_pause_count)
				end
				self:settext(text)
			end;
		};
	};
	return t
end

local function ComboGraph( pn ) 
  	local t = Def.ActorFrame { 
	    Def.ComboGraph { 
		    InitCommand=cmd(Load,"ComboGraph"..ToEnumShortString(pn);); 
		    BeginCommand=function(self) 
		        local ss = SCREENMAN:GetTopScreen():GetStageStats() 
		        self:Set(ss,ss:GetPlayerStageStats(pn)) 
			end 
		}
  	}
  	return t
end; 

local function scoreBoard(pn)
	local hsTable = getScoreList(pn)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local steps = GAMESTATE:GetCurrentSteps(pn)
	local profile = PROFILEMAN:GetProfile(pn)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			if GAMESTATE:GetNumPlayersEnabled() > 1 then
				if pn == PLAYER_1 then
					self:x(frameX)
				else 
					self:x(SCREEN_WIDTH - frameX)
				end
			else
				self:x(frameX)
			end
			self:y(frameY+100)
			self:zoom(0.5)
			self:diffusealpha(0)
		end;
		OnCommand = function(self)
			self:bouncy(0.3)
			self:y(frameY)
			self:zoom(1)
			self:diffusealpha(1)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand=cmd(zoomto,frameWidth,frameHeight;valign,0;diffuse,getMainColor("frame");diffusealpha,0.8)
	}

	t[#t+1] = StandardDecorationFromTable("GraphDisplay"..ToEnumShortString(pn), GraphDisplay(pn))
	t[#t+1] = StandardDecorationFromTable("ComboGraph"..ToEnumShortString(pn),ComboGraph(pn))

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

			if profile ~= nil and song ~= nil and steps ~= nil then
				scoreList = profile:GetHighScoreList(song,steps):GetHighScores()
			end
			local clearType = getHighestClearType(pn,steps,scoreList,0)
			self:diffuse(getClearTypeColor(clearType))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffusealpha(0.8)
		end;
		BeginCommand=function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end
	}

	t[#t+1] = Def.Sprite {
		InitCommand=function (self) self:xy(25+10-(frameWidth/2),5):playcommand("ModifyAvatar") end;
		ModifyAvatarCommand=function(self)
			self:visible(true)
			self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(pn)));
			self:zoomto(50,50)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "DisplayName";
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,10)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))

			local text = ""
			if profile ~= nil then
				text = profile:GetDisplayName()
				if text == "" then
					text = pn == PLAYER_1 and "Player 1" or "Player 2"
				end
			end
			self:settext(text)
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,23)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end;
		SetCommand = function(self)
			if profile ~= nil then
				local text = "Lv.%d (%d/%d)"
				local level = getLevel(getProfileExp(pn))
				local currentExp = getProfileExp(pn) - getLvExp(level)
				local nextExp = getNextLvExp(level)
				if playerLeveled(pn) then
					text = text.." - Level Up!"
					self:diffuse(getMainColor("positive"))
				end

				self:settextf(text,level, currentExp,nextExp)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(self:GetParent():GetChild("DisplayName"):GetX()+self:GetParent():GetChild("DisplayName"):GetWidth()*0.6+5,10)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(getMainColor("positive"))
		end;
		SetCommand = function(self)
			self:settextf("+%d",getExpDiff(pn))
			self:smooth(4)
			self:diffusealpha(0)
			self:addy(-5)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	--Difficulty
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameWidth/2-5,5;zoom,0.5;halign,1;valign,0);
		BeginCommand=cmd(glowshift;effectcolor1,color("1,1,1,0.05");effectcolor2,color("1,1,1,0");effectperiod,2;queuecommand,"Set");
		SetCommand=function(self) 
			local diff = steps:GetDifficulty()
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = steps:GetMeter()
			local difftext
			if diff == 'Difficulty_Edit' and IsUsingWideScreen() then
				difftext = steps:GetDescription()
				difftext = difftext == '' and getDifficulty(diff) or difftext
			else
				difftext = getDifficulty(diff)
			end
			if IsUsingWideScreen() then
				self:settext(stype.." "..difftext.." "..meter)
			else
				self:settext(difftext.." "..meter)
			end
			self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))

		end
	}

	-- Notecount
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameWidth/2-5,19;zoom,0.4;halign,1;valign,0;diffusealpha,0.7;);
		BeginCommand=function(self) 
			local notes = 0
			if steps ~= nil then
				notes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			end
			self:settextf("%d Notes",notes)
			if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)then
				self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35)+WideScale(get43size(140),140)-5)
			end
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())),0.3))
		end;
	};

	--ClearType
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,107)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryClearType"))
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(110)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,107)
			self:zoom(0.5)
			self:halign(1):valign(1)
		end;
		BeginCommand = function(self)
			local score = pss:GetHighScore()
			if score ~= nil then
				local clearType = getClearType(pn,steps,score)
				self:settext(getClearTypeText(clearType))
				self:diffuse(getClearTypeColor(clearType))
			end;
		end;
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,113)
			self:zoom(0.35)
			self:halign(1):valign(0)
		end;
		BeginCommand = function(self)
			local score = pss:GetHighScore()
			if score ~= nil then
				local index
				if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
					index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
				else
					index = pss:GetPersonalHighScoreIndex()+1
				end

				local scoreList

				if profile ~= nil and song ~= nil and steps ~= nil then
					scoreList = profile:GetHighScoreList(song,steps):GetHighScores()
				end
				local clearType = getHighestClearType(pn,steps,scoreList,index)
				self:settext(getClearTypeText(clearType))
				self:diffuse(getClearTypeColor(clearType))
				self:diffusealpha(0.5)
			end
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,106)
			self:zoom(0.30)
			self:valign(1)
		end;
		BeginCommand = function(self) 
			local score = pss:GetHighScore();
			local index
			if GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end

			local scoreList

			if profile ~= nil and song ~= nil and steps ~= nil then
				scoreList = profile:GetHighScoreList(song,steps):GetHighScores()
			end

			local recCTLevel = getClearTypeLevel(getHighestClearType(pn,steps,scoreList,index))
			local curCTLevel = getClearTypeLevel(getClearType(pn,steps,score))
			if curCTLevel < recCTLevel then
				self:settext("▲")
				self:diffuse(getMainColor("positive"))
			elseif curCTLevel > recCTLevel then
				self:settext("▼")
				self:diffuse(getMainColor("negative"))
			else
				self:settext("-")
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end
		end;
	}

	-- Score


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,137)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:settextf("%s - %s",THEME:GetString("ScreenEvaluation","CategoryScore"),getScoreTypeText(0))
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(140)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,137)
			self:zoom(0.5)
			self:halign(1):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end;
		BeginCommand = function(self)
			local score = getCurScoreST(pn,0)
			local maxScore = getMaxScoreST(pn,0)
			local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
			self:settextf("%s (%d/%d)",percentText,score,maxScore)
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,143)
			self:zoom(0.35)
			self:halign(1):valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText)):diffusealpha(0.3)
		end;
		BeginCommand = function(self)
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local score = getBestScore(pn,index,0)
			local maxScore = getMaxScoreST(pn,0)
			local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
			self:settextf("%s (%d/%d)",percentText,score,maxScore)
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,136)
			self:zoom(0.30)
			self:valign(1)
		end;
		BeginCommand = function(self) 
			local index

			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end

			local recScore = getBestScore(pn,index,0)
			local curScore = getCurScoreST(pn,0)
			local diff = curScore - recScore

			if diff > 0 then
				self:settext("▲")
				self:diffuse(getMainColor("positive"))
			elseif diff < 0 then
				self:settext("▼")
				self:diffuse(getMainColor("negative"))
			else
				self:settext("-")
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-20,136)
			self:zoom(0.30)
			self:valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end;
		BeginCommand = function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local recScore = getBestScore(pn,index,0)
			local curScore = getCurScoreST(pn,0)
			local diff = curScore - recScore
			local extra = ""
			if diff >= 0 then
				extra = "+"
			end;
			self:settextf("%s%d",extra,diff)
		end;
	}

	-- Misscount

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,167)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:settext(THEME:GetString("ScreenEvaluation","CategoryMissCount"))
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(170)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,167)
			self:zoom(0.5)
			self:halign(1):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end;
		BeginCommand = function(self)
			local score = pss:GetHighScore();
			local missCount = getScoreMissCount(score)
			self:settext(missCount)
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,173)
			self:zoom(0.35)
			self:halign(1):valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText)):diffusealpha(0.3)
		end;
		BeginCommand = function(self)
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local missCount = getBestMissCount(pn,index)
			if missCount ~= nil then
				self:settext(missCount)
			else
				self:settext("-")
			end
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,166)
			self:zoom(0.30)
			self:valign(1)
		end;
		BeginCommand = function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local score = pss:GetHighScore();
			
			local recMissCount = (getBestMissCount(pn,index))
			local curMissCount = getScoreMissCount(score)
			local diff = 0

			if recMissCount ~= nil then
				diff = curMissCount - recMissCount
				if diff > 0 then
					self:settext("▼")
					self:diffuse(getMainColor("negative"))
				elseif diff < 0 then
					self:settext("▲")
					self:diffuse(getMainColor("positive"))
				else
					self:settext("-")
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
				end
			else
				self:settext("-")
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end;
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-20,166)
			self:zoom(0.30)
			self:valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end;
		BeginCommand = function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local score = pss:GetHighScore();
			
			local recMissCount = (getBestMissCount(pn,index))
			local curMissCount = getScoreMissCount(score)
			local diff = 0
			local extra = ""
			if recMissCount ~= nil then
				diff = curMissCount - recMissCount
				if diff >= 0 then
					extra = "+"
				end;
				self:settext(extra..diff)
			else
				self:settext("+"..curMissCount)
			end;
		end;
	}

	-- Tap judgments

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,196)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryJudgment"))
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(200)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	for k,v in ipairs(judges) do
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),210)
				self:zoom(0.4)
			end;
			BeginCommand = function(self) 
				self:settext(getJudgeStrings(v))
				self:diffuse(TapNoteScoreToColor(v))
			end;
		};

		t[#t+1] = Def.RollingNumbers{
			Font= "Common Normal";
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),225)
				self:zoom(0.35)
			    self:set_chars_wide(1):set_approach_seconds(approachSecond)
			    self:set_leading_attribute{Diffuse = getMainColor("disabled")}
			end;
			BeginCommand=function(self) 
				local percent = pss:GetPercentageOfTaps(v)
				if tostring(percent) == "-nan(ind)" then
					percent = 0
				end
				self:set_number_attribute{Diffuse = lerp_color(percent,Saturation(TapNoteScoreToColor(v),0.1),Saturation(TapNoteScoreToColor(v),0.4))}
				self:target_number(pss:GetTapNoteScores(v))
			end
		}

		t[#t+1] = Def.RollingNumbers{
			Font= "Common Normal";
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),235)
				self:zoom(0.30)
			    self:set_chars_wide(3):set_text_format("(%.2f%%)"):set_approach_seconds(approachSecond)
			    self:set_leading_attribute{Diffuse = getMainColor("disabled")}
			end;
			BeginCommand=function(self) 
				local percent = pss:GetPercentageOfTaps(v)
				if tostring(percent) == "-nan(ind)" then
					percent = 0
				end
				self:set_number_attribute{Diffuse = lerp_color(percent,Saturation(TapNoteScoreToColor(v),0.1),Saturation(TapNoteScoreToColor(v),0.4))}
				self:target_number(percent*100)
			end
		}
	end

	for k,v in ipairs(hjudges) do
		t[#t+1] = LoadFont("Common Normal")..{

			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*k),260)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end;
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local text = getJudgeStrings(v)
				if text == "OK" or text == "NG" then
					text = "Hold "..text
				end
				self:settext(text)
			end;
		};

		t[#t+1] = Def.RollingNumbers{
			Font= "Common Normal";
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*k),275)
				self:zoom(0.35)
			    self:set_chars_wide(1):set_approach_seconds(approachSecond)
			    self:set_leading_attribute{Diffuse = getMainColor("disabled")}
		    	self:set_number_attribute{Diffuse =color(colorConfig:get_data().evaluation.ScoreCardText)}
			end;
			BeginCommand=function(self) 
				local percent = pss:GetHoldNoteScores(v)/(pss:GetRadarPossible():GetValue('RadarCategory_Holds')+pss:GetRadarPossible():GetValue('RadarCategory_Rolls'))
				if tostring(percent) == "-nan(ind)" then
					percent = 0
				end
				self:set_number_attribute{Diffuse = lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))}
				


				self:target_number(pss:GetHoldNoteScores(v))


			end
		}

		t[#t+1] = Def.RollingNumbers{
			Font= "Common Normal";
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*k),285)
				self:zoom(0.30)
			    self:set_chars_wide(3):set_text_format("(%.2f%%)"):set_approach_seconds(approachSecond)
			    self:set_leading_attribute{Diffuse = getMainColor("disabled")}
		    	self:set_number_attribute{Diffuse =color(colorConfig:get_data().evaluation.ScoreCardText)}
			end;
			BeginCommand=function(self) 
				local percent = pss:GetHoldNoteScores(v)/(pss:GetRadarPossible():GetValue('RadarCategory_Holds')+pss:GetRadarPossible():GetValue('RadarCategory_Rolls'))
				if tostring(percent) == "-nan(ind)" then
					percent = 0
				end
				self:set_number_attribute{Diffuse = lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))}
				self:target_number(percent*100)
			end
		}
	end

	t[#t+1] = LoadFont("Common Normal")..{

		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*4),260)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			self:settext("Mines Hit")
		end;
	};

	t[#t+1] = Def.RollingNumbers{
		Font= "Common Normal";
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*4),275)
			self:zoom(0.35)
		    self:set_chars_wide(1):set_approach_seconds(approachSecond)
		    self:set_leading_attribute{Diffuse = getMainColor("disabled")}
		    self:set_number_attribute{Diffuse =color(colorConfig:get_data().evaluation.ScoreCardText)}
		end;
		BeginCommand=function(self) 
			local percent = pss:GetTapNoteScores('TapNoteScore_HitMine')/(pss:GetRadarPossible():GetValue('RadarCategory_Mines'))*100
			if tostring(percent) == "-nan(ind)" then
				percent = 0
			end
			self:set_number_attribute{Diffuse = lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))}
			
			self:target_number(pss:GetTapNoteScores('TapNoteScore_HitMine'))
		end
	}

	t[#t+1] = Def.RollingNumbers{
		Font= "Common Normal";
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*4),285)
			self:zoom(0.30)
		    self:set_chars_wide(3):set_text_format("(%.2f%%)"):set_approach_seconds(approachSecond)
		    self:set_leading_attribute{Diffuse = getMainColor("disabled")}
		    self:set_number_attribute{Diffuse =color(colorConfig:get_data().evaluation.ScoreCardText)}
		end;
		BeginCommand=function(self) 
			local percent = pss:GetTapNoteScores('TapNoteScore_HitMine')/(pss:GetRadarPossible():GetValue('RadarCategory_Mines'))*100
			if tostring(percent) == "-nan(ind)" then
				percent = 0
			end
			self:set_number_attribute{Diffuse = lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))}
			self:target_number(percent)
		end
	}



	--[[
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,0,230;zoom,0.35;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Unstable Rate: %0.1f",getUnstableRateST(pn))
		end;
	};
	--]]

	return t
end;

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = scoreBoard(pn)
end

if themeConfig:get_data().eval.JudgmentBarEnabled then
	t[#t+1] = LoadActor("adefaultmoreripoff")
end;

return t