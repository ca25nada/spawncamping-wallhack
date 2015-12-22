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

--returns current autoplay type. returns a integer between 0~2 corresponding to
--human, autoplay and autoplay cpu respectively.
function getAutoplay()
	return Enum.Reverse(PlayerController)[tostring(PREFSMAN:GetPreference("AutoPlay"))]
end;

--returns true if windowed.
function isWindowed()
	return PREFSMAN:GetPreference("Windowed")
end;

--Recursively grabs the parents' position.
--dunno if it actually returns the correct position, but it works with my needs for now.
function getTrueX(element)
	if element == nil then
		return 0
	end;
	if element:GetParent() == nil then
		return element:GetX() or 0
	else
		return element:GetX()+getTrueX(element:GetParent())
	end;
end;

function getTrueY(element)
	if element == nil then
		return 0
	end;
	if element:GetParent() == nil then
		return element:GetY() or 0
	else
		return element:GetY()+getTrueY(element:GetParent())
	end;
end;

--Button Rollovers
function isOver(element)
	--[[
	if element:GetVisible() == false then
		return false
	end;
	--]]
	local x = getTrueX(element)
	local y = getTrueY(element)
	local hAlign = element:GetHAlign()
	local vAlign = element:GetVAlign()
	local w = element:GetZoomedWidth()
	local h = element:GetZoomedHeight()

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	local withinX = (mouseX >= (x-(hAlign*w))) and (mouseX <= ((x+w)-(hAlign*w)))
	local withinY = (mouseY >= (y-(vAlign*h))) and (mouseY <= ((y+h)-(vAlign*h)))

	return (withinX and withinY)
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

-- Ideally, i should just be checking simfile hashes and 
-- the simfile hashes when the highscore was made, but that's not an option rip-
-- Instead, check for player leaving prematurely, 
-- and the total notecount in score being different than the simfile notecount.
function isScoreValid(pn,steps,score)
	if score:GetGrade() == "Grade_Failed" then
		return true
	end
	if not (steps:GetRadarValues(pn):GetValue('RadarCategory_TapsAndHolds') == 
		(score:GetTapNoteScore('TapNoteScore_W1')+
		score:GetTapNoteScore('TapNoteScore_W2')+
		score:GetTapNoteScore('TapNoteScore_W3')+
		score:GetTapNoteScore('TapNoteScore_W4')+
		score:GetTapNoteScore('TapNoteScore_W5')+
		score:GetTapNoteScore('TapNoteScore_Miss'))) then
		return false
	end
	if ((score:GetTapNoteScore('TapNoteScore_Miss') == 0) and 
		((steps:GetRadarValues(pn):GetValue('RadarCategory_Holds')+(steps:GetRadarValues(pn):GetValue('RadarCategory_Rolls')) ~= 
		(score:GetHoldNoteScore('HoldNoteScore_LetGo')+score:GetHoldNoteScore('HoldNoteScore_Held')+score:GetHoldNoteScore('HoldNoteScore_MissedHold'))
		))) then 
		-- miss == 0 as HNS_MissedHold was added rather recently and NG+OK will not add up correctly for older scores.
		--where the player missed a note with a hold.
		return false
	end
	return true
end

-- No way of turn score saving off for just one player, so it will disqualify both players once called.
-- Doesn't work for some reason rip-
function disqualifyScore()
	local so = GAMESTATE:GetSongOptionsObject('ModsLevel_Song')
	if so:SaveScore() then
		so:SaveScore(false)
		SCREENMAN:SystemMessage("SaveScore set to false")
	else
		SCREENMAN:SystemMessage("SaveScore already set to false")
	end
end


function getNoteFieldWidth()
	local baseWidth = 64
	local style = GAMESTATE:GetCurrentStyle()
	local cols = style:ColumnsPerPlayer()

	return cols*64
end

function getNoteFieldPos(pn)
	local pNum = (pn == PLAYER_1) and 1 or 2
	local style = GAMESTATE:GetCurrentStyle()
	local cols = style:ColumnsPerPlayer()
	local styleType = ToEnumShortString(style:GetStyleType())
	local centered = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player"))

	if centered then 
		return SCREEN_CENTER_X
	else
		return THEME:GetMetric("ScreenGameplay",string.format("PlayerP%i%sX",pNum,styleType))
	end

end