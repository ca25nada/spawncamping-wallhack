--Assortment of wrapped functions related to score/grade tracking

--Load default scoretype
local defaultScoreType = themeConfig:get_data().global.DefaultScoreType

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
	TapNoteScore_W1				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW1"),					--  2
	TapNoteScore_W2				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW2"),					--  2
	TapNoteScore_W3				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW3"),					--  1
	TapNoteScore_W4				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW4"),					--  0
	TapNoteScore_W5				= THEME:GetMetric("ScoreKeeperNormal","GradeWeightW5"),					-- -4
	TapNoteScore_Miss			= THEME:GetMetric("ScoreKeeperNormal","GradeWeightMiss"),				-- -8
	HoldNoteScore_Held			= THEME:GetMetric("ScoreKeeperNormal","GradeWeightHeld"),				--  6
	TapNoteScore_HitMine		= THEME:GetMetric("ScoreKeeperNormal","GradeWeightHitMine"),				-- -8
	HoldNoteScore_LetGo			= THEME:GetMetric("ScoreKeeperNormal","GradeWeightLetGo"),				--  0
	HoldNoteScore_MissedHold	 = THEME:GetMetric("ScoreKeeperNormal","GradeWeightMissedHold"),
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit	= THEME:GetMetric("ScoreKeeperNormal","GradeWeightCheckpointHit"),		--  0
	TapNoteScore_CheckpointMiss = THEME:GetMetric("ScoreKeeperNormal","GradeWeightCheckpointMiss"),		--  0
}

local psWeight =  { -- Score Weights for percentage scores (EX oni)
	TapNoteScore_W1			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW1"),
	TapNoteScore_W2			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW2"),
	TapNoteScore_W3			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW3"),
	TapNoteScore_W4			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW4"),
	TapNoteScore_W5			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightW5"),
	TapNoteScore_Miss			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightMiss"),
	HoldNoteScore_Held			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightHeld"),
	TapNoteScore_HitMine			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightHitMine"),
	HoldNoteScore_LetGo			= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightLetGo"),
	HoldNoteScore_MissedHold	 = THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightMissedHold"),
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightCheckpointHit"),
	TapNoteScore_CheckpointMiss 	= THEME:GetMetric("ScoreKeeperNormal","PercentScoreWeightCheckpointMiss"),
}

local migsWeight =  { -- Score Weights for MIGS score
	TapNoteScore_W1					= 3,
	TapNoteScore_W2					= 2,
	TapNoteScore_W3					= 1,
	TapNoteScore_W4					= 0,
	TapNoteScore_W5					= -4,
	TapNoteScore_Miss				= -8,
	HoldNoteScore_Held				= IsGame("pump") and 0 or 6,
	TapNoteScore_HitMine			= -8,
	HoldNoteScore_LetGo				= 0,
	HoldNoteScore_MissedHold 			= 0,
	TapNoteScore_AvoidMine			= 0,
	TapNoteScore_CheckpointHit		= 2,
	TapNoteScore_CheckpointMiss 	= -8,
}

local judgeStats = { -- Table containing the # of judgements made so far
	PlayerNumber_P1 = {
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
		TapNoteScore_CheckpointMiss 	= 0
	},
	PlayerNumber_P2 = {
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
		TapNoteScore_CheckpointMiss 	= 0
	}
}

--table containing all the tap note judgments in order they occured
local judgeTable = {
	PlayerNumber_P1 = {},
	PlayerNumber_P2 = {}
}

--table containing all the timing offsets from non-miss judges 
local offsetTable = {
	PlayerNumber_P1 = {},
	PlayerNumber_P2 = {}
}

local curMaxNotes = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0
}

local curMaxHolds = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0
}

local curMaxMines = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0
}

local lastSecond = 0
local pauseCount = 0

function isFailingST(pn)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetFailed()
end

-- call this before doing anything
function resetJudgeST()
	defaultScoreType = themeConfig:get_data().global.DefaultScoreType
	-- defaultScoreType = tonumber(GetUserPref("DefaultScoreType"))
	for _,pn in pairs({PLAYER_1,PLAYER_2}) do
		for k,__ in pairs(judgeStats[pn]) do
			judgeStats[pn][k] = 0
			judgeStats[pn][k] = 0
		end	
		judgeTable[pn] = {}
		offsetTable[pn] = {}
		curMaxNotes[pn] = 0
		curMaxHolds[pn] = 0
		curMaxMines[pn] = 0
	end
	pauseCount = 0
	lastSecond = 0
	return
end

-- Adds a tapnotescore or a holdnotescore to the scoretracker for the specified player.
function addJudgeST(pn,judge,isHold)
	if isHold then -- Holds and Rolls

		if isFailingST(pn) == false then
			judgeStats[pn][judge] = judgeStats[pn][judge]+1
		end
		curMaxHolds[pn] = curMaxHolds[pn]+1

	else -- Everyyyyyyyyyyything elseeeeeeee

		if isFailingST(pn) == false then
			if (judge =="TapNoteScore_W1") or
				(judge =="TapNoteScore_W2") or
				(judge =="TapNoteScore_W3") or
				(judge =="TapNoteScore_W4") or
				(judge =="TapNoteScore_W5") or
				(judge =="TapNoteScore_Miss") or
				(judge =="TapNoteScore_CheckpointHit") or
				(judge =="TapNoteScore_CheckpointMiss") then
				judgeTable[pn][#(judgeTable[pn])+1] = judge -- add to judgetable
			end
			judgeStats[pn][judge] = judgeStats[pn][judge]+1
		end

		if (judge ~= 'TapNoteScore_HitMine') and (judge ~= 'TapNoteScore_AvoidMine') then
			curMaxNotes[pn] = curMaxNotes[pn]+1
		else
			curMaxMines[pn] = curMaxMines[pn]+1
		end
	end
end

--Adds the tapnotescore offset value (in seconds) for the specified player. 
--This should be only be called if the tapnotescore is for actual tap notes, not mines or checkpoints.
function addOffsetST(pn,offset)
	if GAMESTATE:IsHumanPlayer(pn) then
		offsetTable[pn][#(offsetTable[pn])+1] = offset 
	end
end

--Returns a table containing all the offset values for every tapnote that results in a judgment (aka: not mines, not checkpoints, and so on)
function getOffsetTableST(pn)
	return offsetTable[pn]
end

--Returns a table containing all the tapnote judgments made. (Again, this excludes mines, checkpoints, etc.)
function getJudgeTableST(pn)
	return judgeTable[pn]
end

--Returns the #of times the specificed judge has been made. (This includes both tapnotes and holdnotes)
function getJudgeST(pn,judge)
	return judgeStats[pn][judge]
end

--Returns the number of "taps" for the steps that the specified player has selected.
--Note that this isn't the number of actual notes since jumps/hands count as 1 judgment or "taps".
function getMaxNotesST(pn)
	if GAMESTATE:IsCourseMode() then
		local trail = GAMESTATE:GetCurrentTrail(pn)
		local notes = 0

		for _,v in pairs(trail:GetTrailEntries()) do
			if GAMESTATE:GetCurrentGame():CountNotesSeparately() then
				notes = notes + v:GetSteps():GetRadarValues(pn):GetValue("RadarCategory_Notes")
			else
				notes = notes + v:GetSteps():GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds")-- Radarvalue, maximum number of notes
			end
		end
		return notes
	else
		local steps  = GAMESTATE:GetCurrentSteps(pn)
		if GAMESTATE:GetCurrentGame():CountNotesSeparately() then
			return steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
		else
			return steps:GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds") -- Radarvalue, maximum number of notes
		end
	end
end

--Returns the current number of "taps" that have been played so far for the specified player.
function getCurMaxNotesST(pn)
	return curMaxNotes[pn]
end

--Returns the number of holds for the steps that the specified player has selected.
--This includes any notes that has a OK/NG judgment. (holds and rolls)
function getMaxHoldsST(pn)
	if GAMESTATE:IsCourseMode() then
		local trail = GAMESTATE:GetCurrentTrail(pn)
		local holds = 0

		for _,v in pairs(trail:GetTrailEntries()) do
			holds = holds + v:GetSteps():GetRadarValues(pn):GetValue("RadarCategory_Holds") + v:GetSteps():GetRadarValues(pn):GetValue("RadarCategory_Rolls")
		end

		return holds 
	else
		local steps  = GAMESTATE:GetCurrentSteps(pn)
		return steps:GetRadarValues(pn):GetValue("RadarCategory_Holds") + steps:GetRadarValues(pn):GetValue("RadarCategory_Rolls")
	end
end

--Returns the current number of holds that have been played so far for the specified player.
function getCurMaxHoldsST(pn)
	return curMaxHolds[pn]
end

--Returns the current number of mines that hae been played so far for the specified player.
function getCurMaxMinesST(pn)
	return curMaxMines[pn]
end

--Returns the absolute maximum score a player can get for the specified player.
function getMaxScoreST(pn,scoreType) -- dp, ps, migs = 0,1,2 respectively

	local maxNotes = getMaxNotesST(pn)
	local maxHolds = getMaxHoldsST(pn)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end

	if scoreType == 1 then
		return (maxNotes*scoreWeight["TapNoteScore_W1"]+maxHolds*scoreWeight["HoldNoteScore_Held"]) or 0-- maximum DP
	elseif scoreType == 2 then
		return (maxNotes*psWeight["TapNoteScore_W1"]+maxHolds*psWeight["HoldNoteScore_Held"]) or 0  -- maximum %score DP
	elseif scoreType == 3 then
		return (maxNotes*migsWeight["TapNoteScore_W1"]+maxHolds*migsWeight["HoldNoteScore_Held"]) or 0
	end
	return 0
end

--Returns the maximum score currently obtainable for the specified player.
function getCurMaxScoreST(pn,scoreType)

	local curMaxNotes = getCurMaxNotesST(pn)
	local curMaxHolds = getCurMaxHoldsST(pn)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end

	if scoreType == 1 then
		return (curMaxNotes*scoreWeight["TapNoteScore_W1"]+curMaxHolds*scoreWeight["HoldNoteScore_Held"]) or 0-- maximum DP
	elseif scoreType == 2 then
		return (curMaxNotes*psWeight["TapNoteScore_W1"]+curMaxHolds*psWeight["HoldNoteScore_Held"]) or 0  -- maximum %score DP
	elseif scoreType == 3 then
		return (curMaxNotes*migsWeight["TapNoteScore_W1"]+curMaxHolds*migsWeight["HoldNoteScore_Held"]) or 0
	end
	return 0
end

--Returns the current score obtained by the player.
function getCurScoreST(pn,scoreType)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end

	if scoreType == 1 then
		return (judgeStats[pn]["TapNoteScore_W1"]*scoreWeight["TapNoteScore_W1"]+judgeStats[pn]["TapNoteScore_W2"]*scoreWeight["TapNoteScore_W2"]+judgeStats[pn]["TapNoteScore_W3"]*scoreWeight["TapNoteScore_W3"]+judgeStats[pn]["TapNoteScore_W4"]*scoreWeight["TapNoteScore_W4"]+judgeStats[pn]["TapNoteScore_W5"]*scoreWeight["TapNoteScore_W5"]+judgeStats[pn]["TapNoteScore_Miss"]*scoreWeight["TapNoteScore_Miss"]+judgeStats[pn]["TapNoteScore_CheckpointHit"]*scoreWeight["TapNoteScore_CheckpointHit"]+judgeStats[pn]["TapNoteScore_CheckpointMiss"]*scoreWeight["TapNoteScore_CheckpointMiss"]+judgeStats[pn]["TapNoteScore_HitMine"]*scoreWeight["TapNoteScore_HitMine"]+judgeStats[pn]["HoldNoteScore_Held"]*scoreWeight["HoldNoteScore_Held"]+judgeStats[pn]["HoldNoteScore_LetGo"]*scoreWeight["HoldNoteScore_LetGo"]) or 0-- maximum DP
	elseif scoreType == 2 then
		return (judgeStats[pn]["TapNoteScore_W1"]*psWeight["TapNoteScore_W1"]+judgeStats[pn]["TapNoteScore_W2"]*psWeight["TapNoteScore_W2"]+judgeStats[pn]["TapNoteScore_W3"]*psWeight["TapNoteScore_W3"]+judgeStats[pn]["TapNoteScore_W4"]*psWeight["TapNoteScore_W4"]+judgeStats[pn]["TapNoteScore_W5"]*psWeight["TapNoteScore_W5"]+judgeStats[pn]["TapNoteScore_Miss"]*psWeight["TapNoteScore_Miss"]+judgeStats[pn]["TapNoteScore_CheckpointHit"]*psWeight["TapNoteScore_CheckpointHit"]+judgeStats[pn]["TapNoteScore_CheckpointMiss"]*psWeight["TapNoteScore_CheckpointMiss"]+judgeStats[pn]["TapNoteScore_HitMine"]*psWeight["TapNoteScore_HitMine"]+judgeStats[pn]["HoldNoteScore_Held"]*psWeight["HoldNoteScore_Held"]+judgeStats[pn]["HoldNoteScore_LetGo"]*psWeight["HoldNoteScore_LetGo"]) or 0  -- maximum %score DP
	elseif scoreType == 3 then
		return (judgeStats[pn]["TapNoteScore_W1"]*migsWeight["TapNoteScore_W1"]+judgeStats[pn]["TapNoteScore_W2"]*migsWeight["TapNoteScore_W2"]+judgeStats[pn]["TapNoteScore_W3"]*migsWeight["TapNoteScore_W3"]+judgeStats[pn]["TapNoteScore_W4"]*migsWeight["TapNoteScore_W4"]+judgeStats[pn]["TapNoteScore_W5"]*migsWeight["TapNoteScore_W5"]+judgeStats[pn]["TapNoteScore_Miss"]*migsWeight["TapNoteScore_Miss"]+judgeStats[pn]["TapNoteScore_CheckpointHit"]*migsWeight["TapNoteScore_CheckpointHit"]+judgeStats[pn]["TapNoteScore_CheckpointMiss"]*migsWeight["TapNoteScore_CheckpointMiss"]+judgeStats[pn]["TapNoteScore_HitMine"]*migsWeight["TapNoteScore_HitMine"]+judgeStats[pn]["HoldNoteScore_Held"]*migsWeight["HoldNoteScore_Held"]+judgeStats[pn]["HoldNoteScore_LetGo"]*migsWeight["HoldNoteScore_LetGo"]) or 0
	end

	return 0
end

--Returns the current grade of the player.
--This is based on the current "average" score a player has rather than the total score.
function getGradeST(pn)
	local curDPScore =getCurScoreST(pn,1)
	local curPSScore = getCurScoreST(pn,2)
	local curMaxDPScore = getCurMaxScoreST(pn,1)
	local curMaxPSScore = getCurMaxScoreST(pn,2)

	local failing = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetFailed()
	if GAMESTATE:IsBattleMode() then
		failing = false
	end

	if failing then
		return 'Grade_Failed'
	elseif curDPScore <= 0 and curPSScore <= 0 then
		return GetGradeFromPercent(0)
	elseif curPSScore == curMaxPSScore then
		return 'Grade_Tier01'
	elseif curDPScore == curMaxDPScore then
		return 'Grade_Tier02'
	else
		return GetGradeFromPercent(curDPScore/curMaxDPScore)
	end

	return 
end

function isFullCombo(pn)
	local misscount = getJudgeST(pn,"TapNoteScore_Miss") + getJudgeST(pn,"TapNoteScore_W5") + getJudgeST(pn,"TapNoteScore_W4")
	return misscount == 0
end

-- Literally what ossu has.
-- At least according to what the wiki says heh.
-- x10 of Std.Dev from all of the judgment offsets.
function getUnstableRateST(pn)
	local sum1 = 0
	local mean = 0
	local offset = getOffsetTableST(pn)
	for i=1,#offset do
		sum1 = sum1+(offset[i]*1000)
	end
	mean = sum1/#offset

	local sum2 = 0
	local sum3 = 0
	for i=1,#offset do
		sum2 = sum2 + math.pow(((offset[i]*1000)-mean),2)
		sum3 = sum3 + ((offset[i]*1000)-mean)
	end
	return math.sqrt((sum2 - math.pow(sum3,2)/#offset)/(#offset-1))*10
end

function setLastSecond(t)
	lastSecond = t
end

function getLastSecond()
	return lastSecond
end