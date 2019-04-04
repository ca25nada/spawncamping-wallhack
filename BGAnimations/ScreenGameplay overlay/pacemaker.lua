--IIDX-esque scoregraph.
--Supports arbituary bar dimensions,number of bars so far. (although none of them are in preferences atm.)
--Support for arbituary display range to be added eventually.

local ghostType
local target

local frameWidth = 105
local frameHeight = SCREEN_HEIGHT

local frameX = SCREEN_WIDTH-frameWidth
local frameY = 0

local barY = 430-- Starting point/bottom of graph
local barCount = 3 -- Number of graphs
local barWidth = 0.65
local barTrim = 0 -- Final width of each graph = ((frameWidth/barCount)*barWidth) - barTrim
local barHeight = 350 -- Max Height of graphs

local textSpacing = 10
local bottomTextY = barY+frameY+10
local topTextY = frameY+barY-barHeight-10-(textSpacing*barCount)

local enabled = GAMESTATE:GetNumPlayersEnabled() == 1 

local player = GAMESTATE:GetEnabledPlayers()[1]
if player == PLAYER_1 then
	ghostType = playerConfig:get_data(pn_to_profile_slot(player)).GhostScoreType -- 0 = off,1 = DP,2 = PS,3 = MIGS
	target = playerConfig:get_data(pn_to_profile_slot(player)).GhostTarget/100 -- target score from 0% to 100%.
	enabled =  enabled and playerConfig:get_data(pn_to_profile_slot(player)).PaceMaker
end

local profile = GetPlayerOrMachineProfile(player)
local origTable
local rtTable
local hsTable

if themeConfig:get_data().global.RateSort then
	origTable = getScoreList(player)
	rtTable = getRateTable(origTable)
	hsTable = sortScore(rtTable[getCurRate()] or {},ghostType)
else
	origTable = getScoreList(player)
	hsTable = sortScore(origTable,ghostType)
end


--if ghost score is off,inherit from default scoring type.
if ghostType == nil or ghostType == 0 then
	ghostType = themeConfig:get_data().global.DefaultScoreType
end

--Strings and the percent value for the goal/grade
local markerPoints = { --DP/PS/MIGS in that order.
	[1] = {Grade_Tier02 = THEME:GetMetric("PlayerStageStats","GradePercentTier02"),
			Grade_Tier03 = THEME:GetMetric("PlayerStageStats","GradePercentTier03"),
			Grade_Tier04 = THEME:GetMetric("PlayerStageStats","GradePercentTier04"),
			Grade_Tier05 = THEME:GetMetric("PlayerStageStats","GradePercentTier05"),
			Grade_Tier06 = THEME:GetMetric("PlayerStageStats","GradePercentTier06"),
			Grade_Tier07 = 0 },

	[2] = {["100%"]=1,["90%"]=0.9,["80%"]=0.8,["70%"]=0.7,["60%"]=0.6,["50%"]=0.5,[""]=0},
	[3] = {["100%"]=1,["90%"]=0.9,["80%"]=0.8,["70%"]=0.7,["60%"]=0.6,["50%"]=0.5,[""]=0},
}



local function ghostScoreGraph(index,scoreType,color)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX) end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY)
			self:zoomto(frameWidth/barCount*barWidth,1)
			self:valign(1)
			self:diffuse(color):diffusealpha(0.7)
		end,
		SetCommand = function(self)
			local curScore = getCurScoreGD(player,scoreType)
			local maxScore = getMaxScoreST(player,scoreType)
			if maxScore <= 0 then
				self:zoomy(1)
			else
				self:zoomy(math.max(1,barHeight*(curScore/maxScore)))
			end
		end,
		GhostScoreMessageCommand = function(self) self:queuecommand("Set") end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2,bottomTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(frameWidth/0.35)
			self:diffuse(color)
			self:settext(THEME:GetString("ScreenGameplay","PacemakerBest"))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(2,topTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(((frameWidth*0.8)-2)/0.35)
			self:halign(0)
			self:diffuse(color)
		end,
		BeginCommand = function(self)
			if getCurRate() == "1.0x" or not themeConfig:get_data().global.RateSort then
				self:settextf("%s Best",getScoreTypeText(ghostType))
			else
				self:settextf("%s Best (%s)",getScoreTypeText(ghostType),getCurRate())
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-2,topTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(25/0.35)
			self:halign(1)
			self:settext(0)
		end,
		SetCommand = function(self)
			local score
			if isGhostDataValid(player,hsTable[1]) then
				score = getCurScoreGD(player,scoreType)
			else
				score = getBestScore(player,0,scoreType)
			end
			self:settext(score)
		end,
		GhostScoreMessageCommand = function(self) self:queuecommand("Set") end
	}

	return t

end

-- Represents the current score/possible score for the specified scoreType
local function currentScoreGraph(index,scoreType,color)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX) end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY)
			self:zoomto(frameWidth/barCount*barWidth,1)
			self:valign(1)
			self:diffuse(color):diffusealpha(0.7)
		end,
		SetCommand = function(self)
			local curScore = getCurScoreST(player,scoreType)
			local maxScore = getMaxScoreST(player,scoreType)
			if maxScore <= 0 then
				self:zoomy(1)
			else
				self:zoomy(math.max(1,barHeight*(curScore/maxScore)))
			end
		end,
		JudgmentMessageCommand = function(self) self:queuecommand("Set") end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2,bottomTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(frameWidth/0.35)
			self:diffuse(color)
			self:settext(THEME:GetString("ScreenGameplay","PacemakerCurrent"))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(2,topTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(((frameWidth*0.8)-2)/0.35)
			self:halign(0)
			self:diffuse(color)
		end,
		BeginCommand = function(self)
			local text = profile:GetDisplayName()
			if text == "" then
				self:settext("Machine Profile")
			else
				self:settext(text)
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-2,topTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(25/0.35)
			self:halign(1)
			self:settext(0)
		end,
		SetCommand = function(self)
			local curScore = getCurScoreST(player,scoreType)
			self:settext(curScore)
		end,
		JudgmentMessageCommand = function(self) self:queuecommand("Set") end
	}

	return t

end


-- The current average score of the player.
local function avgScoreGraph(index,scoreType,color)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX) end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY)
			self:zoomto(frameWidth/barCount*barWidth,1)
			self:valign(1)
			self:diffuse(color):diffusealpha(0.2)
		end,
		SetCommand = function(self)
			local curScore = getCurScoreST(player,scoreType)
			local curMaxScore = getCurMaxScoreST(player,scoreType)
			if curMaxScore <= 0 then
				self:zoomy(1)
			else
				self:zoomy(math.max(1,barHeight*(curScore/curMaxScore)))
			end
		end,
		JudgmentMessageCommand = function(self) self:queuecommand("Set") end
	}

	return t

end


-- Represents the best score achieved for the specified scoreType
local function bestScoreGraph(index,scoreType,color)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX) end
	}


	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY)
			self:zoomto(frameWidth/barCount*barWidth,1)
			self:valign(1)
			self:diffuse(color):diffusealpha(0.2)
		end,
		BeginCommand = function(self)
			local bestScore = 0
			if themeConfig:get_data().global.RateSort then
				bestScore = getScore(hsTable[1],scoreType)
			else
				bestScore = getBestScore(player,0,scoreType)
			end
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:zoomy(math.max(1,barHeight*(bestScore/maxScore)))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY-12)
			self:zoom(0.35):maxwidth(frameWidth/barCount*barWidth/0.35)
			self:diffusealpha(0)
		end,
		BeginCommand = function(self)
			local bestScore = 0
			if themeConfig:get_data().global.RateSort then
				bestScore = getScore(hsTable[1],scoreType)
			else
				bestScore = getBestScore(player,0,scoreType)
			end
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			self:settext("Best\n"..bestScore)
			self:diffusealpha(1)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:y(frameY+barY-math.max(12,(barHeight*(bestScore/maxScore))))
			end
			self:sleep(0.5)
			self:smooth(0.5)
			self:diffusealpha(0)
		end
	}

	return t

end


-- Represents the current target score for the specified scoreType
local function targetScoreGraph(index,scoreType,color)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX) end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY)
			self:zoomto(frameWidth/barCount*barWidth,1)
			self:valign(1)
			self:diffuse(color):diffusealpha(0.7)
		end,
		SetCommand = function(self)
			local curScore = math.ceil(getCurMaxScoreST(player,scoreType)*target)
			local maxScore = getMaxScoreST(player,scoreType)
			if maxScore <= 0 then
				self:zoomy(1)
			else
				self:zoomy(math.max(1,barHeight*(curScore/maxScore)))
			end
		end,
		JudgmentMessageCommand = function(self) self:queuecommand("Set") end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2,bottomTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(frameWidth/0.35)
			self:diffuse(color)
			self:settext(THEME:GetString("ScreenGameplay","PacemakerTarget"))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(2,topTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(((frameWidth*0.8)-2)/0.35)
			self:halign(0)
			self:diffuse(color)
			self:settextf("%s %0.2f%%",getScoreTypeText(ghostType),target*100)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-2,topTextY+textSpacing*(index-1))
			self:zoom(0.35):maxwidth(25/0.35)
			self:halign(1)
			self:settext(0)
		end,
		SetCommand = function(self)
			local curScore = math.ceil(getCurMaxScoreST(player,scoreType)*target)
			self:settext(curScore)
		end,
		JudgmentMessageCommand = function(self) self:queuecommand("Set") end
	}

	return t
end


-- Represents the total target score for the specified scoreType
local function targetMaxGraph(index,scoreType,color)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX) end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY)
			self:zoomto(frameWidth/barCount*barWidth,1)
			self:valign(1)
			self:diffuse(color):diffusealpha(0.2)
		end,
		BeginCommand = function(self)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:zoomy(math.max(1,barHeight*(math.ceil(maxScore*target)/maxScore)))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{	
		InitCommand = function(self)
			self:xy((1+(2*(index-1)))*(frameWidth/(barCount*2)),frameY+barY-12)
			self:zoom(0.35):maxwidth(frameWidth/barCount*barWidth/0.35)
			self:diffusealpha(0)
		end,
		BeginCommand = function(self)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			self:settext("Target\n"..math.ceil(maxScore*target))
			self:diffusealpha(1)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:y(frameY+barY-math.max(12,(barHeight*(math.ceil(maxScore*target)/maxScore))))
			end
			self:sleep(0.5)
			self:smooth(0.5)
			self:diffusealpha(0)
		end
	}

	return t

end


--The Background markers with the lines corresponding to the minimum required for the grade,etc.
local function markers(scoreType,showMessage)

	local t = Def.ActorFrame{
		InitCommand = function(self) self:xy(frameX,frameY):diffusealpha(0.4) end
	}

	for k,v in pairs(markerPoints[scoreType]) do

		t[#t+1] = Def.Quad{
			InitCommand = function(self)
				self:y(barY-(barHeight*v))
				self:zoomto(frameWidth,2)
				self:halign(0)
			end,
			JudgmentMessageCommand = function(self)
				local percent = getCurScoreST(player,scoreType)/getMaxScoreST(player,scoreType)
				if percent >= v then
					self:diffuse(getMainColor('highlight'))
				end
			end
		}

		-- Do not show the letter if the grade req is 0%
		if v ~= 0 then
			t[#t+1] = LoadFont("Common Normal")..{
				InitCommand = function(self)
					self:y(barY-(barHeight*v)-2)
					self:zoom(0.3)
					self:halign(0):valign(1)
					self:settext(getGradeStrings(k))
				end,
				JudgmentMessageCommand = function(self)
					local percent = getCurScoreST(player,scoreType)/getMaxScoreST(player,scoreType)
					if percent >= v then
						if scoreType == 1 then 
							self:diffuse(getGradeColor(k))
						else
							self:diffuse(getMainColor('highlight'))
						end
					end
				end
			}

		end
	end

	return t

end


-- Text showing life/judge setting
local function lifejudge()

	local t = Def.ActorFrame{
		InitCommand = function(self) self:x(frameX):diffusealpha(0.4) end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(2,15)
			self:zoom(0.4)
			self:halign(0):valign(1)
		end,
		BeginCommand = function(self)
			self:settext(THEME:GetString("ScreenGameplay","PacemakerTimingDifficulty")..":")
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(2,28)
			self:zoom(0.4)
			self:halign(0):valign(1)
		end,
		BeginCommand = function(self)
			self:settext(THEME:GetString("ScreenGameplay","PacemakerLifeDifficulty")..":")
		end
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-5,15)
			self:zoom(0.4)
			self:halign(1):valign(1)
		end,
		BeginCommand = function(self)
			self:settext(GetTimingDifficulty())
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-5,28)
			self:zoom(0.4)
			self:halign(1):valign(1)
		end,
		BeginCommand = function(self)
			self:settext(GetLifeDifficulty())
		end
	}

	return t

end

--Make the graph...!
local t = Def.ActorFrame{}
if enabled then

	-- Background quad
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(frameX,frameY)
			self:zoomto(frameWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame")):diffusealpha(0.6)
		end
	}
	
	t[#t+1] = avgScoreGraph(1,ghostType,getPaceMakerColor("Current"))
	t[#t+1] = currentScoreGraph(1,ghostType,getPaceMakerColor("Current"))

	t[#t+1] = ghostScoreGraph(2,ghostType,getPaceMakerColor("Best"))
	t[#t+1] = bestScoreGraph(2,ghostType,getPaceMakerColor("Best"))

	t[#t+1] = targetMaxGraph(math.min(barCount,3),ghostType,getPaceMakerColor("Target"))
	t[#t+1] = targetScoreGraph(math.min(barCount,3),ghostType,getPaceMakerColor("Target"))

	t[#t+1] = markers(ghostType,true)
	t[#t+1] = lifejudge()

end


return t