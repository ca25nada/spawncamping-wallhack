--Random helper functions that don't really belong anywhere else.

-- check for correctness later.
function getCommonBPM(bpms,lastBeat)
	local BPMtable = {}
	local curBPM = math.round(bpms[1][2])
	local curBeat = bpms[1][1]
	for _,v in ipairs(bpms) do
		if BPMtable[tostring(curBPM)] == nil then
			BPMtable[tostring(curBPM)] = (v[1] - curBeat)/curBPM
		else
			BPMtable[tostring(curBPM)] = BPMtable[tostring(curBPM)] + (v[1] - curBeat)/curBPM
		end
		curBPM = math.round(v[2])
		curBeat = v[1]
	end

	if BPMtable[tostring(curBPM)] == nil then
		BPMtable[tostring(curBPM)] = (lastBeat - curBeat)/curBPM
	else
		BPMtable[tostring(curBPM)] = BPMtable[tostring(curBPM)] + (lastBeat - curBeat)/curBPM
	end

	local maxBPM = 0
	local maxDur = 0
	for k,v in pairs(BPMtable) do
		if v > maxDur then
			maxDur = v
			maxBPM = tonumber(k)
		end
	end
	return maxBPM * GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate()
end

-- from profile.lua in til death
function easyInputStringWithParams(question, maxLength, isPassword, f, params)
	SCREENMAN:AddNewScreenToTop("ScreenTextEntry")
	local settings = {
		Question = question,
		MaxInputLength = maxLength,
		Password = isPassword,
		OnOK = function(answer)
			f(answer, params)
		end
	}
	SCREENMAN:GetTopScreen():Load(settings)
end

function easyInputStringWithFunction(question, maxLength, isPassword, f)
	easyInputStringWithParams(question, maxLength, isPassword, function(answer, params) f(answer) end, {})
end

function easyInputString(question, maxLength, isPassword, tablewithvalue)
	easyInputStringWithParams(question, maxLength, isPassword, function(answer, params) tablewithvalue.inputString=answer end, {})
end

-- Overload the function in 02 Utilities.lua with the one in the current SM repository.
-- Because the one currently in etterna is dumb.
function IsUsingWideScreen()
	local curAspect = GetScreenAspectRatio()
	if math.abs(curAspect-16/9) <= .044 or math.abs(curAspect - 16/10) <= .044 then
		return true
	else
		return false
	end
end