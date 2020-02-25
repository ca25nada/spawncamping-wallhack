local shortJudgeString = { -- Text strings for each Judgment types
	TapNoteScore_W1 = 'MA',
	TapNoteScore_W2	= 'PR',
	TapNoteScore_W3	 = 'GR',
	TapNoteScore_W4	= 'GD',
	TapNoteScore_W5	= 'BD',
	TapNoteScore_Miss = 'MS',			
	HoldNoteScore_Held = 'OK',	
	HoldNoteScore_LetGo = 'NG',
	HoldNoteScore_MissedHold = 'HM',
}

local judgeString = { -- Text strings for each Judgment types
	TapNoteScore_W1 = 'Marvelous',
	TapNoteScore_W2	= 'Perfect',
	TapNoteScore_W3	 = 'Great',
	TapNoteScore_W4	= 'Good',
	TapNoteScore_W5	= 'Bad',
	TapNoteScore_Miss = 'Miss',			
	HoldNoteScore_Held = 'OK',	
	HoldNoteScore_LetGo = 'NG',	
	HoldNoteScore_MissedHold = 'Hold Miss',
}

local scoreTypeText = {
	[1] = "Wife"
}

function getJudgeStrings(judge)
	if judge ~= nil then
		return judgeString[judge] or judge
	end
end

function getShortJudgeStrings(judge)
	if judge ~= nil then
		return shortJudgeString[judge] or judge
	end
end

function getScoreTypeText(scoreType)
	if scoreType == 0 then
		return scoreTypeText[themeConfig:get_data().global.DefaultScoreType]
	else
		return scoreTypeText[scoreType]
	end
end