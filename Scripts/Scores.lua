

-- Change this to change the scoretype the theme returns 
--(should be made into a preference eventually)
local defaultScoreType =getTempThemePref("DefaultScoreType") --1DP 2PS 3MIGS

local scoreTypeText = {
	[1] = "DP",
	[2] = "PS",
	[3] = "MIGS"
}

local gradeTiers = {
	Grade_Tier01 = 0,
	Grade_Tier02 = 1,
	Grade_Tier03 = 2,
	Grade_Tier04 = 3,
	Grade_Tier05 = 4,
	Grade_Tier06 = 5,
	Grade_Tier07 = 6,
	Grade_Tier08 = 7,
	Grade_Tier09 = 8,
	Grade_Tier10 = 9,
	Grade_Tier11 = 10,
	Grade_Tier12 = 11,
	Grade_Tier13 = 12,
	Grade_Tier14 = 13,
	Grade_Tier15 = 14,
	Grade_Tier16 = 15,
	Grade_Tier17 = 16,
	Grade_Tier18 = 17,
	Grade_Tier19 = 18,
	Grade_Tier20 = 19,
	Grade_Failed = 20
}

local scoreWeight =  { -- Score Weights for DP score (MAX2)
	TapNoteScore_W1				= 2,--PREFSMAN:GetPreference("GradeWeightW1"),					--  2
	TapNoteScore_W2				= 2,--PREFSMAN:GetPreference("GradeWeightW2"),					--  2
	TapNoteScore_W3				= 1,--PREFSMAN:GetPreference("GradeWeightW3"),					--  1
	TapNoteScore_W4				= 0,--PREFSMAN:GetPreference("GradeWeightW4"),					--  0
	TapNoteScore_W5				= -4,--PREFSMAN:GetPreference("GradeWeightW5"),					-- -4
	TapNoteScore_Miss			= -8,--PREFSMAN:GetPreference("GradeWeightMiss"),				-- -8
	HoldNoteScore_Held			= 6,--PREFSMAN:GetPreference("GradeWeightHeld"),				--  6
	TapNoteScore_HitMine		= -8,--PREFSMAN:GetPreference("GradeWeightHitMine"),				-- -8
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("GradeWeightLetGo"),				--  0
	HoldNoteScore_MissedHold	 = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit	= 0,--PREFSMAN:GetPreference("GradeWeightCheckpointHit"),		--  0
	TapNoteScore_CheckpointMiss = 0--PREFSMAN:GetPreference("GradeWeightCheckpointMiss"),		--  0
}

local psWeight =  { -- Score Weights for percentage scores (EX oni)
	TapNoteScore_W1			= 3,--PREFSMAN:GetPreference("PercentScoreWeightW1"),
	TapNoteScore_W2			= 2,--PREFSMAN:GetPreference("PercentScoreWeightW2"),
	TapNoteScore_W3			= 1,--PREFSMAN:GetPreference("PercentScoreWeightW3"),
	TapNoteScore_W4			= 0,--PREFSMAN:GetPreference("PercentScoreWeightW4"),
	TapNoteScore_W5			= 0,--PREFSMAN:GetPreference("PercentScoreWeightW5"),
	TapNoteScore_Miss			= 0,--PREFSMAN:GetPreference("PercentScoreWeightMiss"),
	HoldNoteScore_Held			= 3,--PREFSMAN:GetPreference("PercentScoreWeightHeld"),
	TapNoteScore_HitMine			= -2,--(0 or -2?) PREFSMAN:GetPreference("PercentScoreWeightHitMine"),
	HoldNoteScore_LetGo			= 0,--PREFSMAN:GetPreference("PercentScoreWeightLetGo"),
	HoldNoteScore_MissedHold	 = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointHit"),
	TapNoteScore_CheckpointMiss 	= 0--PREFSMAN:GetPreference("PercentScoreWeightCheckpointMiss"),
}

local migsWeight =  { -- Score Weights for MIGS score
	TapNoteScore_W1			= 3,
	TapNoteScore_W2			= 2,
	TapNoteScore_W3			= 1,
	TapNoteScore_W4			= 0,
	TapNoteScore_W5			= -4,
	TapNoteScore_Miss			= -8,
	HoldNoteScore_Held			= 6,
	TapNoteScore_HitMine			= -8,
	HoldNoteScore_LetGo			= 0,
	HoldNoteScore_MissedHold	 = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0
}

local judgeStatsP1 = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	HoldNoteScore_Held = 0,
	TapNoteScore_HitMine = 0,
	HoldNoteScore_LetGo = 0,
	HoldNoteScore_MissedHold = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
}

local judgeStatsP2 = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	HoldNoteScore_Held = 0,
	TapNoteScore_HitMine = 0,
	HoldNoteScore_LetGo = 0,
	HoldNoteScore_MissedHold = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
}

local song
local profileP1
local stepsP1
local profileP1
local hsTableP1
local indexScoreP1

local profileP2
local stepsP2
local profileP2
local hsTableP2
local indexScoreP2

--============================================================
-- These should run without any dependencies
--============================================================

function getScoreTypeText(scoreType)
	if scoreType == 0 then
		return scoreTypeText[defaultScoreType]
	else
		return scoreTypeText[scoreType]
	end;
end;

local function resetScoreListP1()
	song = nil
	profileP1 = nil
	stepsP1 = nil
	profileP1 = nil
	hsTableP1 = {}
	indexScoreP1 = nil
	for k,_ in pairs(judgeStatsP1) do
		judgeStatsP1[k] = 0
	end
end;

local function resetScoreListP2()
	song = nil
	profileP2 = nil
	stepsP2 = nil
	profileP2 = nil
	hsTableP2 = {}
	indexScoreP2 = nil
	for k,_ in pairs(judgeStatsP2) do
		judgeStatsP2[k] = 0
	end
end;

function initScoreList(pn)
	if pn == PLAYER_1 then
		resetScoreListP1()
	end;
	if pn == PLAYER_2 then
		resetScoreListP2()
	end;
	song = GAMESTATE:GetCurrentSong()
	if GAMESTATE:IsPlayerEnabled(pn) then
		if pn == PLAYER_1 then
			profileP1 = GetPlayerOrMachineProfile(pn)
			stepsP1 = GAMESTATE:GetCurrentSteps(pn)
			if profileP1 ~= nil and stepsP1 ~= nil and song ~= nil then
				hsTableP1 = profileP1:GetHighScoreList(song,stepsP1):GetHighScores()
			end;
		end;
		if pn == PLAYER_2 then
			profileP2 = GetPlayerOrMachineProfile(pn)
			stepsP2 = GAMESTATE:GetCurrentSteps(pn)
			if profileP2 ~= nil and stepsP2 ~= nil and song ~= nil then
				hsTableP2 = profileP2:GetHighScoreList(song,stepsP2):GetHighScores()
			end;
		end;
	end;
end;

--============================================================
-- Call only after calling initScoreList
--============================================================

function initScore(pn,index)
	if pn == PLAYER_1 then
		if hsTableP1 ~= nil and #hsTableP1 >= 1 and index <= #hsTableP1 then
			indexScoreP1 = hsTableP1[index]
		end;
	end;
	if pn == PLAYER_2 then
		if hsTableP2 ~= nil and #hsTableP2 >= 1 and index <= #hsTableP2 then
			indexScoreP2 = hsTableP2[index]
		end;
	end;
end;

function getMaxNotes(pn)
	if pn == PLAYER_1 then
		if stepsP1 ~= nil then
			return stepsP1:GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds")-- Radarvalue, maximum number of notes
	 	else
	 		return 0
	 	end;
	 end;
	 if pn == PLAYER_2 then
		if stepsP2 ~= nil then
			return stepsP2:GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds")-- Radarvalue, maximum number of notes
	 	else
	 		return 0
	 	end;
	 end;
end;

function getMaxHolds(pn)
	if pn == PLAYER_1 then
		if stepsP1 ~= nil then
			return (stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds") + stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls")) or 0 -- Radarvalue, maximum number of holds
		else
	 		return 0
	 	end;
	 end;
	 if pn == PLAYER_2 then
		if stepsP2 ~= nil then
			return (stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Holds") + stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Rolls")) or 0 -- Radarvalue, maximum number of holds
		else
	 		return 0
	 	end;
	 end;
end;

function getMaxScore(pn,scoreType) -- dp, ps, migs = 1,2,3 respectively, 0 reverts to default
	local maxNotes = getMaxNotes(pn)
	local maxHolds = getMaxHolds(pn)
	if scoreType == 0 or scoreType == nil then
		scoreType = defaultScoreType
	end;

	if scoreType == 1 then
		return (maxNotes*scoreWeight["TapNoteScore_W1"]+maxHolds*scoreWeight["HoldNoteScore_Held"])-- maximum DP
	elseif scoreType == 2 then
		return (maxNotes*psWeight["TapNoteScore_W1"]+maxHolds*psWeight["HoldNoteScore_Held"]) -- maximum %score DP
	elseif scoreType == 3 then
		return (maxNotes*migsWeight["TapNoteScore_W1"]+maxHolds*migsWeight["HoldNoteScore_Held"])
	else
		return "????"
	end
end;


--============================================================
-- Functions for Highest/Lowest values in a scoretable. 
--Call only after calling initScoreList
--============================================================


function getHighestGrade(pn)
	local highest = 21
	local indexScore
	local grade = "Grade_None"
	local temp = 0
	local i = 0
	if pn == PLAYER_1 then
		if hsTableP1 ~= nil and #hsTableP1 >= 1 then
			while i <= #hsTableP1 do
				indexScore = hsTableP1[i]
				if indexScore ~= nil then
					temp = gradeTiers[indexScore:GetGrade()] or 21
					if temp <= highest then
						grade = indexScore:GetGrade()
						highest = temp
					end;
				end;
				i = i+1
			end;
		end;
	end;

	if pn == PLAYER_2 then
		if hsTableP2 ~= nil and #hsTableP2 >= 1 then
			while i <= #hsTableP2 do
				indexScore = hsTableP2[i]
				if indexScore ~= nil then
					temp = gradeTiers[indexScore:GetGrade()] or 21
					if temp <= highest then
						grade = indexScore:GetGrade()
						highest = temp
					end;
				end;
				i = i+1
			end;
		end;
	end;

	return grade
end;

function getHighestMaxCombo(pn)
	local highest = 0
	local indexScore
	local i = 0
	if pn == PLAYER_1 then
		if hsTableP1 ~= nil and #hsTableP1 >= 1 then
			while i <= #hsTableP1 do
				indexScore = hsTableP1[i]
				if indexScore ~= nil then
					temp = indexScore:GetMaxCombo()
					highest = math.max(temp,highest)
				end;
				i = i+1
			end;
		end;
	end;

	if pn == PLAYER_2 then
		if hsTableP2 ~= nil and #hsTableP2 >= 1 then
			while i <= #hsTableP2 do
				indexScore = hsTableP2[i]
				if indexScore ~= nil then
					temp = indexScore:GetMaxCombo()
					highest = math.max(temp,highest)
				end;
				i = i+1
			end;
		end;
	end;

	return highest
end;

function getLowestMissCount(pn)
	local lowest = math.huge
	local temp
	local indexScore
	local i = 0

	if pn == PLAYER_1 then
		if hsTableP1 ~= nil and #hsTableP1 >= 1 then
			while i <= #hsTableP1 do
				indexScore = hsTableP1[i]
				if indexScore ~= nil then
					if indexScore:GetGrade() ~= "Grade_Failed" then
						temp = indexScore:GetTapNoteScore("TapNoteScore_W4") + indexScore:GetTapNoteScore("TapNoteScore_W5") + indexScore:GetTapNoteScore("TapNoteScore_Miss")
						lowest = math.min(lowest,temp)
					end;
				end;
				i = i+1
			end;
		end;
	end;

	if pn == PLAYER_2 then
		if hsTableP2 ~= nil and #hsTableP2 >= 1 then
			while i <= #hsTableP2 do
				indexScore = hsTableP2[i]
				if indexScore ~= nil then
					if indexScore:GetGrade() ~= "Grade_Failed" then
						temp = indexScore:GetTapNoteScore("TapNoteScore_W4") + indexScore:GetTapNoteScore("TapNoteScore_W5") + indexScore:GetTapNoteScore("TapNoteScore_Miss")
						lowest = math.min(lowest,temp)
					end;
				end;
				i = i+1
			end;
		end;
	end;
	if lowest == math.huge then
		lowest = "-"
	end;
	return lowest 
end;

function getHighestScore(pn,scoreType)
	local lowest = 0
	if scoreType == 0 or scoreType == nil then
		scoreType = defaultScoreType
	end
	local table
	local indexScore

	if pn == PLAYER_1 then
		table = hsTableP1
	elseif pn == PLAYER_2 then
		table = hsTableP2
	end

	if table ~= nil then
		for k,v in pairs(table) do
			indexScore = table[k]
			if indexScore ~= nil then
				if scoreType == 1 then
					lowest = math.max(lowest,
					indexScore:GetTapNoteScore("TapNoteScore_W1")*scoreWeight["TapNoteScore_W1"]+
					indexScore:GetTapNoteScore("TapNoteScore_W2")*scoreWeight["TapNoteScore_W2"]+
					indexScore:GetTapNoteScore("TapNoteScore_W3")*scoreWeight["TapNoteScore_W3"]+
					indexScore:GetTapNoteScore("TapNoteScore_W4")*scoreWeight["TapNoteScore_W4"]+
					indexScore:GetTapNoteScore("TapNoteScore_W5")*scoreWeight["TapNoteScore_W5"]+
					indexScore:GetTapNoteScore("TapNoteScore_Miss")*scoreWeight["TapNoteScore_Miss"]+
					indexScore:GetTapNoteScore("TapNoteScore_CheckpointHit")*scoreWeight["TapNoteScore_CheckpointHit"]+
					indexScore:GetTapNoteScore("TapNoteScore_CheckpointMiss")*scoreWeight["TapNoteScore_CheckpointMiss"]+
					indexScore:GetTapNoteScore("TapNoteScore_HitMine")*scoreWeight["TapNoteScore_HitMine"]+
					indexScore:GetTapNoteScore("TapNoteScore_AvoidMine")*scoreWeight["TapNoteScore_AvoidMine"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_LetGo")*scoreWeight["HoldNoteScore_LetGo"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_Held")*scoreWeight["HoldNoteScore_Held"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_MissedHold")*scoreWeight["HoldNoteScore_MissedHold"]
					)
				elseif scoreType == 2 then
					lowest = math.max(lowest,
					indexScore:GetTapNoteScore("TapNoteScore_W1")*psWeight["TapNoteScore_W1"]+
					indexScore:GetTapNoteScore("TapNoteScore_W2")*psWeight["TapNoteScore_W2"]+
					indexScore:GetTapNoteScore("TapNoteScore_W3")*psWeight["TapNoteScore_W3"]+
					indexScore:GetTapNoteScore("TapNoteScore_W4")*psWeight["TapNoteScore_W4"]+
					indexScore:GetTapNoteScore("TapNoteScore_W5")*psWeight["TapNoteScore_W5"]+
					indexScore:GetTapNoteScore("TapNoteScore_Miss")*psWeight["TapNoteScore_Miss"]+
					indexScore:GetTapNoteScore("TapNoteScore_CheckpointHit")*psWeight["TapNoteScore_CheckpointHit"]+
					indexScore:GetTapNoteScore("TapNoteScore_CheckpointMiss")*psWeight["TapNoteScore_CheckpointMiss"]+
					indexScore:GetTapNoteScore("TapNoteScore_HitMine")*psWeight["TapNoteScore_HitMine"]+
					indexScore:GetTapNoteScore("TapNoteScore_AvoidMine")*psWeight["TapNoteScore_AvoidMine"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_LetGo")*psWeight["HoldNoteScore_LetGo"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_Held")*psWeight["HoldNoteScore_Held"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_MissedHold")*psWeight["HoldNoteScore_MissedHold"]
					)
				elseif scoreType == 3 then
					lowest = math.max(lowest,
					indexScore:GetTapNoteScore("TapNoteScore_W1")*migsWeight["TapNoteScore_W1"]+
					indexScore:GetTapNoteScore("TapNoteScore_W2")*migsWeight["TapNoteScore_W2"]+
					indexScore:GetTapNoteScore("TapNoteScore_W3")*migsWeight["TapNoteScore_W3"]+
					indexScore:GetTapNoteScore("TapNoteScore_W4")*migsWeight["TapNoteScore_W4"]+
					indexScore:GetTapNoteScore("TapNoteScore_W5")*migsWeight["TapNoteScore_W5"]+
					indexScore:GetTapNoteScore("TapNoteScore_Miss")*migsWeight["TapNoteScore_Miss"]+
					indexScore:GetTapNoteScore("TapNoteScore_CheckpointHit")*migsWeight["TapNoteScore_CheckpointHit"]+
					indexScore:GetTapNoteScore("TapNoteScore_CheckpointMiss")*migsWeight["TapNoteScore_CheckpointMiss"]+
					indexScore:GetTapNoteScore("TapNoteScore_HitMine")*migsWeight["TapNoteScore_HitMine"]+
					indexScore:GetTapNoteScore("TapNoteScore_AvoidMine")*migsWeight["TapNoteScore_AvoidMine"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_LetGo")*migsWeight["HoldNoteScore_LetGo"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_Held")*migsWeight["HoldNoteScore_Held"]+
					indexScore:GetHoldNoteScore("HoldNoteScore_MissedHold")*migsWeight["HoldNoteScore_MissedHold"]
					)
				end;
			end;
		end
	end

	return lowest
end;

--============================================================
-- Call only after calling initScoreListP1 and initScoreP1
--============================================================

function initJudgeStats(pn)
	if pn == PLAYER_1 then
		if indexScoreP1 ~= nil then
			for k,_ in pairs(judgeStatsP1) do
				if k == "HoldNoteScore_LetGo" or k == "HoldNoteScore_Held" or k == "HoldNoteScore_MissedHold" then
					judgeStatsP1[k] = indexScoreP1:GetHoldNoteScore(k)
				else 
					judgeStatsP1[k] = indexScoreP1:GetTapNoteScore(k)
				end;
			end
		end
	end
	if pn == PLAYER_2 then
		if indexScoreP2 ~= nil then
			for k,_ in pairs(judgeStatsP2) do
				if k == "HoldNoteScore_LetGo" or k == "HoldNoteScore_Held"or k == "HoldNoteScore_MissedHold" then
					judgeStatsP2[k] = indexScoreP2:GetHoldNoteScore(k)
				else 
					judgeStatsP2[k] = indexScoreP2:GetTapNoteScore(k)
				end;
			end
		end
	end
end;	


function getScoreGrade(pn)
	if pn == PLAYER_1 then
		if indexScoreP1 ~= nil then
			return indexScoreP1:GetGrade()
		else
			return "Grade_None"
		end;
	end;
	if pn == PLAYER_2 then
		if indexScoreP2 ~= nil then
			return indexScoreP2:GetGrade()
		else
			return "Grade_None"
		end;
	end;
end;


function getMaxCombo(pn)
	if pn == PLAYER_1 then
		if indexScoreP1 ~= nil then
			return indexScoreP1:GetMaxCombo()
		else
			return 0
		end;
	end;
	if pn == PLAYER_2 then
		if indexScoreP2 ~= nil then
			return indexScoreP2:GetMaxCombo()
		else
			return 0
		end;
	end;
end;


function getScoreDate(pn)
	if pn == PLAYER_1 then
		if indexScoreP1 ~= nil then
			return indexScoreP1:GetDate()
		else
			return ""
		end;
	end;
	if pn == PLAYER_2 then
		if indexScoreP2 ~= nil then
			return indexScoreP2:GetDate()
		else
			return ""
		end;
	end;
end;

--=========================================================================
-- Call only after calling initScoreListP1,initScoreP1 and initJudgeStatsP1
--=========================================================================

function getJudgeStatsCount(pn,tns)
	if pn == PLAYER_1 then
		return judgeStatsP1[tns]
	end;
	if pn == PLAYER_2 then
		return judgeStatsP2[tns]
	end;
end;

function getMissCount(pn)
	return getJudgeStatsCount(pn,"TapNoteScore_Miss")+getJudgeStatsCount(pn,"TapNoteScore_W5")+getJudgeStatsCount(pn,"TapNoteScore_W4")
end;

function getScore(pn,scoreType)
	if scoreType == 0 or scoreType == nil then
		scoreType = defaultScoreType
	end;

	if scoreType == 1 then
		return 
		getJudgeStatsCount(pn,"TapNoteScore_W1")*scoreWeight["TapNoteScore_W1"]+
		getJudgeStatsCount(pn,"TapNoteScore_W2")*scoreWeight["TapNoteScore_W2"]+
		getJudgeStatsCount(pn,"TapNoteScore_W3")*scoreWeight["TapNoteScore_W3"]+
		getJudgeStatsCount(pn,"TapNoteScore_W4")*scoreWeight["TapNoteScore_W4"]+
		getJudgeStatsCount(pn,"TapNoteScore_W5")*scoreWeight["TapNoteScore_W5"]+
		getJudgeStatsCount(pn,"TapNoteScore_Miss")*scoreWeight["TapNoteScore_Miss"]+
		getJudgeStatsCount(pn,"TapNoteScore_CheckpointHit")*scoreWeight["TapNoteScore_CheckpointHit"]+
		getJudgeStatsCount(pn,"TapNoteScore_CheckpointMiss")*scoreWeight["TapNoteScore_CheckpointMiss"]+
		getJudgeStatsCount(pn,"TapNoteScore_HitMine")*scoreWeight["TapNoteScore_HitMine"]+
		getJudgeStatsCount(pn,"TapNoteScore_AvoidMine")*scoreWeight["TapNoteScore_AvoidMine"]+
		getJudgeStatsCount(pn,"HoldNoteScore_LetGo")*scoreWeight["HoldNoteScore_LetGo"]+
		getJudgeStatsCount(pn,"HoldNoteScore_Held")*scoreWeight["HoldNoteScore_Held"]+
		getJudgeStatsCount(pn,"HoldNoteScore_MissedHold")*scoreWeight["HoldNoteScore_MissedHold"]

	elseif scoreType == 2 then
		return 
		getJudgeStatsCount(pn,"TapNoteScore_W1")*psWeight["TapNoteScore_W1"]+
		getJudgeStatsCount(pn,"TapNoteScore_W2")*psWeight["TapNoteScore_W2"]+
		getJudgeStatsCount(pn,"TapNoteScore_W3")*psWeight["TapNoteScore_W3"]+
		getJudgeStatsCount(pn,"TapNoteScore_W4")*psWeight["TapNoteScore_W4"]+
		getJudgeStatsCount(pn,"TapNoteScore_W5")*psWeight["TapNoteScore_W5"]+
		getJudgeStatsCount(pn,"TapNoteScore_Miss")*psWeight["TapNoteScore_Miss"]+
		getJudgeStatsCount(pn,"TapNoteScore_CheckpointHit")*psWeight["TapNoteScore_CheckpointHit"]+
		getJudgeStatsCount(pn,"TapNoteScore_CheckpointMiss")*psWeight["TapNoteScore_CheckpointMiss"]+
		getJudgeStatsCount(pn,"TapNoteScore_HitMine")*psWeight["TapNoteScore_HitMine"]+
		getJudgeStatsCount(pn,"TapNoteScore_AvoidMine")*psWeight["TapNoteScore_AvoidMine"]+
		getJudgeStatsCount(pn,"HoldNoteScore_LetGo")*psWeight["HoldNoteScore_LetGo"]+
		getJudgeStatsCount(pn,"HoldNoteScore_Held")*psWeight["HoldNoteScore_Held"]+
		getJudgeStatsCount(pn,"HoldNoteScore_MissedHold")*psWeight["HoldNoteScore_MissedHold"]
	elseif scoreType == 3 then
		return
		getJudgeStatsCount(pn,"TapNoteScore_W1")*migsWeight["TapNoteScore_W1"]+
		getJudgeStatsCount(pn,"TapNoteScore_W2")*migsWeight["TapNoteScore_W2"]+
		getJudgeStatsCount(pn,"TapNoteScore_W3")*migsWeight["TapNoteScore_W3"]+
		getJudgeStatsCount(pn,"TapNoteScore_W4")*migsWeight["TapNoteScore_W4"]+
		getJudgeStatsCount(pn,"TapNoteScore_W5")*migsWeight["TapNoteScore_W5"]+
		getJudgeStatsCount(pn,"TapNoteScore_Miss")*migsWeight["TapNoteScore_Miss"]+
		getJudgeStatsCount(pn,"TapNoteScore_CheckpointHit")*migsWeight["TapNoteScore_CheckpointHit"]+
		getJudgeStatsCount(pn,"TapNoteScore_CheckpointMiss")*migsWeight["TapNoteScore_CheckpointMiss"]+
		getJudgeStatsCount(pn,"TapNoteScore_HitMine")*migsWeight["TapNoteScore_HitMine"]+
		getJudgeStatsCount(pn,"TapNoteScore_AvoidMine")*migsWeight["TapNoteScore_AvoidMine"]+
		getJudgeStatsCount(pn,"HoldNoteScore_LetGo")*migsWeight["HoldNoteScore_LetGo"]+
		getJudgeStatsCount(pn,"HoldNoteScore_Held")*migsWeight["HoldNoteScore_Held"]+
		getJudgeStatsCount(pn,"HoldNoteScore_MissedHold")*migsWeight["HoldNoteScore_MissedHold"]
	else
		return 0
	end
end;