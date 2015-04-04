--Assortment of wrapped functions related to score/grade tracking

local defaultScoreType =getTempThemePref("DefaultScoreType")

local gradeString = {
	Grade_Tier01 = 'AAAA',
	Grade_Tier02 = 'AAA',
	Grade_Tier03 = 'AA',
	Grade_Tier04 = 'A',
	Grade_Tier05 = 'B',
	Grade_Tier06 = 'C',
	Grade_Tier07 = 'D',
	Grade_Failed = 'F'
}

local gradeTier = {
	Tier01 = THEME:GetMetric("PlayerStageStats", "GradePercentTier01"), -- AAAA
	Tier02 = THEME:GetMetric("PlayerStageStats", "GradePercentTier02"), -- AAA
	Tier03 = THEME:GetMetric("PlayerStageStats", "GradePercentTier03"), -- AA
	Tier04 = THEME:GetMetric("PlayerStageStats", "GradePercentTier04"), -- A
	Tier05 = THEME:GetMetric("PlayerStageStats", "GradePercentTier05"), -- B
	Tier06 = THEME:GetMetric("PlayerStageStats", "GradePercentTier06"), -- C
	Tier07 = THEME:GetMetric("PlayerStageStats", "GradePercentTier07"), -- D
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
	TapNoteScore_CheckpointMiss = 0,--PREFSMAN:GetPreference("GradeWeightCheckpointMiss"),		--  0
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
	TapNoteScore_CheckpointMiss 	= 0,--PREFSMAN:GetPreference("PercentScoreWeightCheckpointMiss"),
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
	TapNoteScore_CheckpointMiss 	= 0,
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

--table containing all the tap note judgments in order they occured
local judgeTableP1 = {}
local judgeTableP2 = {}

--table containing all the timing offsets from non-miss judges 
local offsetTableP1 = {}
local offsetTableP2 = {}

local curMaxNotesP1 = 0
local curMaxNotesP2 = 0
local curMaxHoldsP1 = 0
local curMaxHoldsP2 = 0
local curMaxMinesP1 = 0
local curMaxMinesP2 = 0
--[[
function PJudge(pn,judge)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores(judge)
end

function PHJudge(pn,judge)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetHoldNoteScores(judge)
end
--]]

function isFailingST(pn)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetFailed()
end

-- call this before doing anything
function resetJudgeST()
	for k,_ in pairs(judgeStatsP1) do
		judgeStatsP1[k] = 0
		judgeStatsP2[k] = 0
	end
	judgeTableP1 = {}
	judgeTableP2 = {}
	offsetTableP1 = {}
	offsetTableP2 = {}
	curMaxNotesP1 = 0
	curMaxNotesP2 = 0
	curMaxMinesP1 = 0
	curMaxMinesP2 = 0
	curMaxHoldsP1 = 0
	curMaxHoldsP2 = 0
	return
end

function addJudgeST(pn,judge,isHold)
	--
	if isHold then
		if pn == PLAYER_1 then
			if isFailingST(PLAYER_1) == false then
				judgeTableP1[#judgeTableP1+1] = judge
				judgeStatsP1[judge] = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetHoldNoteScores(judge) --revert to just incrmenting by 1 when autoplay conditions are available
			end
			curMaxHoldsP1 = curMaxHoldsP1+1
		end
		if pn == PLAYER_2 then
			if isFailingST(PLAYER_2) == false then
				judgeTableP2[#judgeTableP2+1] = judge
				judgeStatsP2[judge] = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetHoldNoteScores(judge)
			end
			curMaxHoldsP2 = curMaxHoldsP2+1
		end
	else
		if pn == PLAYER_1 then
			if isFailingST(PLAYER_1) == false then
				judgeTableP1[#judgeTableP1+1] = judge
				judgeStatsP1[judge] = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores(judge)
			end
			if (judge ~= 'TapNoteScore_HitMine') and (judge ~= 'TapNoteScore_AvoidMine') then
				curMaxNotesP1 = curMaxNotesP1+1
			else
				curMaxMinesP1 = curMaxMinesP1+1
			end
		end
		if pn == PLAYER_2 then
			if isFailingST(PLAYER_2) == false then
				judgeTableP2[#judgeTableP2+1] = judge
				judgeStatsP2[judge] = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores(judge)
			end
			if (judge ~= 'TapNoteScore_HitMine') and (judge ~= 'TapNoteScore_AvoidMine') then
				curMaxNotesP2 = curMaxNotesP2+1
			else
				curMaxMinesP2 = curMaxMinesP2+1
			end
		end
	end
end

function addOffsetST(pn,offset)
	if pn == PLAYER_1 and GAMESTATE:IsHumanPlayer(PLAYER_1) then
		offsetTableP1[#offsetTableP1+1] = offset
	end;
	if pn == PLAYER_2 and GAMESTATE:IsHumanPlayer(PLAYER_2)then
		offsetTableP2[#offsetTableP2+1] = offset
	end;
end

function getOffsetTableST(pn)
	if pn == PLAYER_1 then
		return offsetTableP1
	end;
	if pn == PLAYER_2 then
		return offsetTableP2
	end;
	return
end

function getJudgeTableST(pn)
	if pn == PLAYER_1 then
		return judgeTableP1
	end;
	if pn == PLAYER_2 then
		return judgeTableP2
	end;
	return
end

function getJudgeST(pn,judge)
	if pn == PLAYER_1 then
		return judgeStatsP1[judge] or 0
	end;
	if pn == PLAYER_2 then
		return judgeStatsP2[judge] or 0
	end
	return 0
end


function getMaxNotesST(pn)
	return GAMESTATE:GetCurrentSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds") or 0 -- Radarvalue, maximum number of notes
end

function getCurMaxNotesST(pn)
	if pn == PLAYER_1 then
		return curMaxNotesP1 --or 0
	end;
	if pn == PLAYER_2 then
		return curMaxNotesP2-- or 0
	end;
	return 0
end

function getMaxHoldsST(pn)
	return (GAMESTATE:GetCurrentSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Holds") + GAMESTATE:GetCurrentSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Rolls")) or 0 -- Radarvalue, maximum number of holds
end

function getCurMaxHoldsST(pn)
	if pn == PLAYER_1 then
		return curMaxHoldsP1 --or 0
	elseif pn == PLAYER_2 then
		return curMaxHoldsP2 --or 0
	end
	return 0
end

function getCurMaxMinesST(pn)
	if pn == PLAYER_1 then
		return curMaxMinesP1 --or 0
	elseif pn == PLAYER_2 then
		return curMaxMinesP2 --or 0
	end
	return 0
end

function getMaxScoreST(pn,scoreType) -- dp, ps, migs = 0,1,2 respectively
	local maxNotes = getMaxNotesST(pn)
	local maxHolds = getMaxHoldsST(pn)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end;

	if scoreType == 1 then
		return (maxNotes*scoreWeight["TapNoteScore_W1"]+maxHolds*scoreWeight["HoldNoteScore_Held"]) or 0-- maximum DP
	elseif scoreType == 2 then
		return (maxNotes*psWeight["TapNoteScore_W1"]+maxHolds*psWeight["HoldNoteScore_Held"]) or 0  -- maximum %score DP
	elseif scoreType == 3 then
		return (maxNotes*migsWeight["TapNoteScore_W1"]+maxHolds*migsWeight["HoldNoteScore_Held"]) or 0
	end
	return 0
end

function getCurMaxScoreST(pn,scoreType)
	local curMaxNotes = getCurMaxNotesST(pn)
	local curMaxHolds = getCurMaxHoldsST(pn)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end;

	if scoreType == 1 then
		return (curMaxNotes*scoreWeight["TapNoteScore_W1"]+curMaxHolds*scoreWeight["HoldNoteScore_Held"]) or 0-- maximum DP
	elseif scoreType == 2 then
		return (curMaxNotes*psWeight["TapNoteScore_W1"]+curMaxHolds*psWeight["HoldNoteScore_Held"]) or 0  -- maximum %score DP
	elseif scoreType == 3 then
		return (curMaxNotes*migsWeight["TapNoteScore_W1"]+curMaxHolds*migsWeight["HoldNoteScore_Held"]) or 0
	end
	return 0
end

function getCurScoreST(pn,scoreType)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end;

	if pn == PLAYER_1 then
		if scoreType == 1 then
			return (judgeStatsP1["TapNoteScore_W1"]*scoreWeight["TapNoteScore_W1"]+judgeStatsP1["TapNoteScore_W2"]*scoreWeight["TapNoteScore_W2"]+judgeStatsP1["TapNoteScore_W3"]*scoreWeight["TapNoteScore_W3"]+judgeStatsP1["TapNoteScore_W4"]*scoreWeight["TapNoteScore_W4"]+judgeStatsP1["TapNoteScore_W5"]*scoreWeight["TapNoteScore_W5"]+judgeStatsP1["TapNoteScore_Miss"]*scoreWeight["TapNoteScore_Miss"]+judgeStatsP1["TapNoteScore_HitMine"]*scoreWeight["TapNoteScore_HitMine"]+judgeStatsP1["HoldNoteScore_Held"]*scoreWeight["HoldNoteScore_Held"]+judgeStatsP1["HoldNoteScore_LetGo"]*scoreWeight["HoldNoteScore_LetGo"]) or 0-- maximum DP
		elseif scoreType == 2 then
			return (judgeStatsP1["TapNoteScore_W1"]*psWeight["TapNoteScore_W1"]+judgeStatsP1["TapNoteScore_W2"]*psWeight["TapNoteScore_W2"]+judgeStatsP1["TapNoteScore_W3"]*psWeight["TapNoteScore_W3"]+judgeStatsP1["TapNoteScore_W4"]*psWeight["TapNoteScore_W4"]+judgeStatsP1["TapNoteScore_W5"]*psWeight["TapNoteScore_W5"]+judgeStatsP1["TapNoteScore_Miss"]*psWeight["TapNoteScore_Miss"]+judgeStatsP1["TapNoteScore_HitMine"]*psWeight["TapNoteScore_HitMine"]+judgeStatsP1["HoldNoteScore_Held"]*psWeight["HoldNoteScore_Held"]+judgeStatsP1["HoldNoteScore_LetGo"]*psWeight["HoldNoteScore_LetGo"]) or 0  -- maximum %score DP
		elseif scoreType == 3 then
			return (judgeStatsP1["TapNoteScore_W1"]*migsWeight["TapNoteScore_W1"]+judgeStatsP1["TapNoteScore_W2"]*migsWeight["TapNoteScore_W2"]+judgeStatsP1["TapNoteScore_W3"]*migsWeight["TapNoteScore_W3"]+judgeStatsP1["TapNoteScore_W4"]*migsWeight["TapNoteScore_W4"]+judgeStatsP1["TapNoteScore_W5"]*migsWeight["TapNoteScore_W5"]+judgeStatsP1["TapNoteScore_Miss"]*migsWeight["TapNoteScore_Miss"]+judgeStatsP1["TapNoteScore_HitMine"]*migsWeight["TapNoteScore_HitMine"]+judgeStatsP1["HoldNoteScore_Held"]*migsWeight["HoldNoteScore_Held"]+judgeStatsP1["HoldNoteScore_LetGo"]*migsWeight["HoldNoteScore_LetGo"]) or 0
		end
	elseif pn == PLAYER_2 then
		if scoreType == 0 then
			return (judgeStatsP2["TapNoteScore_W1"]*scoreWeight["TapNoteScore_W1"]+judgeStatsP2["TapNoteScore_W2"]*scoreWeight["TapNoteScore_W2"]+judgeStatsP2["TapNoteScore_W3"]*scoreWeight["TapNoteScore_W3"]+judgeStatsP2["TapNoteScore_W4"]*scoreWeight["TapNoteScore_W4"]+judgeStatsP2["TapNoteScore_W5"]*scoreWeight["TapNoteScore_W5"]+judgeStatsP2["TapNoteScore_Miss"]*scoreWeight["TapNoteScore_Miss"]+judgeStatsP2["TapNoteScore_HitMine"]*scoreWeight["TapNoteScore_HitMine"]+judgeStatsP2["HoldNoteScore_Held"]*scoreWeight["HoldNoteScore_Held"]+judgeStatsP2["HoldNoteScore_LetGo"]*scoreWeight["HoldNoteScore_LetGo"]) or 0-- maximum DP
		elseif scoreType == 1 then
			return (judgeStatsP2["TapNoteScore_W1"]*psWeight["TapNoteScore_W1"]+judgeStatsP2["TapNoteScore_W2"]*psWeight["TapNoteScore_W2"]+judgeStatsP2["TapNoteScore_W3"]*psWeight["TapNoteScore_W3"]+judgeStatsP2["TapNoteScore_W4"]*psWeight["TapNoteScore_W4"]+judgeStatsP2["TapNoteScore_W5"]*psWeight["TapNoteScore_W5"]+judgeStatsP2["TapNoteScore_Miss"]*psWeight["TapNoteScore_Miss"]+judgeStatsP2["TapNoteScore_HitMine"]*psWeight["TapNoteScore_HitMine"]+judgeStatsP2["HoldNoteScore_Held"]*psWeight["HoldNoteScore_Held"]+judgeStatsP2["HoldNoteScore_LetGo"]*psWeight["HoldNoteScore_LetGo"]) or 0  -- maximum %score DP
		elseif scoreType == 2 then
			return (judgeStatsP2["TapNoteScore_W1"]*migsWeight["TapNoteScore_W1"]+judgeStatsP2["TapNoteScore_W2"]*migsWeight["TapNoteScore_W2"]+judgeStatsP2["TapNoteScore_W3"]*migsWeight["TapNoteScore_W3"]+judgeStatsP2["TapNoteScore_W4"]*migsWeight["TapNoteScore_W4"]+judgeStatsP2["TapNoteScore_W5"]*migsWeight["TapNoteScore_W5"]+judgeStatsP2["TapNoteScore_Miss"]*migsWeight["TapNoteScore_Miss"]+judgeStatsP2["TapNoteScore_HitMine"]*migsWeight["TapNoteScore_HitMine"]+judgeStatsP2["HoldNoteScore_Held"]*migsWeight["HoldNoteScore_Held"]+judgeStatsP2["HoldNoteScore_LetGo"]*migsWeight["HoldNoteScore_LetGo"]) or 0
		end
	end
	return 0
end

function getGradeST(pn)
	local curDPScore =getCurScoreST(pn,1)
	local curPSScore = getCurScoreST(pn,2)
	local curMaxDPScore = getCurMaxScoreST(pn,1)
	local curMaxPSScore = getCurMaxScoreST(pn,2)

	if SCREENMAN:GetTopScreen():GetLifeMeter(pn):IsFailing() then
		return 'Grade_Failed'
	elseif curDPScore <= 0 and curPSScore <= 0 then
		return GetGradeFromPercent(0)
	elseif curPSScore == curMaxPSScore then
		return 'Grade_Tier01'
	elseif curDPScore == curMaxDPScore then
		return 'Grade_Tier02'
	else
		return GetGradeFromPercent(curDPScore/curMaxDPScore)
	end;

	return 
end

--]]
function scoreTrackTest()
	return "hoooo-"
end