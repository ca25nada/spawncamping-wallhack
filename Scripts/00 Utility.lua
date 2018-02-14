--Random helper functions that don't really belong anywhere else.


function get43size(size4_3)
	return 640*(size4_3/854)
end;

function capWideScale(AR4_3,AR16_9)
	if AR4_3 < AR16_9 then
		return clamp(WideScale(AR4_3, AR16_9),AR4_3,AR16_9)
	else
		return clamp(WideScale(AR4_3, AR16_9),AR16_9,AR4_3)
	end;
end;

--returns if the table contains the key.
function tableContains(table,key)
	return (table[key] ~= nil)
end;

--for non-array tables.
function getTableSize(table)
	local i = 0
	for k,v in pairs(table) do
		i = i+1
	end;
	return i
end;

-- returns the hexadecimal representaion of the MD5 hash.
function MD5FileHex(sPath)
	local text = {}
	local MD5 = CRYPTMAN:MD5File(sPath)
	for i=1,#MD5 do
		text[i] = string.format("%02X",string.byte(MD5,i) or 0)
	end
	if #text == 16 then
		return table.concat(text)
	else
		return 0 --invalid
	end
end

-- returns the hexadecimal representation of the SHA-1 hash.
function SHA1FileHex(sPath)
	local text = {}
	local SHA1 = CRYPTMAN:SHA1File(sPath)
	for i=1,#SHA1 do
		text[i] = string.format("%02X",string.byte(SHA1,i) or 0)
	end
	if #text == 20 then
		return table.concat(text)
	else
		return 0 --invalid
	end
end

-- returns the hexadecimal representaion of the MD5 hash.
function MD5StringHex(str)
	local text = {}
	local MD5 = CRYPTMAN:MD5String(str)
	for i=1,#MD5 do
		text[i] = string.format("%02X",string.byte(MD5,i) or 0)
	end
	if #text == 16 then
		return table.concat(text)
	else
		return 0 --invalid
	end
end

-- returns the hexadecimal representation of the SHA-1 hash.
function SHA1StringHex(str)
	local text = {}
	local SHA1 = CRYPTMAN:SHA1String(str)
	for i=1,#SHA1 do
		text[i] = string.format("%02X",string.byte(SHA1,i) or 0)
	end
	if #text == 20 then
		return table.concat(text)
	else
		return 0 --invalid
	end
end

--Given a table of file paths/names in a fileList
--filters out files from fileList that isn't in the type in fileTypes
--both function parameters are passed on as tables
function filterFileList(fileList,fileTypes)
	local t = {}
	for i=1,#fileList do
		local add = false
		local s
		for _,v in pairs(fileTypes) do
			s = fileList[i]
			s = s:sub(-v:len())
			if s == v then
				add = true
			end
		end
		if add then
			table.insert(t,fileList[i])
		end	
	end
	return t
end

-- Just something to get rid of scores where the player quit out early.
function isScoreValid(pn,steps,score)
	return true
end


-- I probably should check for correctness later.
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

function getBPMChangeCount(bpms)
	local count = 0
	local threshhold = 5 -- get rid of ddreamspeed changes
	local curBPM = bpms[1][2]
	for k,v in ipairs(bpms) do
		if math.abs(curBPM - v[2]) > threshhold then
			count = count + 1
		end
		curBPM = v[2]
	end

	return count
end

-- from profile.lua in til death
function easyInputStringWithParams(question, maxLength, isPassword, f, params)
	SCREENMAN:AddNewScreenToTop("ScreenTextEntry");
	local settings = {
		Question = question,
		MaxInputLength = maxLength,
		Password = isPassword,
		OnOK = function(answer)
			f(answer, params)
		end
	};
	SCREENMAN:GetTopScreen():Load(settings);
end

function easyInputStringWithFunction(question, maxLength, isPassword, f)
	easyInputStringWithParams(question, maxLength, isPassword, function(answer, params) f(answer) end, {})
end

function easyInputString(question, maxLength, isPassword, tablewithvalue)
	easyInputStringWithParams(question, maxLength, isPassword, function(answer, params) tablewithvalue.inputString=answer end, {})
end