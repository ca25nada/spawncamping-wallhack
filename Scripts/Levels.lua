-- STEPMANIA RPG - MINUS THE ROLEPLAY PART

local curExp = {
	PlayerNumber_P1,
	PlayerNumber_P2
}

function getProfileExp(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	if profile ~= nil then
		return math.floor(profile:GetTotalTapsAndHolds()/10 + profile:GetTotalNumSongsPlayed()*10)
	else
		return 0
	end
end

function getLevel(exp)
	return math.floor(math.sqrt(math.sqrt(exp+4)-2))
end

function getLvExp(level)
	return math.pow(level,4) + 4*math.pow(level,2)
end

function getNextLvExp(level)
	return getLvExp(level+1) - getLvExp(level)
end

-- Set the current exp as player enters gameplay.
function setCurExp(pn)
	curExp[pn] = getProfileExp(pn)
end

-- Returns the exp difference between the set exp and the actual exp.
function getExpDiff(pn)
	if curExp[pn] == nil then
		return 0
	end
	return getProfileExp(pn) - curExp[pn]
end

function playerLeveled(pn)
	if curExp[pn] == nil then
		return false
	end
	return getLevel(curExp[pn]) ~= getLevel(getProfileExp(pn))
end