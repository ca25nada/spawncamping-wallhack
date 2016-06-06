------------------------------------------------------
--Methods for generating IIDX-esque ClearType texts --
------------------------------------------------------

local clearType = {
	[1]="ClearType_MFC",
	[2]="ClearType_WF",
	[3]="ClearType_SDP",
	[4]="ClearType_PFC",
	[5]="ClearType_BF",
	[6]="ClearType_SDG",
	[7]="ClearType_FC",
	[8]="ClearType_MF",
	[9]="ClearType_SDCB", -- unused
	[10]="ClearType_EXHC",
	[11]="ClearType_HClear",
	[12]="ClearType_Clear",
	[13]="ClearType_EClear",
	[14]="ClearType_AClear",
	[15]="ClearType_Failed",
	[16]="ClearType_Invalid",
	[17]="ClearType_Noplay",
	[18]="ClearType_None",
}


local clearTypeReverse = { -- Reverse Lookup table for clearType
	ClearType_MFC 		= 1,
	ClearType_WF 		= 2,
	ClearType_SDP 		= 3,
	ClearType_PFC 		= 4,
	ClearType_BF 		= 5,
	ClearType_SDG		= 6,
	ClearType_FC 		= 7,
	ClearType_MF 		= 8,
	ClearType_SDCB		= 9,
	ClearType_EXHC		= 10,
	ClearType_HClear 	= 11,
	ClearType_Clear 	= 12,
	ClearType_EClear 	= 13,
	ClearType_AClear 	= 14,
	ClearType_Failed 	= 15,
	ClearType_Invalid 	= 16,
	ClearType_Noplay 	= 17,
	ClearType_None 		= 18,
}


-- TODO: Move these to en.ini
-- ClearType texts
local clearTypeText = {
	ClearType_MFC 		= "Marvelous Full Combo",
	ClearType_WF 		= "Whiteflag",
	ClearType_SDP 		= "Single Digit Perfects",
	ClearType_PFC 		= "Perfect Full Combo",
	ClearType_BF 		= "Blackflag",
	ClearType_SDG		= "Single Digit Greats",
	ClearType_FC 		= "Full Combo",
	ClearType_MF 		= "Missflag",
	ClearType_SDCB		= "Single Digit CBs",
	ClearType_EXHC		= "EX-Hard Clear",
	ClearType_HClear 	= "Hard Clear",
	ClearType_Clear 	= "Clear",
	ClearType_EClear 	= "Easy Clear",
	ClearType_AClear 	= "Assist Clear",
	ClearType_Failed 	= "Failed",
	ClearType_Invalid 	= "Invalid",
	ClearType_Noplay 	= "No Play",
	ClearType_None 		= "",
}


 -- Shorter ClearType texts
local clearTypeTextShort = {
	ClearType_MFC 		= "Marv F-Combo",
	ClearType_WF 		= "Whiteflag",
	ClearType_SDP 		= "SDP",
	ClearType_PFC 		= "Perf F-Combo",
	ClearType_BF 		= "Blackflag",
	ClearType_SDG		= "SDG",
	ClearType_FC 		= "F-Combo",
	ClearType_MF 		= "Missflag",
	ClearType_SDCB		= "SDCB",
	ClearType_EXHC		= "EXH-Clear",
	ClearType_HClear 	= "H-Clear",
	ClearType_Clear 	= "Clear",
	ClearType_EClear 	= "E-Clear",
	ClearType_AClear 	= "A-Clear",
	ClearType_Failed 	= "Failed",
	ClearType_Invalid 	= "Invalid",
	ClearType_Noplay 	= "No Play",
	ClearType_None 		= "",
}

	
-- Returns an integer corresponding to the clear level of the score.
local function getClearLevel (pn,steps,score)

	-- Return no play if score doesn't exist.
	if score == nil then
		return 17
	end

	-- Return invalid if the score isn't uhh valid.
	if not isScoreValid(pn,steps,score) then
		return 16
	end

	local grade = score:GetGrade()
	local missCount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4')
	local stageAward = score:GetStageAward()
	local clearLevel = 18
	local lifeDiff = 4 -- default to 4

	if grade == nil then
		-- Return no play if there's no grade for the score. (which shoudn't happen anyway)
		clearLevel = 17
	else
		-- Go through all the Stage award based cleartypes
		if grade == 'Grade_Failed' then -- failed
			clearLevel = 15

		elseif stageAward == 'StageAward_SingleDigitW2' then -- SDP
			clearLevel = 3
		elseif stageAward == 'StageAward_SingleDigitW3' then -- SDG
			clearLevel = 6
		elseif stageAward == 'StageAward_OneW2' then -- whiteflag
			clearLevel = 2
		elseif stageAward == 'StageAward_OneW3' then -- blackflag
			clearLevel = 5
		elseif stageAward == 'StageAward_FullComboW1' or grade == 'Grade_Tier01' then -- MFC
			clearLevel = 1
		elseif stageAward == 'StageAward_FullComboW2' or grade == 'Grade_Tier02'then -- PFC
			clearLevel = 4
		elseif stageAward == 'StageAward_FullComboW3' then -- FC
			clearLevel = 7
		else
			-- Missflag
			if missCount == 1 then 
				clearLevel = 8;
			else
				-- Everything else are clears.
				-- Load life difficulty off of ghost data.
				local ghostLifeDiff = getGhostDataParameter(pn,score,'lifeDifficulty')
				if ghostLifeDiff ~= nil then
					lifeDiff = ghostLifeDiff
				end;

				if lifeDiff == 4 then
					clearLevel = 12 -- Clear
				elseif lifeDiff < 4 then
					clearLevel = 13 -- Easy Clear
				elseif lifeDiff == 5 or lifeDiff == 6 then
					clearLevel = 11 -- Hard Clear
				else
					clearLevel = 10 -- EXHC
				end
			end
		end
	end

	return clearLevel
end


-- Returns the ClearType level integer given the ClearType string.
function getClearTypeLevel(clearType)
	return clearTypeReverse[clearType]
end


-- Returns the full text given the ClearType.
function getClearTypeText(clearType)
	return clearTypeText[clearType]
end


-- Returns the shortened text given the ClearType.
function getClearTypeShortText(clearType)
	return clearTypeTextShort[clearType]
end


-- Returns the ClearType from the given HighScore
function getClearType(pn,steps,score)
	return clearType[getClearLevel(pn,steps,score)]
end


-- Returns the highest ClearType from the given HighScoreList.
-- Optional parameter ignore will ignore the specified index in the HighScoreList when provided.
function getHighestClearType(pn,steps,scoreList,ignore)

	if steps == nil then
		return clearType[18]
	end

	local profile = GetPlayerOrMachineProfile(pn)
	local hScore
	local i = 1
	local highest = 17

	if scoreList ~= nil then
		while i <= #scoreList do
			if i ~= ignore then
				hScore = scoreList[i]
				if hScore ~= nil then
					highest = math.min(highest,getClearLevel(pn,steps,hScore))
				end;
			end;
			i = i+1
		end
	end

	return clearType[highest]
end

