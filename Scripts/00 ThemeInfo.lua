-- theme identification file

themeInfo = {
	Name = "spawncamping-wallhack",
	Version = "0.01", -- next is 0.85 (or not)
	Date = "20150427",
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