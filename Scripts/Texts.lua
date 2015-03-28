local shortDiff = {
	Difficulty_Beginner	= 'BG',
	Difficulty_Easy		= 'EZ',
	Difficulty_Medium	= 'NM',
	Difficulty_Hard		= 'HD',
	Difficulty_Challenge= 'IN',
	Difficulty_Edit 	= 'ED',
	Difficulty_Couple	= 'CP',
	Difficulty_Routine	= 'RT',
	Beginner			= 'BG',
	Easy				= 'EZ',
	Normal				= 'NM',
	Hard				= 'HD',
	Insane 				= 'IN',
	Edit 				= 'ED',
	Couple				= 'CP',
	Routine				= 'RT'
}

function getShortDifficulty(diff)
	return shortDiff[diff]
end;