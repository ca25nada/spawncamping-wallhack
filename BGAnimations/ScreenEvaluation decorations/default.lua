local song = GAMESTATE:GetCurrentSong()
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local steps = GAMESTATE:GetCurrentSteps(pn)

--ScoreBoard
local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}
local hjudges = {'HoldNoteScore_Held','HoldNoteScore_LetGo','HoldNoteScore_MissedHold'}
local frameX = SCREEN_CENTER_X/2
local frameY = 150
local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
local frameHeight = 300
local rate = getCurRate()
local judge = (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
local offsetIndex

-- Reset preview music starting point since song was finished.
GHETTOGAMESTATE:setLastPlayedSecond(0)

-- etc timing info
local nrv = pss:GetNoteRowVector()
local dvt = pss:GetOffsetVector()
local ctt = pss:GetTrackVector()
local ntt = pss:GetTapNoteTypeVector()
local totalTaps = pss:GetTotalTaps()

local rescoredPercentage

local usingSimpleScreen = themeConfig:get_data().global.SimpleEval
local showScoreboardOnSimple = themeConfig:get_data().global.ShowScoreboardOnSimple
local offsetY2 = 0
local offsetWidth2 = 0
local offsetHeight2 = 0
local offsetisLocal

local function scroller(event)
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			MESSAGEMAN:Broadcast("WheelUpSlow")
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			MESSAGEMAN:Broadcast("WheelDownSlow")
		end
	end
end
local t = Def.ActorFrame {}

local function oldEvalStuff()

	local function highlight(self)
		self:queuecommand("Highlight")
	end


	local t = Def.ActorFrame {
		InitCommand = function(self)
			if usingSimpleScreen then
				self:addy(SCREEN_HEIGHT)
			end
			self:SetUpdateFunction(highlight)
		end,
		SwitchEvalTypesMessageCommand = function(self)
			self:visible(true)
			if usingSimpleScreen then
				self:bouncy(0.3)
				self:addy(SCREEN_HEIGHT)
			else
				self:bouncy(0.3)
				self:addy(-SCREEN_HEIGHT)
				self:diffusealpha(1)
			end
		end
	}
	t[#t+1] = Def.ActorFrame {
		OffsetPlotModificationMessageCommand = function(self, params)
			local score = pss:GetHighScore()
			local totalHolds =
				pss:GetRadarPossible():GetValue("RadarCategory_Holds") + pss:GetRadarPossible():GetValue("RadarCategory_Rolls")
			local holdsHit =
				pss:GetRadarActual():GetValue("RadarCategory_Holds") + pss:GetRadarActual():GetValue("RadarCategory_Rolls")
			local minesHit =
				pss:GetRadarPossible():GetValue("RadarCategory_Mines") - pss:GetRadarActual():GetValue("RadarCategory_Mines")
			if enabledCustomWindows then
				if params.Name == "PrevJudge" then
					judge = judge < 2 and #customWindows or judge - 1
					customWindow = timingWindowConfig:get_data()[customWindows[judge]]
					rescoredPercentage = getRescoredCustomPercentage(dvt, customWindow, totalHolds, holdsHit, minesHit, totalTaps)
				elseif params.Name == "NextJudge" then
					judge = judge == #customWindows and 1 or judge + 1
					customWindow = timingWindowConfig:get_data()[customWindows[judge]]
					rescoredPercentage = getRescoredCustomPercentage(dvt, customWindow, totalHolds, holdsHit, minesHit, totalTaps)
				end
			elseif params.Name == "PrevJudge" and judge > 1 then
				judge = judge - 1
				rescoredPercentage = getRescoredWifeJudge(dvt, judge, totalHolds - holdsHit, minesHit, totalTaps)
			elseif params.Name == "NextJudge" and judge < 9 then
				judge = judge + 1
				rescoredPercentage = getRescoredWifeJudge(dvt, judge, totalHolds - holdsHit, minesHit, totalTaps)
			end
			if params.Name == "ResetJudge" then
				judge = enabledCustomWindows and 0 or (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
				self:GetParent():playcommand("ResetJudge")
			elseif params.Name ~= "ToggleHands" then
				self:GetParent():playcommand("SetJudge", params)
			end
		end
	}

	-- Timing/Judge Difficulty
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(10,50)
			self:zoom(0.45)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			self:settextf("Timing Difficulty: %d",judge)
		end,
		SetJudgeCommand = function(self)
			self:queuecommand("Set")
		end,
		ResetJudgeCommand = function(self)
			self:queuecommand("Set")
		end
	}

	-- Life Difficulty
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(10,65)
			self:zoom(0.45)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
			self:settextf("Life Difficulty: %d",GetLifeDifficulty())
		end
	}

	-- Music Rate/Haste
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(SCREEN_CENTER_X,120)
			self:zoom(0.48)
			self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
			self:settextf("Rate: %s", rate)
		end
	}

	-- Mod List
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(10,80)
			self:zoom(0.45)
			self:halign(0)
			self:maxwidth((SCREEN_WIDTH/2 - 133 - 10)/0.45)
			self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
			local mods = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString("ModsLevel_Current")
			self:settextf("Mods: %s", mods)
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
	t[#t+1] = Def.Sprite {
		BeginCommand = function(self)
			if song then
				local bnpath = song:GetBannerPath()
				if not bnpath then
					bnpath = THEME:GetPathG("Common", "fallback banner")
				end
				self:LoadBackground(bnpath)
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
			self:settext(song:GetDisplayMainTitle()) 
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
			if song:GetDisplaySubTitle() ~= "" then
				self:settextf("%s\n// %s",song:GetDisplaySubTitle(),song:GetDisplayArtist())
			else
				self:settext("//"..song:GetDisplayArtist())
			end
		end
	}


	-- Life graph and the stuff that goes with it
	local function GraphDisplay( pn )
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
				end,
				SetJudgeCommand = function(self)
					self:settext(THEME:GetString("Grade", ToEnumShortString(getWifeGradeTier(rescoredPercentage))))
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("Begin")
				end
			},

			LoadFont("Common Normal")..{
				Font= "Common Normal", 
				InitCommand= function(self)
					self:y(50):zoom(0.7)
					self:halign(0)
				end,
				BeginCommand=function(self) 
					local wifeScore = pss:GetHighScore():GetWifeScore()
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)

					if wifeScore > 0.99 then
						self:settextf("%.4f%%",math.floor((wifeScore)*1000000)/10000)
					else
						self:settextf("%.2f%%",math.floor((wifeScore)*10000)/100)
					end
				end,
				SetJudgeCommand = function(self, params)
					if enabledCustomWindows then
						if rescoredPercentage > 99 then
							self:settextf(
								"%05.4f%% (%s)",
								rescoredPercentage,
								customWindow.name
							)
							else
								self:settextf(
								"%05.2f%% (%s)",
								rescoredPercentage,
								customWindow.name
							)
						end
					elseif params.Name == "PrevJudge" and judge >= 1 then
						if rescoredPercentage > 99 then
							self:settextf(
								"%05.4f%% (%s)",
								rescoredPercentage,
								"Wife J" .. judge
							)
						else
							self:settextf(
								"%05.2f%% (%s)",
								rescoredPercentage,
								"Wife J" .. judge
							)
						end
					elseif params.Name == "NextJudge" and judge <= 9 then
						if judge == 9 then
							if rescoredPercentage > 99 then
								self:settextf(
									"%05.4f%% (%s)",
									rescoredPercentage,
									"Wife Justice"
								)
							else
								self:settextf(
									"%05.2f%% (%s)",
									rescoredPercentage,
									"Wife Justice"
								)	
							end
						else
							if rescoredPercentage > 99 then
								self:settextf(
									"%05.4f%% (%s)",
									rescoredPercentage,
									"Wife J" .. judge
								)
							else
								self:settextf(
									"%05.2f%% (%s)",
									rescoredPercentage,
									"Wife J" .. judge
								)
							end
						end
					end
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("Begin")
				end
			},

			LoadFont("Common Normal")..{
				InitCommand= function(self)
					self:y(63):zoom(0.4)
					self:halign(0)
				end,
				BeginCommand=function(self) 
					-- Fix when maxwife is available to lua
					local pct = pss:GetWifeScore() * 100
					local grade,diff = getNearbyGrade(pn,pss:GetWifeScore()*getMaxNotes(pn)*2,getWifeGradeTier(pct))
					diff = diff >= 0 and string.format("+%0.2f", diff) or string.format("%0.2f", diff)
					self:settextf("%s %s",THEME:GetString("Grade",ToEnumShortString(grade)),diff)
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)
				end,
				OffsetPlotModificationMessageCommand = function(self, params)
					if params.Name == "ResetJudge" then
						self:playcommand("Begin")
						self:diffusealpha(1)
					elseif params.Name == "NextJudge" or params.Name == "PrevJudge" then
						self:diffusealpha(0)
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
		local profile = PROFILEMAN:GetProfile(pn)
		local index
		if hsTable == nil then
			index = 1
		else
			index = getHighScoreIndex(hsTable, pss:GetHighScore())
		end
		local recScore = getBestScore(pn, index, rate, true)
		local curScore = pss:GetHighScore()

		local clearType = getClearType(pn,steps,curScore)

		-- stolen from Til Death without any shame
		local tracks = pss:GetTrackVector()
		local devianceTable = pss:GetOffsetVector()
		local cbl = 0
		local cbr = 0
		local cbm = 0

		local tst = ms.JudgeScalers
		local tso = tst[judge]
		if enabledCustomWindows then
			tso = 1
		end
		local ncol = GAMESTATE:GetCurrentSteps(PLAYER_1):GetNumColumns() - 1
		local middleCol = ncol / 2
		local function recountCBs()
			tso = tst[judge]
			if enabledCustomWindows then
				tso = 1
			end
			cbl = 0
			cbr = 0
			cbm = 0
			for i = 1, #devianceTable do
				if tracks[i] then
					if math.abs(devianceTable[i]) > tso * 90 then
						if tracks[i] < middleCol then
							cbl = cbl + 1
						elseif tracks[i] > middleCol then
							cbr = cbr + 1
						else
							cbm = cbm + 1
						end
					end
				end
			end
		end
		recountCBs()

		local statInfo = {
			wifeMean(devianceTable),
			wifeAbsMean(devianceTable),
			wifeSd(devianceTable),
			cbl,
			cbr,
			cbm
		}

		local showMiddle = middleCol == math.floor(middleCol)
		local cbYSpacing = showMiddle and 7 or 10

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
			end,
			OffCommand = function(self)
				self:bouncy(0.3)
				self:y(500)
			end,
			ResetJudgeCommand = function(self)
				recountCBs()
			end,
			SetJudgeCommand = function(self)
				recountCBs()
			end,
			ForceUpdateAllInfoMessageCommand = function(self)
				recountCBs()
				self:RunCommandsOnChildren(function(self) self:queuecommand("SetJudge") end)
			end
		}

		t[#t+1] = quadButton(5) .. {
			InitCommand = function(self)
				self:zoomto(frameWidth,frameHeight):valign(0)
				self:diffuse(getMainColor("frame")):diffusealpha(0.8)
			end,
			MouseDownCommand = function(self)
				usingSimpleScreen = not usingSimpleScreen
				MESSAGEMAN:Broadcast("SwitchEvalTypes")
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
				self:Load(getAvatarPath(PLAYER_1))
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
					text = "Player 1"
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
				if DLMAN:IsLoggedIn() then
					local rank = DLMAN:GetSkillsetRank("Overall")
					local rating = DLMAN:GetSkillsetRating("Overall")
					local localrating = profile:GetPlayerRating()
					local rankDiff = GHETTOGAMESTATE:checkOnlineRank()
					local finalStr = ""
					if rankDiff < 0 then
						finalStr = string.format("Rating: %0.2f (%0.2f #%d Online) %d rank change!", localrating, rating, rank, rankDiff)
						self:settext(finalStr)
					elseif rankDiff > 0 then
						finalStr = string.format("Rating: %0.2f (%0.2f #%d Online) +%d rank change!", localrating, rating, rank, rankDiff)
						self:settext(finalStr)
					else
						finalStr = string.format("Rating: %0.2f (%0.2f #%d Online)", localrating, rating, rank)
						self:settext(finalStr)
					end
					self:AddAttribute(#"Rating:", {Length = 7, Zoom =0.3 ,Diffuse = getMSDColor(localrating)})
					self:AddAttribute(#"Rating: 00.00 ", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(rating)})			
					if rankDiff ~= 0 then
						local tempStr = string.format("Rating: %0.2f (%0.2f #%d Online)", localrating, rating, rank)
						self:AddAttribute(#tempStr+1, {Length = -1, Diffuse = color(colorConfig:get_data().evaluation.ScoreCardText)})
					end
				else
					self:settextf("Rating: %0.2f",profile:GetPlayerRating())
				end
			end
		}

		--[[ -- disabled because the game doesnt save the required stuff correctly, just stored it to xml and reads once per session
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
		]]

		--Diff & MSD
		t[#t+1] = LoadFont("Common Normal")..{

			InitCommand = function(self)
				self:xy(frameWidth/2-5,5):zoom(0.45):halign(1):valign(0)
				self:glowshift():effectcolor1(color("1,1,1,0.05")):effectcolor2(color("1,1,1,0")):effectperiod(2)
			end,
			SetCommand=function(self) 
				local diff = steps:GetDifficulty()
				local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")

				local meter = steps:GetMSD(getCurRateValue(),1)
				meter = meter == 0 and steps:GetMeter() or meter

				local difftext
				if diff == 'Difficulty_Edit' and IsUsingWideScreen() then
					difftext = steps:GetDescription()
					difftext = difftext == '' and getDifficulty(diff) or difftext
				else
					difftext = getDifficulty(diff)
				end

				if IsUsingWideScreen() then
					self:settextf("%s %s %5.2f", stype, difftext, meter)
					self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
					self:AddAttribute(#stype + #difftext + 2, {Length = -1, Diffuse = byMSD(meter)})
				else
					self:settextf("%s %5.2f", difftext, meter)
					self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
					self:AddAttribute(#difftext + 1, {Length = -1, Diffuse = byMSD(meter)})
				end
			end
		}

		-- SSR
		t[#t+1] = LoadFont("Common Normal")..{
			Name = "SSR",
			InitCommand = function(self) 
				self:xy(frameWidth/2-5,19):zoom(0.5):halign(1):valign(0)
			end,
			SetCommand=function(self) 
				local meter = curScore:GetSkillsetSSR("Overall")
				self:settextf("SSR   %5.2f", meter)
				self:AddAttribute(#"SSR", {Length = -1, Diffuse = byMSD(meter)})
			end,
			HighlightCommand = function(self)
				if isOver(self) then
					local meter = curScore:GetSkillsetSSR("Overall")
					self:settextf("Score Specific Rating   %5.2f", meter)
					self:AddAttribute(#"Score Specific Rating", {Length = -1, Diffuse = byMSD(meter)})
				else
					self:playcommand("Set")
				end
			end
		}

		--ClearType
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand = function(self)
				self:xy(-frameWidth/2+5,107)
				self:zoom(0.35)
				self:halign(0):valign(1)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if PREFSMAN:GetPreference("SortBySSRNormPercent") then
					self:settextf("%s (J4)", THEME:GetString("ScreenEvaluation", "CategoryClearType"))
				else
					self:settext(THEME:GetString("ScreenEvaluation","CategoryClearType"))
				end
			end,
			SetJudgeCommand = function(self)
				local jdg = (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
				self:settextf("%s (J%d)", THEME:GetString("ScreenEvaluation", "CategoryClearType"), jdg)
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
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
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if PREFSMAN:GetPreference("SortBySSRNormPercent") then
					self:settextf("%s - %s J4", THEME:GetString("ScreenEvaluation","CategoryScore"), getScoreTypeText(1))
				else
					self:settextf("%s - %s", THEME:GetString("ScreenEvaluation","CategoryScore"), getScoreTypeText(1))
				end
			end,
			SetJudgeCommand = function(self)
				local jdg = (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
				self:settextf("%s - %s J%d", THEME:GetString("ScreenEvaluation", "CategoryScore"), getScoreTypeText(1), jdg)
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
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
				self:playcommand("Set")
			end,
			SetCommand = function(self)
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
				end,
				SetJudgeCommand = function(self)
					if enabledCustomWindows then
						self:settext(getRescoredCustomJudge(dvt, customWindow.judgeWindows, k))
					else
						self:settext(getRescoredJudge(dvt, judge, k))
					end
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("Set")
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
				end,
				SetJudgeCommand = function(self)
					if enabledCustomWindows then
						self:settextf("(%.2f%%)", getRescoredCustomJudge(dvt, customWindow.judgeWindows, k) / totalTaps * 100)
					else
						self:settextf("(%.2f%%)", getRescoredJudge(dvt, judge, k) / totalTaps * 100)
					end
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("Set")
				end
			}
		end

		for k,v in ipairs(hjudges) do
			t[#t+1] = LoadFont("Common Normal")..{
				InitCommand= function(self)
					self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),260)
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
					self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),275)
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
					self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),285)
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
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*4),260)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
				self:settext("Mines Hit")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*4),275)
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
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*4),285)
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

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),260)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
				self:settext("Mean")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),275)
				self:zoom(0.35)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
				self:settextf("%.2fms", statInfo[1])
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),285)
				self:zoom(0.25)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
				self:settextf("%.2fms (abs)", statInfo[2])
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),292)
				self:zoom(0.25)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
				self:settextf("%.2fms (std dev)", statInfo[3])
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),260)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
				self:settext("CBs")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),275)
				self:zoom(0.3)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
				self:settextf("Left: %d", cbl)
			end,
			SetJudgeCommand = function(self)
				self:playcommand("Set")
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),275 + cbYSpacing)
				self:zoom(0.30)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
				self:settextf("Right: %d", cbr)
			end,
			SetJudgeCommand = function(self)
				self:playcommand("Set")
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),275 + cbYSpacing*2)
				self:zoom(0.30)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
				self:visible(false)
			end,
			SetCommand=function(self) 
				self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
				self:settextf("Middle: %d", cbm)
				if showMiddle then
					self:visible(true)
				end
			end,
			SetJudgeCommand = function(self)
				self:playcommand("Set")
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
			end
		}

		return t
	end
	
	for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		t[#t+1] = scoreBoard(pn)
	end


	local player = GAMESTATE:GetEnabledPlayers()[1]
	local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]
	local profile = GetPlayerOrMachineProfile(player)
	local hsTable = getScoreTable(player, getCurRate())
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local score = pss:GetHighScore()
	local scoreIndex = getHighScoreIndex(hsTable, score)
	local newScoreboardInitialLocalIndex = scoreIndex
	local newScoreboardInitialLocalIndex2 = scoreIndex -- dont ask about this please i dont want to explain myself

	local lbActor
	local offsetScoreID
	local currentCountry = "Global"
	local scoresPerPage = 5
	local maxPages = math.ceil(#hsTable/scoresPerPage)
	local curPage = 1
	local alreadyPulled = false

	local function updateLeaderBoardForCurrentChart()
		alreadyPulled = true
		if steps then
			DLMAN:RequestChartLeaderBoardFromOnline(
				steps:GetChartKey(),
				function(leaderboard)
					lbActor:queuecommand("SetFromLeaderboard", leaderboard)
				end
			)
		else
			lbActor:queuecommand("SetFromLeaderboard", {})
		end
	end

	local function movePage(n)
		if maxPages <= 1 then
			return
		end

		if n > 0 then 
			curPage = ((curPage+n-1) % maxPages + 1)
		else
			curPage = ((curPage+n+maxPages-1) % maxPages+1)
		end
		MESSAGEMAN:Broadcast("UpdateList")
	end

	local function scoreboardInput(event)
		if event.type == "InputEventType_FirstPress" then
			if maxPages <= 1 then
				return
			end
			if event.button == "MenuLeft" then
				movePage(-1)
			end
			if event.button == "MenuRight" then
				movePage(1)
			end

		end
	end

	-- this is the dynamic scoreboard for all the cool scores
	-- bad name dont ask (do ask)
	local function boardOfScores()
		local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
		local frameHeight = 150
		local frameX = SCREEN_WIDTH - frameWidth - WideScale(get43size(40),40)/2
		local frameY = 154
		local spacing = 1
		local isLocal = true
		local topScoresOnly = true
		local loggedIn = DLMAN:IsLoggedIn()

		local scoreItemWidth = frameWidth / 1.7
		local scoreItemHeight = frameHeight / 8
		local scoreItemX = frameWidth / 6 + 3 + 2 -- button width + divider width + spacing width
		local scoreItemY = 8
		local scoreItemSpacing = spacing

		local t = Def.ActorFrame {
			Name = "ScoreBoardContainer",
			InitCommand = function(self)
				lbActor = self
			end,
			OnCommand = function(self)
				self:addy(-25)
				self:bouncy(0.2)
				self:addy(25)
				SCREENMAN:GetTopScreen():AddInputCallback(scoreboardInput)
				self:queuecommand("UpdateScores")
			end,
			OffCommand = function(self)
				self:stoptweening()
				self:bouncy(0.2)
				self:x(SCREEN_CENTER_X*3/2-frameWidth/2 + 100)
				self:diffusealpha(0)
			end,
			UpdateScoresMessageCommand = function(self, params)
				if isLocal then
					scoreList = getScoreTable(player, getCurRate())
				else
					scoreList = DLMAN:GetChartLeaderBoard(steps:GetChartKey(), currentCountry)
					if #scoreList == 0 and not alreadyPulled then
						updateLeaderBoardForCurrentChart()
					end
				end
				curPage = 1
				if scoreList ~= nil then
					maxPages = math.ceil(#scoreList / scoresPerPage)
				else
					maxPages = 1
				end
				if isLocal or #scoreList ~= 0 then
					self:queuecommand("Set")
				elseif #scoreList == 0 then
					self:queuecommand("ListEmpty")
				end

			end,
			SetFromLeaderboardCommand = function(self, leaderboard)
				self:queuecommand("UpdateScores")
			end,

			-- the quad for the background of the container
			Def.Quad {
				InitCommand = function(self)
					self:zoomto(frameWidth, frameHeight)
					self:halign(0):valign(0)
					self:diffuse(getMainColor("frame")):diffusealpha(0.8)
				end,
				WheelUpSlowMessageCommand = function(self)
					if self:isOver() and maxPages > 1 then
						movePage(-1)
					end
				end,
				WheelDownSlowMessageCommand = function(self)
					if self:isOver() and maxPages > 1 then
						movePage(1)
					end
				end
			},

			-- the sneaky quad for the divider between this container and the one below
			Def.Quad {
				InitCommand = function(self)
					self:y(frameHeight - 1)
					self:zoomto(frameWidth,1)
					self:halign(0):valign(0)
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
				end
			},

			-- the quad for other divider just separating stuff
			Def.Quad {
				InitCommand = function(self)
					self:xy(frameWidth/6, 5)
					self:zoomto(2,frameHeight - 10)
					self:halign(0):valign(0)
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
				end
			},

			-- Page info text
			LoadFont("Common Normal") .. {
				InitCommand = function(self)
					--self:settext("Showing ? - ? of ? scores")
					self:zoom(0.35)
					self:xy((frameWidth - (frameWidth/6))/2 + frameWidth/6, frameHeight - 25)
				end,
				SetCommand = function(self)
					self:settextf("Showing %d - %d of %d scores", (curPage-1) * scoresPerPage + 1, math.min((curPage) * scoresPerPage,#scoreList), #scoreList)
				end,
				UpdateListMessageCommand = function(self)
					self:playcommand("Set")
				end,
				ListEmptyCommand = function(self)
					self:settext("Showing 0 - 0 of 0 scores")
				end
			},

			-- Sort info text
			LoadFont("Common Normal") .. {
				InitCommand = function(self)
					--self:settext("Placeholder.")
					self:zoom(0.35)
					self:xy((frameWidth - (frameWidth/6))/2 + frameWidth/6, frameHeight - 15)
				end,
				SetCommand = function(self)
					if isLocal then
						self:settext("Highest local scores for this rate")
					else
						local allRates = not DLMAN:GetCurrentRateFilter()
						local allScores = not DLMAN:GetTopScoresOnlyFilter()
						if allRates and allScores then
							self:settext("All online scores for all rates")
						elseif allRates and not allScores then
							self:settext("Highest online scores for all rates")
						elseif not allRates and allScores then
							self:settext("All online scores for this rate") -- this is actually no different from the one below
						else
							self:settext("Highest online scores for this rate") -- but i wanted to make the distinction
						end
					end
				end,
				ListEmptyCommand = function(self)
					self:settext("No scores found")
				end
			},

			-- Basic info text
			LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:settext("Click for Offset Plot")
					self:zoom(0.2)
					self:valign(0)
					self:xy(scoreItemX + scoreItemWidth/2, (scoreItemHeight + scoreItemSpacing + 1) * scoresPerPage + scoreItemY)
					self:diffusealpha(0)
				end,
				UpdateListMessageCommand = function(self)
					local scoresOnThisPage = math.abs((curPage-1) * scoresPerPage + 1 - math.min((curPage) * scoresPerPage,#scoreList))
					if #scoreList == 0 then
						self:diffusealpha(0)
						return
					end
					self:stoptweening()
					self:diffusealpha(0)
					self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY - 8)
					self:sleep((scoresOnThisPage+1)*0.03)
					self:diffusealpha(1)
					self:easeOut(0.5)
					self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY + 2)
				end,
				UpdateScoresCommand = function(self)
					self:playcommand("UpdateList")
				end,
				ListEmptyCommand = function(self)
					self:playcommand("UpdateList")
				end
			},

			-- Basic info text 2
			LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:settext("Click for Replay")
					self:zoom(0.2)
					self:valign(0)
					self:diffusealpha(0)
					self:xy(scoreItemX + scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20)/2, (scoreItemHeight + scoreItemSpacing + 1) * scoresPerPage + scoreItemY)
				end,
				UpdateListMessageCommand = function(self)
					local scoresOnThisPage = math.abs((curPage-1) * scoresPerPage + 1 - math.min((curPage) * scoresPerPage,#scoreList))
					if #scoreList == 0 then
						self:diffusealpha(0)
						return
					end
					self:stoptweening()
					self:diffusealpha(0)
					self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY - 8)
					self:sleep((scoresOnThisPage+1)*0.03)
					self:diffusealpha(1)
					self:easeOut(0.5)
					self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY + 2)
				end,
				UpdateScoresCommand = function(self)
					self:playcommand("UpdateList")
				end,
				ListEmptyCommand = function(self)
					self:playcommand("UpdateList")
				end
			},

			-- Local scores button
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(3, 8)
					self:zoomto(frameWidth/6 - 6, frameHeight / 8)
					self:halign(0):valign(0)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					if not loggedIn then
						self:diffusealpha(0.05)
						return
					end
					if not isLocal then
						self:diffusealpha(0.1)
					else
						self:diffusealpha(0.4)
					end
				end,
				MouseDownCommand = function(self)
					if not isLocal and loggedIn and not usingSimpleScreen then
						isLocal = true
						self:GetParent():queuecommand("UpdateScores")
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Bold") .. {
				InitCommand = function(self)
					self:settext("Local")
					self:zoom(0.45)
					self:xy(3, 8)
					self:addx((frameWidth/6 - 6)/2)
					self:addy((frameHeight / 8)/2)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if not loggedIn then
						self:diffusealpha(0.05)
						return
					else
						self:diffusealpha(1)
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},

			-- Online scores button
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(3, 8 + (frameHeight / 8) + spacing)
					self:zoomto(frameWidth/6 - 6, frameHeight / 8)
					self:halign(0):valign(0)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if not loggedIn then
						self:diffusealpha(0.05)
						return
					end
					if isLocal then
						self:diffusealpha(0.1)
					else
						self:diffusealpha(0.4)
					end
				end,
				MouseDownCommand = function(self)
					if isLocal and loggedIn and not usingSimpleScreen then
						isLocal = false
						self:GetParent():queuecommand("UpdateScores")
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Bold") .. {
				InitCommand = function(self)
					self:settext("Online")
					self:zoom(0.45)
					self:xy(3, 8 + (frameHeight / 8) + spacing)
					self:addx((frameWidth/6 - 6)/2)
					self:addy((frameHeight / 8)/2)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if not loggedIn then
						self:diffusealpha(0.05)
						return
					else
						self:diffusealpha(1)
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},

			-- Current rate button
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2) * 2 - spacing)
					self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
					self:halign(0):valign(0)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						if DLMAN:GetCurrentRateFilter() then
							self:diffusealpha(0.4)
						else
							self:diffusealpha(0.1)
						end
					end
				end,
				MouseDownCommand = function(self)
					if not isLocal and loggedIn and not usingSimpleScreen then
						if not DLMAN:GetCurrentRateFilter() then
							DLMAN:ToggleRateFilter()
							self:GetParent():queuecommand("UpdateScores")
						end
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Bold") .. {
				InitCommand = function(self)
					self:settext("Current Rate")
					self:zoom(0.25)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2) * 2 - spacing)
					self:addx((frameWidth/6 - 6)/2)
					self:addy((frameHeight / 8 / 2)/2)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						self:diffusealpha(1)
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},

			-- All rates button
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2))
					self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
					self:halign(0):valign(0)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						if DLMAN:GetCurrentRateFilter() then
							self:diffusealpha(0.1)
						else
							self:diffusealpha(0.4)
						end
					end
				end,
				MouseDownCommand = function(self)
					if not isLocal and loggedIn and not usingSimpleScreen then
						if DLMAN:GetCurrentRateFilter() then
							DLMAN:ToggleRateFilter()
							self:GetParent():queuecommand("UpdateScores")
						end
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Bold") .. {
				InitCommand = function(self)
					self:settext("All Rates")
					self:zoom(0.25)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2))
					self:addx((frameWidth/6 - 6)/2)
					self:addy((frameHeight / 8 / 2)/2)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						self:diffusealpha(1)
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},

			-- Top Scores button
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2)*3 - spacing*3)
					self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
					self:halign(0):valign(0)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						if DLMAN:GetTopScoresOnlyFilter() then
							self:diffusealpha(0.4)
						else
							self:diffusealpha(0.1)
						end
					end
				end,
				MouseDownCommand = function(self)
					if not isLocal and loggedIn and not usingSimpleScreen then
						if not DLMAN:GetTopScoresOnlyFilter() then
							DLMAN:ToggleTopScoresOnlyFilter()
							self:GetParent():queuecommand("UpdateScores")
						end
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Bold") .. {
				InitCommand = function(self)
					self:settext("Top Scores")
					self:zoom(0.25)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2)*3 - spacing*3)
					self:addx((frameWidth/6 - 6)/2)
					self:addy((frameHeight / 8 / 2)/2)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						self:diffusealpha(1)
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},

			-- All Scores button
			quadButton(6) .. {
				InitCommand = function(self)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2)*4 - spacing*4)
					self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
					self:halign(0):valign(0)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						if DLMAN:GetTopScoresOnlyFilter() then
							self:diffusealpha(0.1)
						else
							self:diffusealpha(0.4)
						end
					end
				end,
				MouseDownCommand = function(self)
					if not isLocal and loggedIn and not usingSimpleScreen then
						if DLMAN:GetTopScoresOnlyFilter() then
							DLMAN:ToggleTopScoresOnlyFilter()
							self:GetParent():queuecommand("UpdateScores")
						end
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Bold") .. {
				InitCommand = function(self)
					self:settext("All Scores")
					self:zoom(0.25)
					self:xy(3, frameHeight - 8 - (frameHeight/8/2)*4 - spacing*4)
					self:addx((frameWidth/6 - 6)/2)
					self:addy((frameHeight / 8 / 2)/2)
					self:diffusealpha(0.05)
				end,
				SetCommand = function(self)
					self:linear(0.1)
					if isLocal then
						self:diffusealpha(0.05)
					else
						self:diffusealpha(1)
					end
				end,
				ListEmptyCommand = function(self)
					self:queuecommand("Set")
				end
			}
		}

		-- individual items for the score buttons
		local function scoreItem(i)
			local scoreIndex = (curPage - 1) * scoresPerPage + i

			local d = Def.ActorFrame {
				InitCommand = function(self)
					self:xy(scoreItemX, scoreItemY + (i-1) * (scoreItemHeight + scoreItemSpacing))
					self:diffusealpha(0)
				end,
				ShowCommand = function(self)
					self:y(scoreItemY + (i-1)*(scoreItemHeight + scoreItemSpacing)-10)
					self:diffusealpha(0)
					self:finishtweening()
					self:sleep(math.max(0.01, (i-1)*0.03))
					self:easeOut(1)
					self:y(scoreItemY + (i-1)*(scoreItemHeight + scoreItemSpacing))
					self:diffusealpha(1)
				end,
				HideCommand = function(self)
					self:stoptweening()
					self:easeOut(0.5)
					self:diffusealpha(0)
					self:y(SCREEN_HEIGHT*10)
				end,
				UpdateListMessageCommand = function(self)
					self:playcommand("UpdateScores")
				end,
				UpdateScoresMessageCommand = function(self)
					scoreIndex = (curPage - 1) * scoresPerPage + i
					if scoreList[scoreIndex] ~= nil then
						self:playcommand("Show")
					else
						self:playcommand("Hide")
					end
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				end
			}

			-- BG+Button for score item
			d[#d+1] = quadButton(6) .. {
				InitCommand = function(self)
					self:halign(0):valign(0)
					self:diffusealpha(0.1)
					self:zoomto(scoreItemWidth, scoreItemHeight)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] ~= nil and ((scoreIndex == offsetIndex and offsetisLocal and isLocal) or (scoreList[scoreIndex]:GetScoreid() == offsetScoreID and not offsetisLocal and not isLocal) or (isLocal and offsetIndex == nil and scoreIndex == newScoreboardInitialLocalIndex)) then
						self:diffusealpha(0.3)
					else
						self:diffusealpha(0.1)
					end
				end,
				MouseDownCommand = function(self)
					if scoreList[scoreIndex] == nil or not scoreList[scoreIndex]:HasReplayData() or usingSimpleScreen then
						return
					end
					newScoreboardInitialLocalIndex = 0
					offsetIndex = scoreIndex
					offsetScoreID = scoreList[scoreIndex]:GetScoreid()
					offsetisLocal = isLocal
					MESSAGEMAN:Broadcast("ShowScoreOffset")
					self:finishtweening()
					self:diffusealpha(0.3)
					self:GetParent():GetParent():playcommand("Set")
				end
			}

			-- symbol indicating that this is the score you just set
			d[#d+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
				Name = "CurrentScoreIndicator",
				InitCommand = function(self)
					self:zoom(0.10)
					self:diffusealpha(0.8)
					self:rotationz(90)
					self:diffuse(color("#aaaaff"))
					self:diffusealpha(0)
					self:xy(3, scoreItemHeight/4)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					if (isLocal == true and scoreIndex == newScoreboardInitialLocalIndex2) then
						self:linear(0.1)
						self:diffusealpha(1)
					else
						self:diffusealpha(0)
					end
				end
			}

			-- grade
			d[#d+1] = LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(22,scoreItemHeight/4)
					self:zoom(0.3)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					local grade = scoreList[scoreIndex]:GetWifeGrade()
					self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
					self:diffuse(getGradeColor(grade))
				end
			}
			-- cleartype
			d[#d+1] = LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(22,scoreItemHeight/4 * 3)
					self:zoom(0.3)
					self:maxwidth(135)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					local clearType = getClearType(PLAYER_1, steps, scoreList[scoreIndex])
					self:settext(getClearTypeShortText(clearType))
					self:diffuse(getClearTypeColor(clearType))
				end
			}
			-- score percent and judgments
			d[#d+1] = LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(45,scoreItemHeight/4)
					self:halign(0)
					self:zoom(0.3)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					local score = scoreList[scoreIndex]:GetWifeScore()
					local w1 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W1")
					local w2 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W2")
					local w3 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W3")
					local w4 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W4")
					local w5 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W5")
					local miss = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_Miss")
					if score >= 0.99 then
						self:settextf("%0.4f%% | %d - %d - %d - %d - %d - %d",math.floor(score*1000000)/10000, w1, w2, w3, w4, w5, miss)
						self:AddAttribute(11, {Length = #tostring(w1), Diffuse = byJudgment("TapNoteScore_W1")})
						self:AddAttribute(14 + #tostring(w1), {Length = #tostring(w2), Diffuse = byJudgment("TapNoteScore_W2")})
						self:AddAttribute(17 + #tostring(w1) + #tostring(w2), {Length = #tostring(w3), Diffuse = byJudgment("TapNoteScore_W3")})
						self:AddAttribute(20 + #tostring(w1) + #tostring(w2) + #tostring(w3), {Length = #tostring(w4), Diffuse = byJudgment("TapNoteScore_W4")})
						self:AddAttribute(23 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4), {Length = #tostring(w5), Diffuse = byJudgment("TapNoteScore_W5")})
						self:AddAttribute(26 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4) + #tostring(w5), {Length = #tostring(miss), Diffuse = byJudgment("TapNoteScore_Miss")})
					else
						self:settextf("%0.2f%% | %d - %d - %d - %d - %d - %d",math.floor(score*10000)/100, w1, w2, w3, w4, w5, miss)
						self:AddAttribute(9, {Length = #tostring(w1), Diffuse = byJudgment("TapNoteScore_W1")})
						self:AddAttribute(12 + #tostring(w1), {Length = #tostring(w2), Diffuse = byJudgment("TapNoteScore_W2")})
						self:AddAttribute(15 + #tostring(w1) + #tostring(w2), {Length = #tostring(w3), Diffuse = byJudgment("TapNoteScore_W3")})
						self:AddAttribute(18 + #tostring(w1) + #tostring(w2) + #tostring(w3), {Length = #tostring(w4), Diffuse = byJudgment("TapNoteScore_W4")})
						self:AddAttribute(21 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4), {Length = #tostring(w5), Diffuse = byJudgment("TapNoteScore_W5")})
						self:AddAttribute(24 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4) + #tostring(w5), {Length = #tostring(miss), Diffuse = byJudgment("TapNoteScore_Miss")})
					end
				end
			}
			-- date and ssr
			d[#d+1] = LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(45,scoreItemHeight/4 * 3)
					self:halign(0)
					self:zoom(0.3)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					local date = scoreList[scoreIndex]:GetDate()
					local ssr = scoreList[scoreIndex]:GetSkillsetSSR("Overall")
					self:settextf("%s | %0.2f", date, ssr)
					self:AddAttribute(#date + #" | ", {Length = -1, Diffuse = byMSD(ssr)})
				end
			}

			-- BG quad for score item player info
			d[#d+1] = quadButton(6) .. {
				InitCommand = function(self)
					self:addx(scoreItemWidth + 10)
					self:halign(0):valign(0)
					self:diffusealpha(0.1)
					self:zoomto(frameWidth - scoreItemWidth - scoreItemX - 20, scoreItemHeight)
				end,
				MouseDownCommand = function(self)
					if scoreList[scoreIndex] == nil or not scoreList[scoreIndex]:HasReplayData() or usingSimpleScreen then
						return
					end
					GHETTOGAMESTATE:setReplay(scoreList[scoreIndex], not isLocal)
					SCREENMAN:GetTopScreen():Cancel()
				end
			}

			-- Tiny green box that means the score has replay data
			d[#d+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
				InitCommand = function(self)
					self:addx(scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20) - 5)
					self:addy(scoreItemHeight * 3/4)
					self:diffuse(color("#00ff00"))
					self:zoom(0.12)
					self:visible(false)
					self:rotationz(90)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					self:visible(scoreList[scoreIndex]:HasReplayData())
				end
			}

			-- player name
			d[#d+1] = LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20)/2,scoreItemHeight/4)
					self:maxwidth((frameWidth - scoreItemWidth - scoreItemX - 20)*3)
					self:zoom(0.3)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					local name = profile:GetDisplayName()
					if not isLocal then
						name = scoreList[scoreIndex]:GetDisplayName()
					end
					self:settext(name)
				end
			}

			-- rate
			d[#d+1] = LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20)/2,scoreItemHeight/4 * 3)
					self:maxwidth((frameWidth - scoreItemWidth - scoreItemX - 20)*3)
					self:zoom(0.3)
				end,
				SetCommand = function(self)
					if scoreList[scoreIndex] == nil then
						return
					end
					local ratestring = "("..string.format("%.2f", scoreList[scoreIndex]:GetMusicRate()):gsub("%.?0$", "") .. "x)"
					self:settext(ratestring)
				end
			}


			return d

		end

		for i=1, scoresPerPage do
			t[#t+1] = scoreItem(i)
		end


		return t
	end

	
	local newScoreboard = themeConfig:get_data().global.EvalScoreboard
	local inMulti = NSMAN:IsETTP() and IsSMOnlineLoggedIn() or false
	if newScoreboard and not inMulti then
		t[#t+1] = boardOfScores() .. {
			InitCommand = function(self)
				self:xy(SCREEN_CENTER_X*3/2-frameWidth/2, SCREEN_HEIGHT - 180 - 150)
			end
		}
	elseif not inMulti then
		t[#t+1] = LoadActor("scoreboard")
	else
		t[#t+1] = LoadActor("MPscoreboard")
	end
	return t
end

local function offsetStuff()
	local offsetParamX = SCREEN_CENTER_X*3/2-frameWidth/2
	local offsetParamY = SCREEN_HEIGHT - 180
	local offsetParamZoom = 0.5
	local offsetParamWidth = frameWidth
	local offsetParamHeight = 150

	local altOffsetParamX = 41/1066 * SCREEN_WIDTH
	local altOffsetParamY = offsetY2
	local altOffsetParamZoom = 0.5
	local altOffsetParamWidth = offsetWidth2
	local altOffsetParamHeight = offsetHeight2

	local localparamscopy = {}
	local selectedparamscopy = {}

	-- im stupid
	local function setOffsetParams()
		if usingSimpleScreen then
			offsetParamX = altOffsetParamX
			offsetParamY = altOffsetParamY
			offsetParamZoom = altOffsetParamZoom
			offsetParamWidth = altOffsetParamWidth
			offsetParamHeight = altOffsetParamHeight
		else
			offsetParamX = SCREEN_CENTER_X*3/2-frameWidth/2
			offsetParamY = SCREEN_HEIGHT - 180
			offsetParamZoom = 0.5
			offsetParamWidth = frameWidth
			offsetParamHeight = 150
		end
	end
	setOffsetParams()

	local t = Def.ActorFrame {}
	local function offsetInput(event)
		if event.type == "InputEventType_FirstPress" then
			local outputName = ""
			if event.button == "EffectUp" then
				outputName = "NextJudge"
			elseif event.button == "EffectDown" then
				outputName = "PrevJudge"
			elseif event.button == "MenuDown" then
				outputName = "ToggleHands"
			elseif event.button == "MenuUp" then
				outputName = "ResetJudge"
			end

			if outputName ~= "" then
				MESSAGEMAN:Broadcast("OffsetPlotModification", {Name = outputName})
			end

			if (INPUTFILTER:IsBeingPressed("left ctrl") or INPUTFILTER:IsBeingPressed("right ctrl")) and
			event.DeviceInput.button == "DeviceButton_a" then
				usingSimpleScreen = not usingSimpleScreen
				MESSAGEMAN:Broadcast("SwitchEvalTypes")
			end
		end
	end

	t[#t+1] = LoadActor(THEME:GetPathG("","OffsetGraph"))..{
		InitCommand = function(self, params)
			self:xy(offsetParamX, offsetParamY)
			self:zoom(offsetParamZoom)

			local pn = GAMESTATE:GetEnabledPlayers()[1]
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
			local steps = GAMESTATE:GetCurrentSteps(pn)

			self:RunCommandsOnChildren(function(self)
				local params = 	{width = offsetParamWidth, 
								height = offsetParamHeight,
								song = song, 
								steps = steps, 
								nrv = nrv,
								dvt = dvt,
								ctt = ctt,
								ntt = ntt,
								columns = steps:GetNumColumns()}
				localparamscopy = params
				self:playcommand("Update", params) end
			)
		end,
		SwitchEvalTypesMessageCommand = function(self)
			setOffsetParams()
			self:bouncy(0.3)
			self:xy(offsetParamX, offsetParamY)
			if selectedparamscopy["width"] == nil then
				selectedparamscopy = localparamscopy
			end
			if localparamscopy["width"] == nil then
				localparamscopy = selectedparamscopy
			end
			selectedparamscopy.width = offsetParamWidth
			selectedparamscopy.height = offsetParamHeight
			localparamscopy.width = offsetParamWidth
			localparamscopy.height = offsetParamHeight
			if usingSimpleScreen then
				self:RunCommandsOnChildren(function(self) self:playcommand("Update", localparamscopy) end)
			else
				self:RunCommandsOnChildren(function(self) self:playcommand("Update", selectedparamscopy) end)
			end
		end,
		ShowScoreOffsetMessageCommand = function(self, params)
			if scoreList[offsetIndex]:HasReplayData() then
				if not offsetisLocal then
					DLMAN:RequestOnlineScoreReplayData(
						scoreList[offsetIndex],
						function()
							MESSAGEMAN:Broadcast("DelayedShowOffset")
						end
					)
				else
					MESSAGEMAN:Broadcast("DelayedShowOffset")
				end
			else
				self:RunCommandsOnChildren(function(self) self:playcommand("Update", {width = offsetParamWidth, height = offsetParamHeight}) end)
			end
		end,
		DelayedShowOffsetMessageCommand = function(self)
			self:RunCommandsOnChildren(function(self)
				local params = 	{width = offsetParamWidth, 
								height = offsetParamHeight, 
								song = song, 
								steps = steps, 
								nrv = scoreList[offsetIndex]:GetNoteRowVector(),
								dvt = scoreList[offsetIndex]:GetOffsetVector(),
								ctt = scoreList[offsetIndex]:GetTrackVector(),
								ntt = scoreList[offsetIndex]:GetTapNoteTypeVector(),
								columns = steps:GetNumColumns()}
				selectedparamscopy = params
				self:playcommand("Update", params) end
			)
		end,
		OnCommand = function(self)
			self:stoptweening()
			self:zoom(1)
			self:addy(25)
			self:bouncy(0.2)
			self:addy(-25)
			self:xy(offsetParamX, offsetParamY)
			self:diffusealpha(1)
			SCREENMAN:GetTopScreen():AddInputCallback(offsetInput)
		end,
		OffCommand = function(self)
			self:stoptweening()
			self:bouncy(0.2)
			self:x(offsetParamX + 100)
			self:diffusealpha(0)
		end

	}

	-- Missing noterows text
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(SCREEN_WIDTH * 3/4, SCREEN_HEIGHT * 3/4)
			self:settext("Missing Noterows from Online Replay\n(゜´Д｀゜)")
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.6)
			self:visible(false)
		end,
		DelayedShowOffsetMessageCommand = function(self)
			if scoreList[offsetIndex]:GetNoteRowVector() == nil then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	}
	return t
end



local function newEvalStuff()
	-- below are many measurements taken of the reference graphic for positioning
	local leftSideSpacingReferenceRatio = 41/1066
	local rightSideSpacingReferenceRatio = 36/1066
	local playerInfoWidthReferenceRatio = 256/1066
	local playerInfoHeightReferenceRatio = 160/600
	local headerHeightReferenceRatio = 28/600
	local dividerHeightReferenceRatio = 3/600
	local upperDivider1SpacingReferenceRatio = 59/600
	local upperDivider2SpacingReferenceRatio = 101/600
	local lowerDivider2SpacingReferenceRatio = 386/600
	local lowerDivider1SpacingReferenceRatio = 287/600
	local titleSectionReferenceRatio = upperDivider1SpacingReferenceRatio
	local gradeSectionReferenceRatio = 39/600
	local judgmentSectionReferenceRatio = 183/600 + headerHeightReferenceRatio
	local radarSectionReferenceRatio = 96/600 + headerHeightReferenceRatio
	local miscSectionReferenceRatio = 28/600 + headerHeightReferenceRatio
	local offsetSectionReferenceRatio = 155/600 + headerHeightReferenceRatio
	local offsetPlotReferenceRatio = 133/600
	local edgeTextSpacing1ReferenceRatio = 11/1066
	local edgeTextSpacing2ReferenceRatio = 14/1066
	local difficultySpacingReferenceRatio = 15/1066
	-- these next 5 numbers are not exact to the reference, just fudged for "correctness"
	local judgmentTextSpacingFromDividerReferenceRatio = 15/600
	local judgmentTextSpacingFromLowerDividerReferenceRatio = 19/600
	local radarTextSpacingFromDividerReferenceRatio = 16/600
	local radarTextSpacingFromLowerDividerReferenceRatio = 17/600
	local meanTextSpacingFromDividerReferenceRatio = 12/600

	local avatarReferenceRatio = 82/1066 -- its a square so use the smaller one i guess
	local avatarTopEdgeReferenceRatio = 8/600
	local avatarLeftEdgeReferenceRatio = 11/1066
	local playerNameWidthReferenceRatio = 153/1066
	local playerNameBottomReferenceRatio = 45/600
	local playerRatingTopReferenceRatio = 57/600
	local playerInfoDateTopReferenceRatio = 102/600
	local playerInfoModsTopReferenceRatio = 130/600

	local screenHeaderOffset = 20
	local screenFooterOffset = 20
	local playerInfoRightX = SCREEN_WIDTH - SCREEN_WIDTH * rightSideSpacingReferenceRatio
	local playerInfoBottomY = SCREEN_HEIGHT - screenFooterOffset -- it sits on the bottom of the screen
	local playerInfoFrameWidth = SCREEN_WIDTH * playerInfoWidthReferenceRatio
	local playerInfoFrameHeight = SCREEN_HEIGHT * playerInfoHeightReferenceRatio
	local playerInfoAvatarWH = SCREEN_WIDTH * avatarReferenceRatio -- a square, use width and height the same
	local frameCenterX = SCREEN_WIDTH * leftSideSpacingReferenceRatio + SCREEN_WIDTH/4
	local frameCenterY = SCREEN_CENTER_Y + screenFooterOffset - screenHeaderOffset
	local frameWidth = SCREEN_WIDTH/2
	local frameHeight = SCREEN_HEIGHT - screenHeaderOffset - screenFooterOffset
	local frameHeaderHeight = (SCREEN_HEIGHT - screenHeaderOffset - screenFooterOffset) * headerHeightReferenceRatio
	local frameHeaderY = -frameHeight/2 + frameHeaderHeight/2 -- no valign means find middle Y pos

	local upperDivider1SpacingRatio = upperDivider1SpacingReferenceRatio + headerHeightReferenceRatio -- ref ratio measurements were taken relative to header
	local upperDivider2SpacingRatio = upperDivider2SpacingReferenceRatio + headerHeightReferenceRatio
	local lowerDivider1SpacingRatio = lowerDivider1SpacingReferenceRatio + headerHeightReferenceRatio
	local lowerDivider2SpacingRatio = lowerDivider2SpacingReferenceRatio + headerHeightReferenceRatio
	local dividerHeight = SCREEN_HEIGHT * dividerHeightReferenceRatio
	local upperDivider1Y = -frameHeight/2 + frameHeight * upperDivider1SpacingRatio + dividerHeight/2 -- no valign means find middle Y pos
	local upperDivider2Y = -frameHeight/2 + frameHeight * upperDivider2SpacingRatio + dividerHeight/2
	local lowerDivider1Y = -frameHeight/2 + frameHeight * lowerDivider1SpacingRatio + dividerHeight/2
	local lowerDivider2Y = -frameHeight/2 + frameHeight * lowerDivider2SpacingRatio + dividerHeight/2

	local edgeTextSpacing1 = SCREEN_WIDTH * edgeTextSpacing1ReferenceRatio
	local edgeTextSpacing2 = SCREEN_WIDTH * edgeTextSpacing2ReferenceRatio
	local difficultySpacing = edgeTextSpacing2

	local headerColor = getMainColor("highlight")
	local boardBGColor = color("0,0,0,0.75")
	local dividerColor = color(".8,.8,.8,1")
	local mainTextColor = color("1,1,1,1")

	local mainTextScale = 0.62
	local smallerTextScale = 0.6
	local msdTextScale = 0.45
	local biggerTextScale = 0.9
	local judgmentSectionTextScale = 0.7

	offsetWidth2 = frameWidth
	offsetHeight2 = SCREEN_HEIGHT * offsetPlotReferenceRatio
	offsetY2 = SCREEN_HEIGHT - offsetHeight2 - screenFooterOffset

	local player = GAMESTATE:GetEnabledPlayers()[1]
	local profile = GetPlayerOrMachineProfile(player)
	local hsTable = getScoreTable(player, getCurRate())
	local score = pss:GetHighScore()
	local scoreIndex = getHighScoreIndex(hsTable, score)

	-- stolen from earlier in this same file without any shame
	-- stolen from Til Death without any shame
	local tracks = pss:GetTrackVector()
	local devianceTable = pss:GetOffsetVector()
	local cbl = 0
	local cbr = 0
	local cbm = 0

	local tst = ms.JudgeScalers
	local tso = tst[judge]
	if enabledCustomWindows then
		tso = 1
	end
	local ncol = GAMESTATE:GetCurrentSteps(PLAYER_1):GetNumColumns() - 1
	local middleCol = ncol / 2
	local function recountCBs()
		cbl = 0
		cbr = 0
		cbm = 0
		for i = 1, #devianceTable do
			if tracks[i] then
				if math.abs(devianceTable[i]) > tso * 90 then
					if tracks[i] < middleCol then
						cbl = cbl + 1
					elseif tracks[i] > middleCol then
						cbr = cbr + 1
					else
						cbm = cbm + 1
					end
				end
			end
		end
	end
	recountCBs()

	local statInfo = {
		mean = wifeMean(devianceTable),
		absmean = wifeAbsMean(devianceTable),
		sd = wifeSd(devianceTable),
	}

	local showMiddle = middleCol == math.floor(middleCol)

	local function highlightSD(self)
		self:GetChild("Mean"):queuecommand("Highlight")
	end

	local t = Def.ActorFrame {
		InitCommand = function(self)
			if not usingSimpleScreen then
				self:addy(SCREEN_HEIGHT)
			end
		end,
		SwitchEvalTypesMessageCommand = function(self)
			self:visible(true)
			if not usingSimpleScreen then
				self:bouncy(0.3)
				self:addy(SCREEN_HEIGHT)
			else
				self:bouncy(0.3)
				self:addy(-SCREEN_HEIGHT)
				self:diffusealpha(1)
			end
		end,
		OffsetPlotModificationMessageCommand = function(self, params)
			if params.Name == "ResetJudge" then
				if PREFSMAN:GetPreference("SortBySSRNormPercent") then
					judge = 4
					rescoredPercentage = score:GetWifeScore() * 100
					self:queuecommand("SetJudge", params)
				else
					recountCBs()
					self:queuecommand("ResetJudge")
				end
			elseif params.Name ~= "ToggleHands" then
				self:queuecommand("SetJudge", params)
			end
		end,
		ForceUpdateAllInfoMessageCommand = function(self)
			recountCBs()
			self:RunCommandsOnChildren(function(self) self:queuecommand("SetJudge") end)
		end
	}

	local function judgmentTexts()
		local function oneText(i)
			local thisJudgment = judges[i]
			return LoadFont("Common Normal") .. {
				Name = thisJudgment,
				InitCommand = function(self)
					self:halign(0)
					-- im crying laughing
					self:xy(-frameWidth/2 + edgeTextSpacing1, upperDivider2Y + dividerHeight/2 + frameHeight * judgmentTextSpacingFromDividerReferenceRatio + (frameHeight * (judgmentSectionReferenceRatio - judgmentTextSpacingFromDividerReferenceRatio - judgmentTextSpacingFromLowerDividerReferenceRatio)) / #judges * (i-1))
					self:zoom(judgmentSectionTextScale)
					self:settext(getJudgeStrings(thisJudgment) .. ":")
					self:diffuse(TapNoteScoreToColor(thisJudgment))
				end
			}
		end
		local t = Def.ActorFrame {}
		for i = 1,#judges do
			t[#t+1] = oneText(i)
		end
		return t
	end
	local function judgmentCounts()
		local function oneSet(i)
			local thisJudgment = judges[i]
			local count
			local percent
			return Def.ActorFrame {
				Name = "Frame_"..thisJudgment,
				BeginCommand = function(self)
					count = pss:GetHighScore():GetTapNoteScore(thisJudgment)
					percent = pss:GetPercentageOfTaps(thisJudgment) * 100
				end,
				SetJudgeCommand = function(self)
					if enabledCustomWindows then
						percent = getRescoredCustomJudge(dvt, customWindow.judgeWindows, i) / totalTaps * 100
						count = getRescoredCustomJudge(dvt, customWindow.judgeWindows, i)
					else
						percent = getRescoredJudge(dvt, judge, i) / totalTaps * 100
						count = getRescoredJudge(dvt, judge, i)
					end
				end,
				ResetJudgeCommand = function(self)
					count = pss:GetHighScore():GetTapNoteScore(thisJudgment)
					percent = pss:GetPercentageOfTaps(thisJudgment) * 100
				end,
				LoadFont("Common Normal") .. {
					Name = "Counts_"..thisJudgment,
					InitCommand = function(self)
						self:y(upperDivider2Y + dividerHeight/2 + frameHeight * judgmentTextSpacingFromDividerReferenceRatio + (frameHeight * (judgmentSectionReferenceRatio - judgmentTextSpacingFromDividerReferenceRatio - judgmentTextSpacingFromLowerDividerReferenceRatio)) / #judges * (i-1))
						self:settext("")
						self:zoom(judgmentSectionTextScale)
					end,
					BeginCommand = function(self)
						self:settextf("%d", count)
					end,
					SetJudgeCommand = function(self)
						self:playcommand("Begin")
					end,
					ResetJudgeCommand = function(self)
						self:playcommand("Begin")
					end
				},
				LoadFont("Common Normal") .. {
					Name = "Percentage_"..thisJudgment,
					InitCommand = function(self)
						self:halign(1)
						self:x(frameWidth/2 - edgeTextSpacing1)
						self:y(upperDivider2Y + dividerHeight/2 + frameHeight * judgmentTextSpacingFromDividerReferenceRatio + (frameHeight * (judgmentSectionReferenceRatio - judgmentTextSpacingFromDividerReferenceRatio - judgmentTextSpacingFromLowerDividerReferenceRatio)) / #judges * (i-1))
						self:settext("")
						self:zoom(judgmentSectionTextScale)
						self:diffuse(TapNoteScoreToColor(thisJudgment))
					end,
					BeginCommand = function(self)
						self:settextf("%5.2f%%", percent)
					end,
					SetJudgeCommand = function(self)
						self:playcommand("Begin")
					end,
					ResetJudgeCommand = function(self)
						self:playcommand("Begin")
					end
				}
			}
		end
		local t = Def.ActorFrame {}
		for i = 1,#judges do
			t[#t+1] = oneSet(i)
		end
		return t
	end


	local function radarTexts()
		local radars = {"Holds", "Mines", "Rolls"}
		local function oneText(i)
			local thisRadar = radars[i]
			local thisRadarCategory = "RadarCategory_"..radars[i]
			local possible
			local count
			return Def.ActorFrame {
				Name = "Frame_"..thisRadar,
				BeginCommand = function(self)
					possible = pss:GetRadarPossible():GetValue(thisRadarCategory)
					count = pss:GetRadarActual():GetValue(thisRadarCategory)
				end,
				LoadFont("Common Normal") .. {
					Name = "Name_"..thisRadar,
					InitCommand = function(self)
						self:halign(0)
						-- hahahahaha
						self:xy(-frameWidth/2 + edgeTextSpacing1, lowerDivider1Y + dividerHeight/2 + frameHeight * radarTextSpacingFromDividerReferenceRatio + (frameHeight * (radarSectionReferenceRatio - radarTextSpacingFromDividerReferenceRatio - radarTextSpacingFromLowerDividerReferenceRatio)) / #radars * (i-1))
						self:zoom(judgmentSectionTextScale)
						self:settext(thisRadar .. ":")
					end
				},
				LoadFont("Common Normal") .. {
					Name = "Counts_"..thisRadar,
					InitCommand = function(self)
						-- ... hehe
						self:y(lowerDivider1Y + dividerHeight/2 + frameHeight * radarTextSpacingFromDividerReferenceRatio + (frameHeight * (radarSectionReferenceRatio - radarTextSpacingFromDividerReferenceRatio - radarTextSpacingFromLowerDividerReferenceRatio)) / #radars * (i-1))
						self:zoom(judgmentSectionTextScale)
						self:settext("")
					end,
					BeginCommand = function(self)
						self:settextf("%d/%d", count, possible)
					end
				},
				LoadFont("Common Normal") .. {
					Name = "Percentage_"..thisRadar,
					InitCommand = function(self)
						self:halign(1)
						self:x(frameWidth/2 - edgeTextSpacing1)
						-- its not funny anymore
						self:y(lowerDivider1Y + dividerHeight/2 + frameHeight * radarTextSpacingFromDividerReferenceRatio + (frameHeight * (radarSectionReferenceRatio - radarTextSpacingFromDividerReferenceRatio - radarTextSpacingFromLowerDividerReferenceRatio)) / #radars * (i-1))
						self:zoom(judgmentSectionTextScale)
						self:settext("")
					end,
					BeginCommand = function(self)
						local percent = count/possible * 100
						if count == 0 then
							percent = 100
						end
						self:settextf("%5.2f%%", percent)
					end
				}
			}
		end
		local t = Def.ActorFrame {}
		for i = 1,#radars do
			t[#t+1] = oneText(i)
		end
		return t
	end

	t[#t+1] = Def.ActorFrame {
		Name = "The Board",
		InitCommand = function(self)
			self:xy(frameCenterX, frameCenterY)
		end,
		Def.ActorFrame {
			Name = "MainQuads",
			quadButton(5) .. {
				Name = "BoardBG",
				InitCommand = function(self)
					self:zoomto(frameWidth, frameHeight)
					self:diffuse(boardBGColor)
				end,
				MouseDownCommand = function(self)
					usingSimpleScreen = not usingSimpleScreen
					MESSAGEMAN:Broadcast("SwitchEvalTypes")
				end
			},
			Def.Quad {
				Name = "BoardHeader",
				InitCommand = function(self)
					self:y(frameHeaderY)
					self:zoomto(frameWidth, frameHeaderHeight)
					self:diffuse(headerColor)
				end
			}
		},

		Def.ActorFrame {
			Name = "Dividers",
			Def.Quad {
				Name = "UpperDivider1",
				InitCommand = function(self)
					self:y(upperDivider1Y)
					self:zoomto(frameWidth, dividerHeight)
					self:diffuse(dividerColor)
				end
			},
			Def.Quad {
				Name = "UpperDivider2",
				InitCommand = function(self)
					self:y(upperDivider2Y)
					self:zoomto(frameWidth, dividerHeight)
					self:diffuse(dividerColor)
				end
			},
			Def.Quad {
				Name = "LowerDivider1",
				InitCommand = function(self)
					self:y(lowerDivider1Y)
					self:zoomto(frameWidth, dividerHeight)
					self:diffuse(dividerColor)
				end
			},
			Def.Quad {
				Name = "LowerDivider2",
				InitCommand = function(self)
					self:y(lowerDivider2Y)
					self:zoomto(frameWidth, dividerHeight)
					self:diffuse(dividerColor)
				end
			}
		},

		Def.ActorFrame {
			Name = "Static Text",
			InitCommand = function(self)
				self:SetUpdateFunction(highlightSD)
			end,
			--[[ -- not using group name because we already have group name on this screen.
			LoadFont("Common Normal") .. {
				Name = "PackName",
				InitCommand = function(self)
					self:y(frameHeaderY)
					self:zoom(mainTextScale)
					self:settext(GAMESTATE:GetCurrentSong():GetGroupName())
					self:maxwidth(frameWidth / mainTextScale)
				end
			},]]
			LoadFont("Common Normal") .. {
				Name = "TitleAndRate",
				InitCommand = function(self)
					self:y(-frameHeight/2 + frameHeaderHeight + (frameHeight * titleSectionReferenceRatio / 4))
					self:zoom(mainTextScale)
					local title = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
					local rate = "("..rate..")"
					self:settextf("%s %s", title, rate)
					self:AddAttribute(#title + 1, {Length=-1, Diffuse = getMainColor("warning")})
					self:maxwidth(frameWidth / mainTextScale)
				end
			},
			LoadFont("Common Normal") .. {
				Name = "Artist",
				InitCommand = function(self)
					self:y(-frameHeight/2 + frameHeaderHeight + (frameHeight * titleSectionReferenceRatio / 4) * 3)
					self:zoom(mainTextScale)
					local artist = GAMESTATE:GetCurrentSong():GetDisplayArtist()
					self:settextf("By: %s", artist)
				end,
				BeginCommand = function(self)
					self:maxwidth((frameWidth - self:GetParent():GetChild("MSD"):GetZoomedWidth() * 2.5) / mainTextScale)
				end
			},
			LoadFont("Common Normal") .. {
				Name = "SSR",
				InitCommand = function(self)
					self:halign(0)
					self:xy(-frameWidth/2 + edgeTextSpacing2, upperDivider1Y + dividerHeight/2 + (frameHeight * gradeSectionReferenceRatio / 2))
					self:zoom(biggerTextScale)
					local score = pss:GetHighScore()
					local ssr = 0
					if score then
						ssr = score:GetSkillsetSSR("Overall")
					end
					self:settextf("%5.2f", ssr)
					self:diffuse(byMSD(ssr))

				end
			},
			LoadFont("Common Normal") .. {
				Name = "MSD",
				InitCommand = function(self)
					self:halign(0):valign(1)
					self:xy(-frameWidth/2 + edgeTextSpacing2, upperDivider1Y - dividerHeight/2 - 3)
					self:zoom(msdTextScale)
					local msd = GAMESTATE:GetCurrentSteps(PLAYER_1):GetMSD(getCurRateValue(), 1)
					self:settextf("%5.2f", msd)
					self:diffuse(byMSD(msd))
				end
			},
			LoadFont("Common Normal") .. {
				Name = "Difficulty",
				InitCommand = function(self)
					self:halign(0)
					self:xy(-frameWidth/2 + edgeTextSpacing2, upperDivider1Y + dividerHeight/2 + (frameHeight * gradeSectionReferenceRatio / 5 * 3.4))
					self:zoom(smallerTextScale)
					local diff = steps:GetDifficulty()
					local difftext
					if diff == 'Difficulty_Edit' and IsUsingWideScreen() then
						difftext = steps:GetDescription()
						difftext = difftext == '' and getShortDifficulty(diff) or difftext
					else
						difftext = getShortDifficulty(diff)
					end
					self:settext(difftext)
					self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
				end,
				BeginCommand = function(self)
					difficultySpacing = -frameWidth/2 + edgeTextSpacing2 + self:GetParent():GetChild("SSR"):GetZoomedWidth() + SCREEN_WIDTH * difficultySpacingReferenceRatio
					self:x(difficultySpacing)
				end
			},
			LoadFont("Common Normal") .. {
				Name = "PBIndicator",
				InitCommand = function(self)
					self:halign(0)
					self:xy(-frameWidth/2 + edgeTextSpacing2, upperDivider1Y + dividerHeight/2 + (frameHeight * gradeSectionReferenceRatio / 5 * 1.2))
					self:zoom(smallerTextScale)
					self:diffuse(getMainColor("warning"))
					if scoreIndex == 1 and #hsTable > 0 then
						self:settext("PB!")
					end
				end,
				BeginCommand = function(self)
					difficultySpacing = -frameWidth/2 + edgeTextSpacing2 + self:GetParent():GetChild("SSR"):GetZoomedWidth() + SCREEN_WIDTH * difficultySpacingReferenceRatio
					self:x(difficultySpacing)
				end
			},
			judgmentTexts(),
			radarTexts(),
			LoadFont("Common Normal") .. {
				Name = "Mean",
				InitCommand = function(self)
					self:halign(0)
					self:xy(-frameWidth/2 + edgeTextSpacing1, lowerDivider2Y + dividerHeight/2 + (frameHeight * meanTextSpacingFromDividerReferenceRatio))
					self:zoom(smallerTextScale)
					self:settext("")
					self:maxwidth((frameWidth/3-5) / smallerTextScale)
				end,
				BeginCommand = function(self)
					self:playcommand("Set")
				end,
				SetCommand = function(self)
					self:settextf("Mean: %5.2fms", statInfo["mean"])
				end,
				HighlightCommand = function(self)
					if isOver(self) then
						self:settextf("Std Dev: %5.2fms", statInfo["sd"])
					else
						self:playcommand("Set")
					end
				end,
			},
			LoadFont("Common Normal") .. {
				Name = "CBText",
				InitCommand = function(self)
					self:y(lowerDivider2Y + dividerHeight/2 + (frameHeight * meanTextSpacingFromDividerReferenceRatio * 2.5))
					self:zoom(msdTextScale)
					self:settext("CBs")
				end
			}
		},

		Def.ActorFrame {
			Name = "DynamicTexts",
			LoadFont("Common Normal") .. {
				Name = "WifePercent",
				InitCommand = function(self)
					self:y(upperDivider1Y + dividerHeight/2 + (frameHeight * gradeSectionReferenceRatio / 2))
					self:zoom(biggerTextScale)
					self:maxwidth(frameWidth / 4 / biggerTextScale)
					self:settext("")
				end,
				BeginCommand=function(self) 
					local wifeScore = pss:GetHighScore():GetWifeScore()
					if wifeScore > 0.99 then
						self:settextf("%.4f%%",math.floor((wifeScore)*1000000)/10000)
					else
						self:settextf("%.2f%%",math.floor((wifeScore)*10000)/100)
					end
				end,
				SetJudgeCommand = function(self, params)
					if enabledCustomWindows then
						if rescoredPercentage > 99 then
							self:settextf("%05.4f%% (%s)", rescoredPercentage, customWindow.name)
						else
							self:settextf("%05.2f%% (%s)", rescoredPercentage, customWindow.name)
						end
					else

						if rescoredPercentage > 99 then
							self:settextf("%05.4f%%", rescoredPercentage)
						else
							self:settextf("%05.2f%%", rescoredPercentage)
						end
					end
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("Begin")
				end
			},
			LoadFont("Common Normal")..{
				Name = "Grade",
				InitCommand = function(self)
					self:halign(1)
					self:xy(frameWidth/2 - edgeTextSpacing2, upperDivider1Y + dividerHeight/2 + (frameHeight * gradeSectionReferenceRatio / 2))
					self:zoom(biggerTextScale)
					self:settext("")
				end,
				BeginCommand=function(self)
					local grade = pss:GetHighScore():GetWifeGrade()
					self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
					self:diffuse(getGradeColor(grade))
				end,
				SetJudgeCommand = function(self)
					local grade = getWifeGradeTier(rescoredPercentage)
					self:settext(THEME:GetString("Grade", ToEnumShortString(grade)))
					self:diffuse(getGradeColor(grade))
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("Begin")
				end
			},
			judgmentCounts(),
			LoadFont("Common Normal") .. {
				Name = "Judge",
				InitCommand = function(self)
					self:halign(1)
					self:xy(frameWidth/2 - edgeTextSpacing1, lowerDivider2Y + dividerHeight/2 + (frameHeight * meanTextSpacingFromDividerReferenceRatio))
					self:zoom(smallerTextScale)
					self:maxwidth((frameWidth/3-5) / smallerTextScale)
					self:settext("")
				end,
				BeginCommand = function(self)
					self:playcommand("Set")
				end,
				SetCommand = function(self)
					self:settextf("Judge:  %s", judge)
				end,
				SetJudgeCommand = function(self)
					self:queuecommand("Set")
				end,
				ResetJudgeCommand = function(self)
					self:queuecommand("Set")
				end
			},
			LoadFont("Common Normal") .. {
				Name = "CBNumbers",
				InitCommand = function(self)
					self:y(lowerDivider2Y + dividerHeight/2 + (frameHeight * meanTextSpacingFromDividerReferenceRatio))
					self:zoom(smallerTextScale)
					self:maxwidth((frameWidth/3 - 5) / smallerTextScale)
					self:settext("")
				end,
				BeginCommand = function(self)
					self:playcommand("Set")
				end,
				SetCommand = function(self)
					if not showMiddle then
						self:settextf("%d | %d", cbl, cbr)
					else
						self:settextf("%d | %d | %d", cbl, cbm, cbr)
					end
				end,
				SetJudgeCommand = function(self)
					tso = tst[judge]
					if enabledCustomWindows then
						tso = 1
					end
					recountCBs()
					self:queuecommand("Set")
				end,
				ResetJudgeCommand = function(self)
					self:playcommand("SetJudge")
				end
			},
			
		}
	}

	t[#t+1] = Def.ActorFrame {
		Name = "PlayerInfo",
		InitCommand = function(self)
			self:xy(playerInfoRightX, playerInfoBottomY)
		end,
		Def.Quad {
			Name = "BG",
			InitCommand = function(self)
				self:halign(1)
				self:valign(1)
				self:zoomto(playerInfoFrameWidth, playerInfoFrameHeight)
				self:diffuse(boardBGColor)
			end
		},
		Def.Quad {
			Name = "AvatarBG",
			InitCommand = function(self)
				self:halign(0)
				self:valign(0)
				self:xy(-playerInfoFrameWidth + SCREEN_WIDTH * avatarLeftEdgeReferenceRatio,-playerInfoFrameHeight + SCREEN_HEIGHT * avatarTopEdgeReferenceRatio)
				self:zoomto(playerInfoAvatarWH, playerInfoAvatarWH)
				self:diffuse(dividerColor)
			end
		},
		Def.Sprite {
			Name = "AvatarImage",
			InitCommand = function(self)
				self:halign(0)
				self:valign(0)
				self:xy(-playerInfoFrameWidth + SCREEN_WIDTH * avatarLeftEdgeReferenceRatio + 2,-playerInfoFrameHeight + SCREEN_HEIGHT * avatarTopEdgeReferenceRatio + 2)
				self:Load(getAvatarPath(PLAYER_1))
				self:zoomto(playerInfoAvatarWH - 4,playerInfoAvatarWH - 4)
			end
		},
		LoadFont("Common Normal") .. {
			Name = "PlayerName", 
			InitCommand = function(self)
				self:halign(0)
				self:valign(1)
				self:xy(-SCREEN_WIDTH * playerNameWidthReferenceRatio, -playerInfoFrameHeight + SCREEN_HEIGHT * playerNameBottomReferenceRatio)
				local text = getCurrentUsername(pn)
				if text == "" then
					text = "Player 1"
				end
				self:settext(text)
				self:zoom(judgmentSectionTextScale)
				self:maxwidth(SCREEN_WIDTH * playerNameWidthReferenceRatio / judgmentSectionTextScale)
			end
		},
		LoadFont("Common Normal") .. {
			Name = "PlayerRating",
			InitCommand = function(self)
				self:halign(0)
				self:valign(0)
				self:xy(-SCREEN_WIDTH * playerNameWidthReferenceRatio, -playerInfoFrameHeight + SCREEN_HEIGHT * playerRatingTopReferenceRatio)
				self:zoom(judgmentSectionTextScale)
				local rating
				if DLMAN:IsLoggedIn() then
					rating = DLMAN:GetSkillsetRating("Overall")
				else
					rating = profile:GetPlayerRating()
				end
				self:diffuse(byMSD(rating))
				self:settextf("%5.2f", rating)
				self:maxwidth(SCREEN_WIDTH * playerNameWidthReferenceRatio / judgmentSectionTextScale)
			end
		},
		LoadFont("Common Normal") .. {
			Name = "DateTime",
			InitCommand = function(self)
				self:valign(0)
				self:xy(-playerInfoFrameWidth/2, -playerInfoFrameHeight + SCREEN_HEIGHT * playerInfoDateTopReferenceRatio)
				self:zoom(smallerTextScale)
				self:settext(pss:GetHighScore():GetDate())
				self:maxwidth((playerInfoFrameWidth - 6) / smallerTextScale)
			end
		},
		LoadFont("Common Normal") .. {
			Name = "Mods",
			InitCommand = function(self)
				self:valign(0)
				self:xy(-playerInfoFrameWidth/2, -playerInfoFrameHeight + SCREEN_HEIGHT * playerInfoModsTopReferenceRatio)
				self:zoom(smallerTextScale)
				local mods = pss:GetHighScore():GetModifiers()
				--GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():GetInvalidatingMods()
				self:settext(mods)
				self:maxwidth((playerInfoFrameWidth - 6) / smallerTextScale)
			end
		}
	}

	if showScoreboardOnSimple then
		if not inMulti then
			t[#t+1] = LoadActor("scoreboard")
		else
			t[#t+1] = LoadActor("MPscoreboard")
		end
	end

	return t
end

t[#t+1] = oldEvalStuff()
t[#t+1] = newEvalStuff()
t[#t+1] = offsetStuff()

-- for scrolling input. i know, its dumb
-- but i decided to make this so carefully disorganized that it had to be done
-- this single scroll input handler works for 3 different scoreboards
-- so if it dies, you cant scroll on any of them
-- they should only be loaded on this screen anyways
-- dont mess it up (the keyboard hotkeys will work anyways though)
t[#t+1] = Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(scroller)
		if PREFSMAN:GetPreference("SortBySSRNormPercent") then
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
			local curScore = pss:GetHighScore()
			judge = 4
			
			rescoredPercentage = curScore:GetWifeScore() * 100
			MESSAGEMAN:Broadcast("ForceUpdateAllInfo")
		end
	end
}



return t