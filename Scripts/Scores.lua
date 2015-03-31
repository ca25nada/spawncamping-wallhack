

-- Change this to change the scoretype the theme returns 
--(should be made into a preference eventually)
local defaultScoreType = 2 --1DP 2PS 3MIGS

local scoreTypeText = {
	[1] = "DP",
	[2] = "PS",
	[3] = "MIGS"
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
	HoldNoteScore_Missed = 0,
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

local song
local profileP1
local stepsP1
local profileP1
local hsTableP1
local indexScoreP1

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

function initScoreListP1()
	resetScoreListP1()
	song = GAMESTATE:GetCurrentSong()
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
		stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
		if profileP1 ~= nil and stepsP1 ~= nil and song ~= nil then
			hsTableP1 = profileP1:GetHighScoreList(song,stepsP1):GetHighScores()
		end;
	end;
end;

--============================================================
-- Call only after calling initScoreListP1
--============================================================
function initScoreP1(index)
	if hsTableP1 ~= nil and #hsTableP1 >= 1 and index <= #hsTableP1 then
		indexScoreP1 = hsTableP1[index]
	end;
end;

function getMaxNotesP1()
	if stepsP1 ~= nil then
		return stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_TapsAndHolds")-- Radarvalue, maximum number of notes
 	else
 		return 0
 	end;
end

function getMaxHoldsP1()
	if stepsP1 ~= nil then
		return (stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds") + stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls")) or 0 -- Radarvalue, maximum number of holds
	else
 		return 0
 	end;
end;

function getMaxScoreP1(scoreType) -- dp, ps, migs = 1,2,3 respectively, 0 reverts to default
	local maxNotes = getMaxNotesP1()
	local maxHolds = getMaxHoldsP1()
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
-- Call only after calling initScoreListP1 and initScoreP1
--============================================================

function initJudgeStatsP1()
	if indexScoreP1 ~= nil then
		for k,_ in pairs(judgeStatsP1) do
			if k == 'HoldNoteScore_LetGo' or k == 'HoldNoteScore_Held' or k == 'HoldNoteScore_MissedHold' then
				judgeStatsP1[k] = indexScoreP1:GetHoldNoteScore(k)
			else 
				judgeStatsP1[k] = indexScoreP1:GetTapNoteScore(k)
			end;
		end
	end
end;	

function getScoreGradeP1()
	if indexScoreP1 ~= nil then
		return indexScoreP1:GetGrade()
	else
		return '~'
	end;
end;


--=========================================================================
-- Call only after calling initScoreListP1,initScoreP1 and initJudgeStatsP1
--=========================================================================

function getJudgeStatsCountP1(tns)
	return judgeStatsP1[tns]
end;

function getMissCountP1()
	return getJudgeStatsCountP1("TapNoteScore_Miss")+getJudgeStatsCountP1("TapNoteScore_W5")+getJudgeStatsCountP1("TapNoteScore_W4")
end;

function getScoreP1(scoreType)
	if scoreType == 0 or scoreType == nil then
		scoreType = defaultScoreType
	end;

	if scoreType == 1 then
		return 
		getJudgeStatsCountP1("TapNoteScore_W1")*scoreWeight["TapNoteScore_W1"]+
		getJudgeStatsCountP1("TapNoteScore_W2")*scoreWeight["TapNoteScore_W2"]+
		getJudgeStatsCountP1("TapNoteScore_W3")*scoreWeight["TapNoteScore_W3"]+
		getJudgeStatsCountP1("TapNoteScore_W4")*scoreWeight["TapNoteScore_W4"]+
		getJudgeStatsCountP1("TapNoteScore_W5")*scoreWeight["TapNoteScore_W5"]+
		getJudgeStatsCountP1("TapNoteScore_Miss")*scoreWeight["TapNoteScore_Miss"]+
		getJudgeStatsCountP1("TapNoteScore_CheckpointHit")*scoreWeight["TapNoteScore_CheckpointHit"]+
		getJudgeStatsCountP1("TapNoteScore_CheckpointMiss")*scoreWeight["TapNoteScore_CheckpointMiss"]+
		getJudgeStatsCountP1("TapNoteScore_HitMine")*scoreWeight["TapNoteScore_HitMine"]+
		getJudgeStatsCountP1("TapNoteScore_AvoidMine")*scoreWeight["TapNoteScore_AvoidMine"]+
		getJudgeStatsCountP1("HoldNoteScore_LetGo")*scoreWeight["HoldNoteScore_LetGo"]+
		getJudgeStatsCountP1("HoldNoteScore_Held")*scoreWeight["HoldNoteScore_Held"]+
		getJudgeStatsCountP1("HoldNoteScore_MissedHold")*scoreWeight["HoldNoteScore_MissedHold"]

	elseif scoreType == 2 then
		return 
		getJudgeStatsCountP1("TapNoteScore_W1")*psWeight["TapNoteScore_W1"]+
		getJudgeStatsCountP1("TapNoteScore_W2")*psWeight["TapNoteScore_W2"]+
		getJudgeStatsCountP1("TapNoteScore_W3")*psWeight["TapNoteScore_W3"]+
		getJudgeStatsCountP1("TapNoteScore_W4")*psWeight["TapNoteScore_W4"]+
		getJudgeStatsCountP1("TapNoteScore_W5")*psWeight["TapNoteScore_W5"]+
		getJudgeStatsCountP1("TapNoteScore_Miss")*psWeight["TapNoteScore_Miss"]+
		getJudgeStatsCountP1("TapNoteScore_CheckpointHit")*psWeight["TapNoteScore_CheckpointHit"]+
		getJudgeStatsCountP1("TapNoteScore_CheckpointMiss")*psWeight["TapNoteScore_CheckpointMiss"]+
		getJudgeStatsCountP1("TapNoteScore_HitMine")*psWeight["TapNoteScore_HitMine"]+
		getJudgeStatsCountP1("TapNoteScore_AvoidMine")*psWeight["TapNoteScore_AvoidMine"]+
		getJudgeStatsCountP1("HoldNoteScore_LetGo")*psWeight["HoldNoteScore_LetGo"]+
		getJudgeStatsCountP1("HoldNoteScore_Held")*psWeight["HoldNoteScore_Held"]+
		getJudgeStatsCountP1("HoldNoteScore_MissedHold")*psWeight["HoldNoteScore_MissedHold"]
	elseif scoreType == 3 then
		return
		getJudgeStatsCountP1("TapNoteScore_W1")*migsWeight["TapNoteScore_W1"]+
		getJudgeStatsCountP1("TapNoteScore_W2")*migsWeight["TapNoteScore_W2"]+
		getJudgeStatsCountP1("TapNoteScore_W3")*migsWeight["TapNoteScore_W3"]+
		getJudgeStatsCountP1("TapNoteScore_W4")*migsWeight["TapNoteScore_W4"]+
		getJudgeStatsCountP1("TapNoteScore_W5")*migsWeight["TapNoteScore_W5"]+
		getJudgeStatsCountP1("TapNoteScore_Miss")*migsWeight["TapNoteScore_Miss"]+
		getJudgeStatsCountP1("TapNoteScore_CheckpointHit")*migsWeight["TapNoteScore_CheckpointHit"]+
		getJudgeStatsCountP1("TapNoteScore_CheckpointMiss")*migsWeight["TapNoteScore_CheckpointMiss"]+
		getJudgeStatsCountP1("TapNoteScore_HitMine")*migsWeight["TapNoteScore_HitMine"]+
		getJudgeStatsCountP1("TapNoteScore_AvoidMine")*migsWeight["TapNoteScore_AvoidMine"]+
		getJudgeStatsCountP1("HoldNoteScore_LetGo")*migsWeight["HoldNoteScore_LetGo"]+
		getJudgeStatsCountP1("HoldNoteScore_Held")*migsWeight["HoldNoteScore_Held"]+
		getJudgeStatsCountP1("HoldNoteScore_MissedHold")*migsWeight["HoldNoteScore_MissedHold"]
	else
		return "????"
	end

end;