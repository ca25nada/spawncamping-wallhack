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
	if score == nil or steps == nil then
		return 17
	end

	local grade = score:GetWifeGrade()
	local clearLevel = 18
	local lifeDiff = 4 -- default to 4

	local maxNotes
	local maxHolds

	local tapNoteScore = {
		TapNoteScore_W1 = score:GetTapNoteScore('TapNoteScore_W1'),
		TapNoteScore_W2 = score:GetTapNoteScore('TapNoteScore_W2'),
		TapNoteScore_W3 = score:GetTapNoteScore('TapNoteScore_W3'),
		TapNoteScore_W4 = score:GetTapNoteScore('TapNoteScore_W4'),
		TapNoteScore_W5 = score:GetTapNoteScore('TapNoteScore_W5'),
		TapNoteScore_Miss = score:GetTapNoteScore('TapNoteScore_Miss'),
		TapNoteScore_HitMine = score:GetTapNoteScore('TapNoteScore_HitMine'),
		TapNoteScore_AvoidMine = score:GetTapNoteScore('TapNoteScore_AvoidMine')
	}

	local holdNoteScore = {
		HoldNoteScore_LetGo = score:GetHoldNoteScore('HoldNoteScore_LetGo'),
		HoldNoteScore_Held = score:GetHoldNoteScore('HoldNoteScore_Held'),
		HoldNoteScore_MissedHold = score:GetHoldNoteScore('HoldNoteScore_MissedHold')
	}

	-- Use notes if there's no CC, taps if there's CC
	if steps ~= nil then 
		if GAMESTATE:CountNotesSeparately() then
			maxNotes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes") or 0
		else
			maxNotes = steps:GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds") or 0
		end
		maxHolds = (steps:GetRadarValues(pn):GetValue("RadarCategory_Holds") + steps:GetRadarValues(pn):GetValue("RadarCategory_Rolls"))
	end

	if grade == nil then
		-- Return no play if there's no grade for the score. (which shoudn't happen anyway)
		return 17
	elseif grade == 'Grade_Failed' then -- failed
		return 15
	end

	if tapNoteScore['TapNoteScore_W1'] + tapNoteScore['TapNoteScore_W2'] + tapNoteScore['TapNoteScore_W3'] + tapNoteScore['TapNoteScore_W4'] +
		tapNoteScore['TapNoteScore_W5'] + tapNoteScore['TapNoteScore_Miss'] ~= maxNotes then

		return 16

	end

	-- MFC
	if tapNoteScore['TapNoteScore_W1'] == maxNotes and
		holdNoteScore['HoldNoteScore_Held'] == maxHolds then
		return 1
	end

	-- PFC
	if tapNoteScore['TapNoteScore_W1'] + tapNoteScore['TapNoteScore_W2'] == maxNotes and
		holdNoteScore['HoldNoteScore_Held'] == maxHolds then

		if tapNoteScore['TapNoteScore_W2'] == 1 then
			return 2 -- WF
		elseif tapNoteScore['TapNoteScore_W2'] < 10 then
			return 3 -- SDP
		else
			return 4 -- PFC
		end
	end

	-- FC
	local missCount = tapNoteScore['TapNoteScore_W4'] + tapNoteScore['TapNoteScore_W5'] + tapNoteScore['TapNoteScore_Miss']
	if missCount == 0 then

		if tapNoteScore['TapNoteScore_W3'] == 1 then
			return 5 -- BF
		elseif tapNoteScore['TapNoteScore_W3'] < 10 then
			return 6 -- SDG
		else
			return 7 -- FC
		end

	elseif missCount == 1 then
		return 8 -- MF
	elseif missCount < 10 and missCount > 1 then
		return 9 -- SDCB
	end
	
	return 12 -- Clear
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
				end
			end
			i = i+1
		end
	end

	return clearType[highest]
end

function getClearTypeLampQuad(width, height)
	local t = Def.ActorFrame{
		SetClearTypeCommand = function(self, params)
			self:RunCommandsOnChildren(function(self) self:playcommand("Set", params) end)
		end
	}


	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(width, height)
		end,
		SetCommand = function(self, params)
			if params then
				self:diffuse(getClearTypeColor(params.clearType))
			end
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(width, height)
		end,
		SetCommand = function(self, params)
			if not params then
				return
			end

			if getClearTypeLevel(params.clearType) <= 7 then
				self:diffuseblink()
				self:effectcolor2(color("1,1,1,0.8"))
				self:effectcolor1(color("1,1,1,0"))
				self:effectperiod(0.1)
			else
				self:diffuseramp()
				self:effectcolor2(color("1,1,1,0.6"))
				self:effectcolor1(color("1,1,1,0"))
				self:effecttiming(2,1,0,0)
			end
		end
	}

	return t
end