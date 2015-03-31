

local tabIndex = 0
local tabSize = 5

function resetTabIndex()
	tabIndex = 0
end;

function incrementTabIndex()
	tabIndex = (tabIndex+1)%tabSize
end;

function getTabIndex()
	return tabIndex
end;