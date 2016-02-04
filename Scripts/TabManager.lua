

-- Tabs are 0 indexed
local tabIndex = 1

local tabData = { -- Name, Available in singleplayer, Available in multiplayer.
	{"General",true,true},
	{"Simfile",true,false},
	{"Score",true,false},
	{"Profile",false,false},
	{"Other",true,true}
}

local availableTabs1P = {true,true,true,false,true,true}
local availableTabs2P = {true,false,false,false,true,true}
local tabSize = #tabData

-- Resets the index of the tabs to 1
function resetTabIndex()
	tabIndex = 1
end

function setTabIndex(index)
	if GAMESTATE:GetNumPlayersEnabled() == 1 then
		if tabData[index][2] then
			tabIndex = index
			MESSAGEMAN:Broadcast("TabChanged")
		end
	else
		if tabData[index][3] then
			tabIndex = index
			MESSAGEMAN:Broadcast("TabChanged")
		end
	end
end

-- Returns the current tab index
function getTabIndex()
	return tabIndex
end

-- Returns the total number of tabs
function getTabSize()
	return tabSize
end

function getTabName(index)
	return tabData[index][1]
end

-- Returns whether a certain tab is enabled
function isTabEnabled(index)
	if GAMESTATE:GetNumPlayersEnabled() == 1 then
		return tabData[index][2]
	else
		return tabData[index][3]
	end
end
