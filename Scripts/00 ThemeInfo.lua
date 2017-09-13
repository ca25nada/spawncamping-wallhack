-- theme identification file

themeInfo = {
	Name = "spawncamping-wallhack (etterna .54)",
	Version = "2.1.0", -- a.b.c, a for complete overhauls, b for major releases, c for minor additions/bugfix.
	Date = "20170912",
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
