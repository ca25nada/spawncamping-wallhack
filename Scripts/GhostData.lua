--[[ 
more like an extension of the highscore class...ish now.
format:
ghostTable = {
	[SimfileSHA1] = {
		[ghostTableSHA1] = {
			judgmentData = string,
			judgmentHash = string,
			timingDifficulty = number,
			lifeDifficulty = number,
			offsetMean = number,
			offsetStdDev = number
		}
	}
}
--]]

local defaultScoreType = themeConfig:get_data().global.DefaultScoreType

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


local currentGhostData = {
	PlayerNumber_P1 = {},
	PlayerNumber_P2 = {}
} -- Loaded from theme


local currentGhostIndex = {
	PlayerNumber_P1 = 1,
	PlayerNumber_P2 = 1
}


local tempGhostData = {
	PlayerNumber_P1 = {},
	PlayerNumber_P2 = {}
} -- Tracked


local ghostScoreStats = { -- Table containing the # of judgements made so far
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


-- Resets the variables
function resetGhostData()
	for _,pn in pairs({PLAYER_1,PLAYER_2}) do
		currentGhostData[pn] = {}
		tempGhostData[pn] = {}
		currentGhostIndex[pn] = 1
		for k,__ in pairs(ghostScoreStats[pn]) do
			ghostScoreStats[pn][k] = 0
			ghostScoreStats[pn][k] = 0
		end	
	end
end


-- Adds a judgment event to the tempghostdata table.
function addJudgeGD(pn,judgment,isHold)
	tempGhostData[pn][#(tempGhostData[pn])+1] = {judgment,isHold}
end


-- Returns the SHA-1 Hash of the simfile that will be used for the ghostdata table key.
local function getSimfileHash(steps)
	return SHA1FileHex(steps:GetFilename())
end


-- Returns the SHA-1 of the score's timestamp to be used as the 2nd key of the 2d table.
-- Since we're trying to tie each ghostdata to each HighScore saved in stepmania,
-- its timestamp is the only thing that can uniquely identify a score afaik.
local function getGhostDataHash(score)
	return SHA1StringHex(score:GetDate())
end


-- Returns the hash of the concatenated string of several ghostdata metadata.
local function getJudgmentDataHash(score,judgmentDataString,timingDifficulty,lifeDifficulty)
	return SHA1StringHex(string.format("%s%s%d%d",getGhostDataHash(score),SHA1StringHex(judgmentDataString),timingDifficulty,lifeDifficulty))
end


-- Returns true if ghostdata exists.
function ghostDataExists(pn,score)
	if not GAMESTATE:IsPlayerEnabled(pn) or 
		GAMESTATE:IsCourseMode() or 
		score == nil then
		return false
	end

	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))
	local ghostTableSHA1 = getGhostDataHash(score)
	local ghostData = ghostTable:get_data(pn_to_profile_slot(pn))[ghostTableSHA1]

	if ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1] ~= nil then
		return ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1] ~= nil 
	end
	return false
end


-- Returns true if the ghostdata is valid.
function isGhostDataValid(pn,score)

	if not GAMESTATE:IsPlayerEnabled(pn) or 
		GAMESTATE:IsCourseMode() or 
		score == nil then
		return false
	end
	
	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))
	local ghostTableSHA1 = getGhostDataHash(score)

	if ghostDataExists(pn,score) then
		local judgmentHash = ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].judgmentHash
		local judgmentDataString = ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].judgmentData
		local timingDifficulty = ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].timingDifficulty
		local lifeDifficulty = ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].lifeDifficulty
		return judgmentHash == getJudgmentDataHash(score,judgmentDataString,timingDifficulty,lifeDifficulty)
	end

	return false
end


--Reads the ghostdata string and loads it into the currentghostdata table.
--currentghostdata will be a empty table if it doesn't exist.
function readGhostData(pn,score)
	currentGhostData[pn] = {}

	if not GAMESTATE:IsPlayerEnabled(pn) or 
		GAMESTATE:IsCourseMode() or 
		score == nil then
		return
	end

	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))
	local ghostTableSHA1 = getGhostDataHash(score)


	if isGhostDataValid(pn,score) then
		local judgmentDataString = ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].judgmentData
		-- Check if the hash of the data string match the hash saved in the ghostdata.

		for i = 1 , #judgmentDataString do
			local isHold
			local judgment
			local num = string.byte(judgmentDataString,i)
			
			isHold = num >= 16
			if isHold then
				num = num -16
				judgment = HoldNoteScore[num+1] -- enum values are 0 indexed, tables are 1 indexed.
			else
				judgment = TapNoteScore[num+1]
			end

			currentGhostData[pn][#currentGhostData[pn]+1] = {judgment,isHold}
		end
	end
end


-- Returns the ghostscore table parameter if it exists.
function getGhostDataParameter(pn,score,parameter)
	if not GAMESTATE:IsPlayerEnabled(pn) or
		GAMESTATE:IsCourseMode() or
		score == nil then
		return
	end

	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))
	local ghostTableSHA1 = getGhostDataHash(score)
	if ghostDataExists(pn,score) then
		return ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1][parameter]
	end
end


-- Saves the data loaded in the tempGhostData table as a string
function saveGhostData(pn,score)

	if not GAMESTATE:IsPlayerEnabled(pn) or 
		GAMESTATE:IsCourseMode() or 
		score == nil then
		return
	end

	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))
	local ghostTableSHA1 = getGhostDataHash(score)

	-- Convert the data in tempGhostData table into a binary string.
	local judgmentDataString = ""
	for _,v in pairs(tempGhostData[pn]) do
		local temp = 0
		if v[2] then -- Holds

			temp = tonumber(Enum.Reverse(HoldNoteScore)[v[1]])+16
		else
			temp = tonumber(Enum.Reverse(TapNoteScore)[v[1]])
		end
		judgmentDataString = judgmentDataString..string.format("%c",temp)
	end

	-- If there's no previous ghostscore entry for a song, make a new table.
	if ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1] == nil then
		ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1] = {}
	end

	-- Make and save all the table parameters
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1] = {}
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].judgmentData = judgmentDataString
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].timingDifficulty = GetTimingDifficulty()
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].lifeDifficulty = GetLifeDifficulty()
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].version = getThemeVersion()
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].assist = false
	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1].judgmentHash = getJudgmentDataHash(score,judgmentDataString,GetTimingDifficulty(),GetLifeDifficulty())
	ghostTable:set_dirty(pn_to_profile_slot(pn))
	ghostTable:save(pn)

	SCREENMAN:SystemMessage("Ghost data saved.")
end


--Deletes a single ghostdata given the player, score.
function deleteGhostData(pn,score)

	if not GAMESTATE:IsPlayerEnabled(pn) or 
		GAMESTATE:IsCourseMode() or 
		score == nil then
		return
	end

	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))
	local ghostTableSHA1 = getGhostDataHash(score)
	local ghostData = ghostTable:get_data(pn_to_profile_slot(pn))[ghostTableSHA1]

	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1][ghostTableSHA1] = nil
	ghostTable:set_dirty(pn_to_profile_slot(pn))
	ghostTable:save(pn_to_profile_slot(pn))
	SCREENMAN:SystemMessage("Ghost data deleted.")

end

--Deletes all ghostdata for a song given player.
function deleteGhostDataForSong(pn)

	if not GAMESTATE:IsPlayerEnabled(pn) or 
		GAMESTATE:IsCourseMode() or 
		score == nil then
		return
	end

	local simfileSHA1 = getSimfileHash(GAMESTATE:GetCurrentSteps(pn))

	ghostTable:get_data(pn_to_profile_slot(pn))[simfileSHA1] = nil
	ghostTable:set_dirty(pn_to_profile_slot(pn))
	ghostTable:save(pn_to_profile_slot(pn))
	SCREENMAN:SystemMessage("All Ghost data for this song deleted.")
	
end

--not exactly a pop anymore since I keep the values in the table but w/e.
--returns the judgment and adds the judgment to the ghostScoreStats table.
function popGhostData(pn)
	if #currentGhostData[pn] == 0 or currentGhostIndex[pn] > #currentGhostData[pn] then
		return nil
	end
	local judgment = currentGhostData[pn][currentGhostIndex[pn]]
	ghostScoreStats[pn][judgment[1]] = ghostScoreStats[pn][judgment[1]]+1
	currentGhostIndex[pn] = currentGhostIndex[pn] + 1
	return judgment
end


-- Gets the current exscore of the ghost data.
function getCurScoreGD(pn,scoreType)

	if scoreType == 0 then
		scoreType = defaultScoreType
	end

	if scoreType == 1 then
		return (ghostScoreStats[pn]["TapNoteScore_W1"]*scoreWeight["TapNoteScore_W1"]+ghostScoreStats[pn]["TapNoteScore_W2"]*scoreWeight["TapNoteScore_W2"]+ghostScoreStats[pn]["TapNoteScore_W3"]*scoreWeight["TapNoteScore_W3"]+ghostScoreStats[pn]["TapNoteScore_W4"]*scoreWeight["TapNoteScore_W4"]+ghostScoreStats[pn]["TapNoteScore_W5"]*scoreWeight["TapNoteScore_W5"]+ghostScoreStats[pn]["TapNoteScore_Miss"]*scoreWeight["TapNoteScore_Miss"]+ghostScoreStats[pn]["TapNoteScore_CheckpointHit"]*scoreWeight["TapNoteScore_CheckpointHit"]+ghostScoreStats[pn]["TapNoteScore_CheckpointMiss"]*scoreWeight["TapNoteScore_CheckpointMiss"]+ghostScoreStats[pn]["TapNoteScore_HitMine"]*scoreWeight["TapNoteScore_HitMine"]+ghostScoreStats[pn]["HoldNoteScore_Held"]*scoreWeight["HoldNoteScore_Held"]+ghostScoreStats[pn]["HoldNoteScore_LetGo"]*scoreWeight["HoldNoteScore_LetGo"]) or 0-- maximum DP
	elseif scoreType == 2 then
		return (ghostScoreStats[pn]["TapNoteScore_W1"]*psWeight["TapNoteScore_W1"]+ghostScoreStats[pn]["TapNoteScore_W2"]*psWeight["TapNoteScore_W2"]+ghostScoreStats[pn]["TapNoteScore_W3"]*psWeight["TapNoteScore_W3"]+ghostScoreStats[pn]["TapNoteScore_W4"]*psWeight["TapNoteScore_W4"]+ghostScoreStats[pn]["TapNoteScore_W5"]*psWeight["TapNoteScore_W5"]+ghostScoreStats[pn]["TapNoteScore_Miss"]*psWeight["TapNoteScore_Miss"]+ghostScoreStats[pn]["TapNoteScore_CheckpointHit"]*psWeight["TapNoteScore_CheckpointHit"]+ghostScoreStats[pn]["TapNoteScore_CheckpointMiss"]*psWeight["TapNoteScore_CheckpointMiss"]+ghostScoreStats[pn]["TapNoteScore_HitMine"]*psWeight["TapNoteScore_HitMine"]+ghostScoreStats[pn]["HoldNoteScore_Held"]*psWeight["HoldNoteScore_Held"]+ghostScoreStats[pn]["HoldNoteScore_LetGo"]*psWeight["HoldNoteScore_LetGo"]) or 0  -- maximum %score DP
	elseif scoreType == 3 then
		return (ghostScoreStats[pn]["TapNoteScore_W1"]*migsWeight["TapNoteScore_W1"]+ghostScoreStats[pn]["TapNoteScore_W2"]*migsWeight["TapNoteScore_W2"]+ghostScoreStats[pn]["TapNoteScore_W3"]*migsWeight["TapNoteScore_W3"]+ghostScoreStats[pn]["TapNoteScore_W4"]*migsWeight["TapNoteScore_W4"]+ghostScoreStats[pn]["TapNoteScore_W5"]*migsWeight["TapNoteScore_W5"]+ghostScoreStats[pn]["TapNoteScore_Miss"]*migsWeight["TapNoteScore_Miss"]+ghostScoreStats[pn]["TapNoteScore_CheckpointHit"]*migsWeight["TapNoteScore_CheckpointHit"]+ghostScoreStats[pn]["TapNoteScore_CheckpointMiss"]*migsWeight["TapNoteScore_CheckpointMiss"]+ghostScoreStats[pn]["TapNoteScore_HitMine"]*migsWeight["TapNoteScore_HitMine"]+ghostScoreStats[pn]["HoldNoteScore_Held"]*migsWeight["HoldNoteScore_Held"]+ghostScoreStats[pn]["HoldNoteScore_LetGo"]*migsWeight["HoldNoteScore_LetGo"]) or 0
	end
	return 0
end