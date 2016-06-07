-- theme identification file

themeInfo = {
	Name = "spawncamping-wallhack",
	Version = "2.0.1", -- a.b.c, a for complete overhauls, b for major releases, c for minor additions/bugfix.
	Date = "20160607",
};

function getThemeName()
	return themeInfo["Name"]
end;

function getThemeVersion()
	return themeInfo["Version"]
end;

function getThemeDate()
	return themeInfo["Date"]
end;
