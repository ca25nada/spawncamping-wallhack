
WifeTiers = {
	Grade_Tier01 = 0.99999, 
	Grade_Tier02 = 0.9999, 
	Grade_Tier03 = 0.9998, 
	Grade_Tier04 = 0.9997, 
	Grade_Tier05 = 0.9992, 
	Grade_Tier06 = 0.9985,
	Grade_Tier07 = 0.9975, 
	Grade_Tier08 = 0.99, 
	Grade_Tier09 = 0.965,
	Grade_Tier10 = 0.93, 
	Grade_Tier11 = 0.9, 
	Grade_Tier12 = 0.85,
	Grade_Tier13 = 0.8,
	Grade_Tier14 = 0.7,
	Grade_Tier15 = 0.6,
	Grade_Tier16 = 0.5,
}

WifeTierList = {"Grade_Tier01","Grade_Tier02","Grade_Tier03","Grade_Tier04","Grade_Tier05","Grade_Tier06","Grade_Tier07","Grade_Tier08","Grade_Tier09","Grade_Tier10","Grade_Tier11","Grade_Tier12","Grade_Tier13","Grade_Tier14","Grade_Tier15","Grade_Tier16"}

function isMidGrade(grade)
	return grade == "Grade_Tier02" or grade == "Grade_Tier03" or grade == "Grade_Tier05" or grade == "Grade_Tier06" or grade == "Grade_Tier08" or grade == "Grade_Tier09" or grade == "Grade_Tier11" or grade == "Grade_Tier12"
end

function gradeFamilyToBetterGrade(grade)
	if grade == "Grade_Tier04" then
		return "Grade_Tier01"
	elseif grade == "Grade_Tier07" then
		return "Grade_Tier04"
	elseif grade == "Grade_Tier10" then
		return "Grade_Tier07"
	elseif grade == "Grade_Tier14" then
		return "Grade_Tier10"
	else
		if grade == "Grade_Tier01" then
			return grade
		else
			return string.format("Grade_Tier%02d",(tonumber(grade:sub(-2))-1))
		end
	end
end


function getWifeGradeTier(percent)
	percent = percent / 100
	local midgrades = PREFSMAN:GetPreference("UseMidGrades")
	for _,v in pairs(WifeTierList) do
		if not midgrades and isMidGrade(v) then
			-- not using midgrades, skip the midgrades
		else
			if percent > WifeTiers[v] then
				return v
			end
		end
	end

	return "Grade_Tier16"

end

--Gets the highest score possible for the scoretype
function getMaxScore(pn) -- WIFE
	local maxNotes = getMaxNotes(pn)
	return maxNotes*2
end

function getGradeThreshold(pn,grade)
	local maxScore = getMaxScore(pn,1)
	if grade == "Grade_Failed" then
		return 0
	else
		return math.ceil(maxScore*WifeTiers[grade])
	end
end

function getNearbyGrade(pn, wifeScore, grade)
	local nextGrade
	local gradeScore = 0
	local nextGradeScore = 0
	local midgrades = PREFSMAN:GetPreference("UseMidGrades")
	if grade == "Grade_Tier01" then
		return grade, 0
	elseif grade == "Grade_Failed" then
		return "Grade_Tier16", wifeScore
	elseif grade == "Grade_None" then
		return "Grade_Tier16", 0
	else
		if not midgrades then
			local grd = getGradeFamilyForMidGrade(grade)
			nextGrade = gradeFamilyToBetterGrade(grd)
		else
			nextGrade = string.format("Grade_Tier%02d",(tonumber(grade:sub(-2))-1))
		end
		gradeScore = getGradeThreshold(pn,grade)
		nextGradeScore = getGradeThreshold(pn,nextGrade)

		curGradeDiff = wifeScore - gradeScore
		nextGradeDiff = wifeScore - nextGradeScore

		if math.abs(curGradeDiff) < math.abs(nextGradeDiff) then
			return grade,curGradeDiff
		else
			return nextGrade,nextGradeDiff
		end
	end
end


function getScoreGrade(score)
	if score ~= nil then
		return score:GetWifeGrade()
	else
		return "Grade_None"
	end
end

-- Do this until the raw wife score is exposed to lua.
function getScore(score, steps, percent)
	if percent == nil then percent = true end
	if score ~= nil and steps ~= nil then
		local notes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
		if percent == true then
			return score:GetWifeScore()
		else
			return score:GetWifeScore() * notes * 2
		end
	end
	return 0
end

------------------------------------------------
-- Rate filter stuff -- 

local sortScoreType = 0
local function scoreComparator(scoreA,scoreB)
	return  getScore(scoreA) > getScore(scoreB)
end

-- returns a sorted table based on the criteria given by the
-- scoreComparator() function.
function sortScore(hsTable)
	table.sort(hsTable,scoreComparator)
	return hsTable
end

function getCurRate()
	local mods = GAMESTATE:GetSongOptionsString()
	if string.find(mods,"Haste") ~= nil then
		return 'Haste'
	elseif string.find(mods,"xMusic") == nil then
		return '1.0x'
	else
		return (string.match(mods,"%d+%.%d+xMusic")):sub(1,-6)
	end
end

----------------------------------------------------

-- Grabs the highest grade available from all currently saved scores.
-- Ignore parameter will ignore the score at that index.

function getScoreTable(pn, rate, steps)
	if not rate then rate = "1.0x" end
	local rtTable = getRateTable(pn, steps)

	if not rtTable then return nil end
	return rtTable[rate]
end

-- Grabs the score with the highest max combo from all currently saved scores.
-- Ignore parameter will ignore the score at that index.
function getBestMaxCombo(pn,ignore, rate)
	if not rate then rate = "1.0x" end

	local highest = 0
	local bestScore
	local indexScore
	local i = 0

	local hsTable = getScoreTable(pn, rate)

	local steps = GAMESTATE:GetCurrentSteps(pn)

	if hsTable ~= nil and #hsTable >= 1 then
		while i <= #hsTable do
			if i ~= ignore then
				indexScore = hsTable[i]
				if indexScore ~= nil then
					temp = getScoreMaxCombo(indexScore)
					if temp > highest then
						highest = temp
						bestScore = indexScore
					end
				end
			end
			i = i+1
		end
	end

	return bestScore
end

-- Grabs the score with the lowest misscount from all currently saved scores.
-- Ignore parameter will ignore the score at that index.
function getBestMissCount(pn,ignore, rate)
	if not rate then rate = "1.0x" end
	local lowest = math.huge
	local bestScore
	local temp
	local indexScore
	local i = 0

	local hsTable = getScoreTable(pn, rate)

	local steps = GAMESTATE:GetCurrentSteps(pn)

	if hsTable ~= nil and #hsTable >= 1 then
		while i <= #hsTable do
			if i ~= ignore then
				indexScore = hsTable[i]
				if indexScore ~= nil then
					if indexScore:GetGrade() ~= "Grade_Failed" then
						temp = getScoreMissCount(indexScore)
						if temp < lowest then
							lowest = temp
							bestScore = indexScore
						end
					end
				end
			end
			i = i+1
		end
	end

	return bestScore
end

function getBestScore(pn, ignore, rate, percent)
	if not rate then rate = "1.0x" end
	local highest = -math.huge

	local indexScore
	local bestScore

	local hsTable = getScoreTable(pn, rate)
	local steps = GAMESTATE:GetCurrentSteps(pn)
	local temp

	if hsTable ~= nil and #hsTable >= 1 then
		for k,v in ipairs(hsTable) do
			if k ~= ignore then
				indexScore = hsTable[k]
				if indexScore ~= nil then
					temp = getScore(indexScore, steps, percent)
					if temp >= highest then
						highest = temp
						bestScore = indexScore
					end
				end
			end
		end
	end
	return bestScore
end

