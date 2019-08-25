
WifeTiers = {
	Grade_Tier01 = 0.9997, 
	Grade_Tier02 = 0.9975, 
	Grade_Tier03 = 0.93, 
	Grade_Tier04 = 0.8, 
	Grade_Tier05 = 0.7, 
	Grade_Tier06 = 0.6,
	Grade_Tier07 = 0.0
}

WifeTierList = {"Grade_Tier01","Grade_Tier02","Grade_Tier03","Grade_Tier04","Grade_Tier05","Grade_Tier06","Grade_Tier07"}

function getWifeGradeTier(percent)
	percent = percent / 100
	for _,v in pairs(WifeTierList) do
		if percent > WifeTiers[v] then
			return v
		end
	end

	return "Grade_Tier07"

end

function getScoresByKey(pn, steps)
	local song = GAMESTATE:GetCurrentSong()
	local profile
	if GAMESTATE:IsPlayerEnabled(pn) then
		profile = GetPlayerOrMachineProfile(pn)

		if steps == nil then
			steps = GAMESTATE:GetCurrentSteps(pn)
		end
		
		if profile ~= nil and steps ~= nil and song ~= nil then
			return SCOREMAN:GetScoresByKey(steps:GetChartKey())
		end
	end
	return nil
end

function getMaxNotes(pn)
	if not GAMESTATE:IsPlayerEnabled(pn) then
		return 0
	end

	local steps = GAMESTATE:GetCurrentSteps(pn)
	if steps ~= nil then 
		if GAMESTATE:CountNotesSeparately() then
			return steps:GetRadarValues(pn):GetValue("RadarCategory_Notes") or 0
		else
			return steps:GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds") or 0
		end
	else
		return 0
	end
end

function getMaxHolds(pn)
	if not GAMESTATE:IsPlayerEnabled(pn) then
		return 0
	end

	local steps = GAMESTATE:GetCurrentSteps(pn)
	if steps ~= nil then 
		return  (steps:GetRadarValues(pn):GetValue("RadarCategory_Holds") + steps:GetRadarValues(pn):GetValue("RadarCategory_Rolls")) or 0
	else
		return 0
	end
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
	if grade == "Grade_Tier01" then
		return grade, 0
	elseif grade == "Grade_Failed" then
		return "Grade_Tier07", wifeScore
	elseif grade == "Grade_None" then
		return "Grade_Tier07", 0
	else
		nextGrade = string.format("Grade_Tier%02d",(tonumber(grade:sub(-2))-1))
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

function getScoreMaxCombo(score)
	if score ~= nil then
		return score:GetMaxCombo()
	else
		return 0
	end
end

function getScoreDate(score)
	if score ~= nil then
		return score:GetDate()
	else
		return ""
	end
end

function getScoreTapNoteScore(score,tns)
	if score ~= nil then
		return score:GetTapNoteScore(tns)
	else
		return 0
	end
end

function getScoreHoldNoteScore(score,tns)
	if score ~= nil then
		return score:GetHoldNoteScore(tns)
	else
		return 0
	end
end

function getScoreMissCount(score)
	return getScoreTapNoteScore(score,"TapNoteScore_Miss") + getScoreTapNoteScore(score,"TapNoteScore_W5") + getScoreTapNoteScore(score,"TapNoteScore_W4")
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

-- returns a string corresponding to the rate mod used in the highscore.
function getRate(score)
	-- gets the rate mod used in highscore. doesn't work if ratemod has a different name
	local mods = score:GetModifiers()
	if string.find(mods,"Haste") ~= nil then
		return 'Haste'
	elseif string.find(mods,"xMusic") == nil then
		return '1.0x'
	else
		return (string.match(mods,"%d+%.%d+xMusic")):sub(1,-6)
	end
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

-- returns the index of the highscore in a given highscore table. 
function getHighScoreIndex(hsTable,score)
	for k,v in ipairs(hsTable) do
		if v:GetDate() == score:GetDate() then
			return k
		end
	end
	return 0
end

-- Returns a table containing tables containing scores for each ratemod used. 
function getRateTable(pn, steps)
	local o = getScoresByKey(pn, steps)
	if not o then return nil end
	
	for k,v in pairs(o) do
		o[k] = o[k]:GetScores()
	end
	
	return o
end

function getUsedRates(rtTable)
	local rates = {}
	local initIndex = 1 
	if rtTable ~= nil then
		for k,v in pairs(rtTable) do
			rates[#rates+1] = k
		end
		table.sort(rates,function(a,b) a=a:gsub("x","") b=b:gsub("x","") return a<b end)
		for i=1,#rates do
			if rates[i] == "1.0x" or rates[i] == "All" then
				initIndex = i
			end
		end
	end
	return rates,initIndex
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

