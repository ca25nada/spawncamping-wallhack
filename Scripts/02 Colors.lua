
themeColors = {
	placeholder = {
		[1] = color("#FFFFFF")
	},
	main = {
		[1] = color("#00AEEF"), --Primary light blue
		[2] = color("#009AEF"),-- Slightly darker blue
		[3] = color("#00C2EF") -- Slightly lighter blue
	},

	grade = {
		Grade_Tier01	= color("#66ccff"), -- AAAA
		Grade_Tier02	= color("#eebb00"), -- AAA
		Grade_Tier03	= color("#66cc66"), -- AA
		Grade_Tier04	= color("#da5757"), -- A
		Grade_Tier05	= color("#5b78bb"), -- B
		Grade_Tier06	= color("#c97bff"), -- C
		Grade_Tier07	= color("#8c6239"), -- D
		Grade_Failed	= color("0.8,0.8,0.8,1"), -- F
		Grade_None		= color("#666666"), -- no play
	}

}

function getPlaceholderColor()
	return themeColors.placeholder[1] or color("#FFFFFF")
end

function getMainColor(i)
	return themeColors.main[i] or color("#FFFFFF")
end

function getGradeColor (grade)
	return themeColors.grade[grade] or color("#ffffff");
end;