
themeColors = {
	placeholder = {
		[1] = color("#FFFFFF")
	},
	main = {
		[1] = color("#00AEEF"), --Primary light blue
		[2] = color("#009AEF"),-- Slightly darker blue
		[3] = color("#00C2EF") -- Slightly lighter blue
	}

}

function getPlaceholderColor()
	return themeColors.placeholder[1] or color("#FFFFFF")
end

function getMainColor(i)
	return themeColors.main[i] or color("#FFFFFF")
end