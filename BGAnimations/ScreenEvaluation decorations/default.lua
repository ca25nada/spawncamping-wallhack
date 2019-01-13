local t = Def.ActorFrame{}
local song = GAMESTATE:GetCurrentSong()

--ScoreBoard
local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}
local hjudges = {'HoldNoteScore_Held','HoldNoteScore_LetGo','HoldNoteScore_MissedHold'}
local frameX = SCREEN_CENTER_X/2
local frameY = 150
local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
local frameHeight = 300
local rate = getCurRate()

-- Reset preview music starting point since song was finished.
GHETTOGAMESTATE:setLastPlayedSecond(0)

-- ApproachSecond time for all rolling numbers in this file.
local approachSecond = 0.5


-- Timing/Judge Difficulty
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,40)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Timing Difficulty: %d",GetTimingDifficulty())
	end
}

-- Life Difficulty
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,55)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Life Difficulty: %d",GetLifeDifficulty())
	end
}

-- Music Rate/Haste
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,70)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Music Rate: %s", rate)
	end
}

-- Background Quad for Song banner
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(256+10,80+10)
		self:xy(SCREEN_CENTER_X,70)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end
}

-- Song banner
t[#t+1] = Def.Banner{
	BeginCommand = function(self)
		if song and not course then
			self:LoadFromSong(song)
		elseif course and not song then
			self:LoadFromCourse(course)
		end
		self:scaletofit(0,0,256,80)
		self:xy(SCREEN_CENTER_X,70)
	end
}


-- Song title
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X+5+(266/2),50)
		self:zoom(0.6)
		self:maxwidth(((SCREEN_WIDTH/2 -5 -266/2)/0.6) - 10)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:halign(0):valign(0)
	end,
	BeginCommand = function(self) 
		if GAMESTATE:IsCourseMode() then
			self:settext(course:GetDisplayFullTitle())
		else
			self:settext(song:GetDisplayMainTitle()) 
		end
	end
}

-- Artist and subtitles
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X+5+(266/2),65)
		self:zoom(0.4)
		self:maxwidth(((SCREEN_WIDTH/2 -5 -266/2)/0.4) - 10)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:halign(0):valign(0)
	end,
	BeginCommand = function(self) 
		if GAMESTATE:IsCourseMode() then
			self:settext("//"..course:GetScripter())
		else
			if song:GetDisplaySubTitle() ~= "" then
				self:settextf("%s\n// %s",song:GetDisplaySubTitle(),song:GetDisplayArtist())
			else
				self:settext("//"..song:GetDisplayArtist())
			end
		end
	end
}


-- Life graph and the stuff that goes with it
local function GraphDisplay( pn )
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	local t = Def.ActorFrame {

		Def.GraphDisplay {
			InitCommand = function(self)
				self:Load("GraphDisplay")
			end,
			BeginCommand = function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set(ss,pss)
				self:diffusealpha(0.5)
				self:GetChild("Line"):diffusealpha(0)
				self:y(55)
			end
		},

		LoadFont("Common Large")..{
			Name = "Grade",
			InitCommand = function(self)
				self:xy(-frameWidth/2+35,55):zoom(0.7):maxwidth(70/0.8)
			end,
			BeginCommand=function(self) 
				self:settext(THEME:GetString("Grade",ToEnumShortString(pss:GetHighScore():GetWifeGrade()))) 
			end
		},

		LoadFont("Common Normal")..{
			Font= "Common Normal", 
			InitCommand= function(self)
				self:y(50):zoom(0.6)
				self:halign(0)
			end,
			BeginCommand=function(self) 
				local wifeScore = pss:GetHighScore():GetWifeScore()
				if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)
				else
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)
				end

				self:settextf("%.2f%%",math.floor((wifeScore)*10000)/100)
			end
		},

		LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:y(63):zoom(0.4)
				self:halign(0)
			end,
			BeginCommand=function(self) 
				-- Fix when maxwife is available to lua
				local grade,diff = getNearbyGrade(pn,pss:GetWifeScore()*getMaxNotes(pn)*2,pss:GetGrade())
				diff = diff >= 0 and string.format("+%0.2f", diff) or string.format("%0.2f", diff)
				self:settextf("%s %s",THEME:GetString("Grade",ToEnumShortString(grade)),diff)
				if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)
				else
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)
				end
			end
		},



		LoadFont("Common Normal")..{
			InitCommand = function(self)
				self:xy(frameWidth/2-5,60-25+5):zoom(0.4):halign(1):valign(0):diffusealpha(0.7)
			end,
			BeginCommand=function(self)
				local text = ""
				text = string.format("Life: %.0f%%",pss:GetCurrentLife()*100)
				if pss:GetCurrentLife() == 0 then
					text = string.format("%s\n%.2fs Survived",text,pss:GetAliveSeconds())
				end
				self:settext(text)
			end
		}
	}
	return t
end

local function ComboGraph( pn ) 
  	local t = Def.ActorFrame { 
	    Def.ComboGraph {
	    	InitCommand = function(self)
				self:Load("ComboGraph"..ToEnumShortString(pn))
			end,
		    BeginCommand=function(self) 
		        local ss = SCREENMAN:GetTopScreen():GetStageStats() 
		        self:Set(ss,ss:GetPlayerStageStats(pn)) 
			end 
		}
  	}
  	return t
end

local function scoreBoard(pn)
	local hsTable = getScoreTable(pn, rate)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local steps = GAMESTATE:GetCurrentSteps(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	local index = getHighScoreIndex(hsTable, pss:GetHighScore())

	local recScore = getBestScore(pn, index, rate, true)
	local curScore = pss:GetHighScore()

	local clearType = getClearType(pn,steps,curScore)

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
		end,
		OnCommand = function(self)
			self:RunCommandsOnChildren(function(self) self:queuecommand("Set") end)
			self:bouncy(0.3)
			self:y(frameY)
			self:zoom(1)
			self:diffusealpha(1)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth,frameHeight):valign(0)
			self:diffuse(getMainColor("frame")):diffusealpha(0.8)
		end
	}

	t[#t+1] = StandardDecorationFromTable("GraphDisplay"..ToEnumShortString(pn), GraphDisplay(pn))
	t[#t+1] = StandardDecorationFromTable("ComboGraph"..ToEnumShortString(pn),ComboGraph(pn))

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			self:diffuse(getBorderColor())
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffusealpha(0.8)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end
	}

	t[#t+1] = Def.Sprite {
		InitCommand = function (self) 
			self:xy(25+10-(frameWidth/2),5)
			self:visible(true)
			self:LoadBackground(PROFILEMAN:GetAvatarPath(pn))
			self:zoomto(50,50)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "DisplayName",
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,9)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))

			local text = profile:GetDisplayName()
			if text == "" then
				text = pn == PLAYER_1 and "Player 1" or "Player 2"
			end
			self:settext(text)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,20)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self)
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
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,28)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self)
			self:settextf("Rating: %0.2f",profile:GetPlayerRating())
		end
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(self:GetParent():GetChild("DisplayName"):GetX()+self:GetParent():GetChild("DisplayName"):GetWidth()*0.6+5,10)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(getMainColor("positive"))
		end,
		SetCommand = function(self)
			self:settextf("+%d", getExpDiff(pn))
			self:smooth(4)
			self:diffusealpha(0)
			self:addy(-5)
		end
	}

	--Difficulty
	t[#t+1] = LoadFont("Common Normal")..{

		InitCommand = function(self)
			self:xy(frameWidth/2-5,5):zoom(0.5):halign(1):valign(0)
			self:glowshift():effectcolor1(color("1,1,1,0.05")):effectcolor2(color("1,1,1,0")):effectperiod(2)
		end,
		SetCommand=function(self) 
			local diff = steps:GetDifficulty()
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")

			local meter = steps:GetMSD(getCurRateValue(),1)
			meter = meter == 0 and steps:GetMeter() or math.floor(meter)

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
		InitCommand = function(self) 
		 	self:xy(frameWidth/2-5,19):zoom(0.4):halign(1):valign(0):diffusealpha(0.7)
		end,
		SetCommand=function(self) 
			
			local notes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			self:settextf("%d Notes",notes)

			if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)then
				self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35)+WideScale(get43size(140),140)-5)
			end

			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())),0.3))
		end
	}

	--ClearType
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,107)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryClearType"))
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
		end
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
		end,
		SetCommand = function(self)
			self:settext(getClearTypeText(clearType))
			self:diffuse(getClearTypeColor(clearType))
		end
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,113)
			self:zoom(0.35)
			self:halign(1):valign(0)
		end,
		SetCommand = function(self)
			local clearType = getHighestClearType(pn,steps,hsTable,index)
			self:settext(getClearTypeText(clearType))
			self:diffuse(getClearTypeColor(clearType))
			self:diffusealpha(0.5)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,106)
			self:zoom(0.30)
			self:valign(1)
		end,
		SetCommand = function(self) 
			local recCTLevel = getClearTypeLevel(getHighestClearType(pn,steps,hsTable,index))
			local curCTLevel = getClearTypeLevel(clearType)
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
		end
	}

	-- Score


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,137)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:settextf("%s - %s",THEME:GetString("ScreenEvaluation","CategoryScore"),getScoreTypeText(1))
		end
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
		end,
		SetCommand = function(self)
			local notes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			local curScoreValue = getScore(curScore, steps, false)
			local curScorePercent = getScore(curScore, steps, true)
			local maxScoreValue = notes * 2
			local percentText = string.format("%05.2f%%",math.floor(curScorePercent*10000)/100)
			self:settextf("%s (%d/%d)",percentText,curScoreValue,maxScoreValue)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,143)
			self:zoom(0.35)
			self:halign(1):valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText)):diffusealpha(0.3)
		end,
		SetCommand = function(self)
			local recScoreValue = getScore(recScore, steps, true)

			local maxScore = getMaxScore(pn)
			local percentText = string.format("%05.2f%%",math.floor(recScoreValue*10000)/100)
			self:settextf("%s (%0.0f/%d)",percentText,recScoreValue*maxScore,maxScore)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,136)
			self:zoom(0.30)
			self:valign(1)
		end,
		SetCommand = function(self) 
			local curScoreValue = getScore(curScore, steps, false)
			local recScoreValue = getScore(recScore, steps, false)
			local diff = curScoreValue - recScoreValue

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
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-20,136)
			self:zoom(0.30)
			self:valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self) 
			local curScoreValue = getScore(curScore, steps, false)
			local recScoreValue = getScore(recScore, steps, false)
			local diff = curScoreValue - recScoreValue

			local extra = ""
			if diff >= 0 then
				extra = "+"
			end
			self:settextf("%s%0.2f",extra,diff)
		end
	}

	-- Misscount

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,167)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:settext(THEME:GetString("ScreenEvaluation","CategoryMissCount"))
		end
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
		end,
		SetCommand = function(self)
			local missCount = getScoreMissCount(curScore)
			self:settext(missCount)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,173)
			self:zoom(0.35)
			self:halign(1):valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText)):diffusealpha(0.3)
		end,
		SetCommand = function(self)
			local score = getBestMissCount(pn,index, rate)
			local missCount = getScoreMissCount(score)

			if missCount ~= nil then
				self:settext(missCount)
			else
				self:settext("-")
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,166)
			self:zoom(0.30)
			self:valign(1)
		end,
		SetCommand = function(self) 

			local score = getBestMissCount(pn,index, rate)
			local recMissCount = getScoreMissCount(score)
			local curMissCount = getScoreMissCount(curScore)
			local diff = 0

			if score ~= nil then
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
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-20,166)
			self:zoom(0.30)
			self:valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self) 
			local score = getBestMissCount(pn,index, rate)
			local recMissCount = getScoreMissCount(score)
			local curMissCount = getScoreMissCount(curScore)
			local diff = 0

			local extra = ""
			if score ~= nil then
				diff = curMissCount - recMissCount
				if diff >= 0 then
					extra = "+"
				end
				self:settext(extra..diff)
			else
				self:settext("+"..curMissCount)
			end
		end
	}

	-- Tap judgments

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,196)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryJudgment"))
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
		end
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
				self:settext(getJudgeStrings(v))
				self:diffuse(TapNoteScoreToColor(v))
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),225)
				self:zoom(0.35)
			end,
			SetCommand=function(self) 
				local percent = pss:GetPercentageOfTaps(v)
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(TapNoteScoreToColor(v),0.1),Saturation(TapNoteScoreToColor(v),0.4)))
				self:settext(pss:GetTapNoteScores(v))
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),235)
				self:zoom(0.30)
			end,
			SetCommand=function(self) 
				local percent = pss:GetPercentageOfTaps(v)
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(TapNoteScoreToColor(v),0.1),Saturation(TapNoteScoreToColor(v),0.4)))
				self:settextf("(%.2f%%)",math.floor(percent*10000)/100)
			end
		}
	end

	for k,v in ipairs(hjudges) do
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*k),260)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))

				local text = getJudgeStrings(v)
				if text == "OK" or text == "NG" then
					text = "Hold "..text
				end
				self:settext(text)
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*k),275)
				self:zoom(0.35)
		    	self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				local percent = pss:GetHoldNoteScores(v)/(pss:GetRadarPossible():GetValue('RadarCategory_Holds')+pss:GetRadarPossible():GetValue('RadarCategory_Rolls'))
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
				self:settext(pss:GetHoldNoteScores(v))
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*k),285)
				self:zoom(0.30)
		    	self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				local percent = pss:GetHoldNoteScores(v)/(pss:GetRadarPossible():GetValue('RadarCategory_Holds')+pss:GetRadarPossible():GetValue('RadarCategory_Rolls'))
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
				self:settextf("(%.2f%%)",math.floor(percent*10000)/100)
			end
		}
	end

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*4),260)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			self:settext("Mines Hit")
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*4),275)
			self:zoom(0.35)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			local percent = pss:GetTapNoteScores('TapNoteScore_HitMine')/(pss:GetRadarPossible():GetValue('RadarCategory_Mines'))*100
			if tostring(percent) == tostring(0/0) then
				percent = 0
			end
			self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
			self:settext(pss:GetTapNoteScores('TapNoteScore_HitMine'))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/4)/2)+((frameWidth+frameWidth/4)/5)*4),285)
			self:zoom(0.30)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			local percent = pss:GetTapNoteScores('TapNoteScore_HitMine')/(pss:GetRadarPossible():GetValue('RadarCategory_Mines'))*100
			if tostring(percent) == tostring(0/0) then
				percent = 0
			end
			self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
			self:settextf("(%.2f%%)",percent)
		end
	}

	return t
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = scoreBoard(pn)
end

if GAMESTATE:GetNumPlayersEnabled() == 1 then
	t[#t+1] = LoadActor(THEME:GetPathG("","OffsetGraph"))..{
		InitCommand = function(self, params)
			self:xy(SCREEN_CENTER_X*3/2-frameWidth/2, 200)

			local pn = GAMESTATE:GetEnabledPlayers()[1]
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
			local steps = GAMESTATE:GetCurrentSteps(pn)

			self:RunCommandsOnChildren(function(self)
				local params = 	{width = frameWidth, 
								height = 150, 
								song = song, 
								steps = steps, 
								noterow = pss:GetNoteRowVector(), 
								offset = pss:GetOffsetVector()}
				self:playcommand("Update", params) end
			)
		end
	}
end


return t