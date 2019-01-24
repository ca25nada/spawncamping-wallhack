
-- **Very slight efficiency rewrites**
notShit = {}
function notShit.floor(x, y)
	y = 10^(y or 0)
	return math.floor(x*y)/y
end

function notShit.ceil(x, y)
	y = 10^(y or 0)
	return math.ceil(x*y)/y
end

-- seriously what is math and how does it work
function notShit.round(x, y)
	y = 10^(y or 0)
	return math.floor(x*y+0.5)/y
end

-- Grabs the currently selected rate as a string in the form of "r.rrx" while dropping trailing 0s
function getCurRateString()
	return string.format("%.2f", getCurRateValue()):gsub("%.?0+$", "").."x"
end

function getCurRateDisplayString()
	return getRateDisplayString(getCurRateString())
end

function getRateDisplayString(x)
	if x == "1x" then
		x = "1.0x"
	elseif x == "2x" then
		x = "2.0x"
	end
	return x.."Music"
end

function getCurRateValue()
  return notShit.round(GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate(),3)
end

function changeMusicRate(amount)
	local curRate = getCurRateValue()
	local newRate = curRate + amount
	if newRate <= 3 and newRate >= 0.7 then
		GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate(curRate+amount)
		GAMESTATE:GetSongOptionsObject('ModsLevel_Song'):MusicRate(curRate+amount)
		GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate(curRate+amount)
		MESSAGEMAN:Broadcast("CurrentRateChanged", {rate = newRate, oldRate = curRate})
	end
end