-- STEPMANIA RPG - MINUS THE ROLEPLAY PART

local curExp = {
	PlayerNumber_P1
}


-- Returns the total Exp given a PlayerNumber
function getProfileExp(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	if profile ~= nil then
		return math.floor(profile:GetTotalDancePoints()/10 + profile:GetTotalNumSongsPlayed()*50)
	else
		return 0
	end
end

-- Returns the level given the Exp
function getLevel(exp)
	return math.floor(math.sqrt(math.sqrt(exp+441)-20))
end

-- Returns the Exp required for a level
function getLvExp(level)
	return math.pow(level,4) + 40*math.pow(level,2) - 41
end

-- Returns the Exp difference from the given level and the next.
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

-- Returns true if a player leveled up between setting the exp and now.
function playerLeveled(pn)
	if curExp[pn] == nil then
		return false
	end
	return getLevel(curExp[pn]) ~= getLevel(getProfileExp(pn))
end