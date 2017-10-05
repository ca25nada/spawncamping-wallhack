-- Most of the scoretracking function calls and message broadcasting are done here.

local bareBone = isBareBone()
local startFlag = false
local fcFlag = false
local fcFlagDelay = 0.5 -- Minimum delay after lastSecond before broadcasting FC message.
local firstSecond -- First Second of a song.
local lastSecond -- Last Second of a song.

local ghostDataUpdateDelay = 0.01
local ghostDataLastUpdate = 0

--[[
for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	setCurExp(pn) -- Save current exp for each player for comparison after gameplay.

	-- Ignore ghostdata stuff for course mode.
	if GAMESTATE:IsCourseMode() then
		break
	end

	local origTable
	local rtTable
	local hsTable
	if themeConfig:get_data().global.RateSort then
		origTable = getScoreList(pn)
		rtTable = getRateTable(origTable)
		hsTable = sortScore(rtTable[getCurRate()] or {},ghostType)
	else
		origTable = getScoreList(pn)
		hsTable = sortScore(origTable,ghostType)
	end
	readGhostData(pn,hsTable[1]) -- Read ghost data.
end
--]]

local function Update(self)
	self.InitCommand=cmd(SetUpdateFunction,Update)
	local curSecond = GAMESTATE:GetSongPosition():GetMusicSeconds()
	GHETTOGAMESTATE:setLastPlayedSecond(curSecond) -- For preview music when exiting midway.

	if not startFlag and (firstSecond-curSecond < 2 or curSecond > 1) then
        MESSAGEMAN:Broadcast("SongStarting")
        startFlag = true
    end

    if not fcFlag and curSecond > lastSecond+fcFlagDelay then
    	for _,v in pairs(GAMESTATE:GetEnabledPlayers()) do
	    	-- FC CHECK
	    end
	    fcFlag = true
    end

end


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:SetUpdateFunction(Update)
	end;
	-- Reset flags and first/last second at the beginning of each song.
	CurrentSongChangedMessageCommand = function(self)
		firstSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
		lastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()
		startFlag = false
		fcFlag = false
	end
}


t[#t+1] = Def.Actor{
	JudgmentMessageCommand=function(self,params)
		
	end
}


return t