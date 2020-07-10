-- theme identification file

themeInfo = {
	Name = "spawncamping-wallhack (etterna .70.1)",
	Version = "2.2.5", -- a.b.c, a for complete overhauls, b for major releases, c for minor additions/bugfix.
	Date = "20200709",
}

function getThemeName()
	return themeInfo["Name"]
end

function getThemeVersion()
	return themeInfo["Version"]
end

function getThemeDate()
	return themeInfo["Date"]
end
