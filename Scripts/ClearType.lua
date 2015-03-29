-------------------------------------------------------------------
--Methods for generating IIDX-ish ClearType texts given the score--
-------------------------------------------------------------------



local stypetable = { -- Shorthand Versions of ClearType. Not Really used anywhere yet but who knows
	[1]="Marv F-Combo",
	[2]="Whiteflag",
	[3]="SDP",
	[4]="Perf F-Combo",
	[5]="Blackflag",
	[6]="SDG",
	[7]="F-Combo",
	[8]="Missflag",
	[9]="SDCB",
	[10]="Clear",
	[11]="Failed",
	[12]="No Play",
	[13]="-",
	[14]="Ragequit" -- can't implement unless there's a way to track playcounts by difficulty
};

local typetable = { -- ClearType texts
	[1]="Marvelous Full Combo",
	[2]="Whiteflag",
	[3]="Single Digit Perfects",
	[4]="Perfect Full Combo",
	[5]="Blackflag",
	[6]="Single Digit Greats",
	[7]="Full Combo",
	[8]="Missflag",
	[9]="Single Digit CBs",
	[10]="Clear",
	[11]="Failed",
	[12]="No Play",
	[13]="-",
	[14]="Ragequit" -- can't implement unless there's a way to track playcounts by difficulty
};

local typecolors = {-- colors corresponding to cleartype
	[1]		= color("#66ccff"),
	[2]		= color("#dddddd"),
	[3] 	= color("#cc8800"),
	[4] 	= color("#eeaa00"),
	[5]		= color("#999999"),
	[6]		= color("#448844"),
	[7]		= color("#66cc66"),
	[8]		= color("#cc6666"),
	[9]		= color("#666666"),
	[10]	= color("#33aaff"),
	[11]	= color("#e61e25"),
	[12]	= color("#666666"),
	[13]	= color("#666666"),
	[14]	= color("#e61e25")
};

-- ClearTypes based on stage awards and grades.
-- Stageaward based cleartypes do not work if anything causes the stageaward to not show up (disqualification, score saving is off, etc.)
-- and will just result in "Clear". I migggggggggght just drop the SA usage and use raw values instead.
-- returntype 	=0 -> ClearType, 
--				=1 -> ShortClearType, 
-- 				=2 -> ClearTypeColor, 
-- 				=else -> ClearTypeLevel
local function clearTypes(stageaward,grade,playcount,misscount,returntype)
	stageaward = stageaward or 0; -- initialize everything incase some are nil
	grade = grade or 0;
	playcount = playcount or 0;
	misscount = misscount or 0;

	clearlevel = 12; -- no play

	if grade == 0 then
		if playcount == 0 then
			clearlevel = 12;
		end;
	else
		if grade == 'Grade_Failed' then -- failed
			clearlevel = 11;
		elseif stageaward == 'StageAward_SingleDigitW2'then -- SDP
			clearlevel = 3;
		elseif stageaward == 'StageAward_SingleDigitW3' then -- SDG
			clearlevel = 6;
		elseif stageaward == 'StageAward_OneW2' then -- whiteflag
			clearlevel = 2;
		elseif stageaward == 'StageAward_OneW3' then -- blackflag
			clearlevel = 5;
		elseif stageaward == 'StageAward_FullComboW1' or grade == 'Grade_Tier01' then -- MFC
			clearlevel = 1;
		elseif stageaward == 'StageAward_FullComboW2' or grade == 'Grade_Tier02'then -- PFC
			clearlevel = 4;
		elseif stageaward == 'StageAward_FullComboW3' then -- FC
			clearlevel = 7;
		else
			if misscount == 1 then 
				clearlevel = 8; -- missflag
			else
				clearlevel = 10; -- Clear
			end;
		end;
	end;
	if returntype == 0 then
		return typetable[clearlevel];
	elseif returntype == 1 then
		return stypetable[clearlevel];
	elseif returntype == 2 then
		return typecolors[clearlevel];
	else
		return clearlevel
	end;
end;



--				=0 -> ClearType, 
--				=1 -> ShortClearType, 
-- 				=2 -> ClearTypeColor, 
-- 				=else -> ClearTypeLevel
-- Returns the ClearType for Player1
function getClearType(pn,ret)
	local song
	local steps
	local profile
	local hScoreList
	local hScore
	local playCount = 0
	local stageAward
	local missCount = 0
	local grade
	song = GAMESTATE:GetCurrentSong()
	steps = GAMESTATE:GetCurrentSteps(pn)
	profile = GetPlayerOrMachineProfile(pn)
	if song ~= nil and steps ~= nil then
		hScoreList = profile:GetHighScoreList(song,steps):GetHighScores()
		hScore = hScoreList[1]
	end;
	if hScore ~= nil then
		playCount = profile:GetSongNumTimesPlayed(song)
		missCount = hScore:GetTapNoteScore('TapNoteScore_Miss')+hScore:GetTapNoteScore('TapNoteScore_W5')+hScore:GetTapNoteScore('TapNoteScore_W4');
		grade = hScore:GetGrade()
		stageAward = hScore:GetStageAward()
	end;
	return clearTypes(stageAward,grade,playCount,missCount,ret) or typetable[12]; 
end;

-- Methods for other uses (manually setting colors/text, etc.)

function getClearTypeText(index)
	return typetable[index];
end;

function getShortClearTypeText(index)
	return stypetable[index];
end;

function getClearTypeColor(index)
	return typecolors[index];
end;

--]]