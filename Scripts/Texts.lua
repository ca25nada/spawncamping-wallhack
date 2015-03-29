local shortDiffName = {
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

local DiffName = {
	Difficulty_Beginner	= 'Beginner',
	Difficulty_Easy		= 'Easy',
	Difficulty_Medium	= 'Normal',
	Difficulty_Hard		= 'Hard',
	Difficulty_Challenge= 'Insane',
	Difficulty_Edit 	= 'Edit',
	Difficulty_Couple	= 'Couple',
	Difficulty_Routine	= 'Routine',
}

function getShortDifficulty(diff)
	if diff ~= nil and diff ~= "" then
		return shortDiffName[diff]
	else
		return "ED"
	end
end;

function getDifficulty(diff)
	if diff ~= nil and diff ~= "" then
		return DiffName[diff]
	elseif diff == "" then
		return "Edit"
	else 
		return diff
	end
end;