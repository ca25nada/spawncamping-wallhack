-- Most of the scoretracking function calls and message broadcasting are done here.
local startFlag = false
local fcFlag = false
local fcFlagDelay = 0.5 -- Minimum delay after lastSecond before broadcasting FC message.
local firstSecond -- First Second of a song.
local lastSecond -- Last Second of a song.

local function Update(self)
	self.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end	
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
	end,
	-- Reset flags and first/last second at the beginning of each song.
	CurrentSongChangedMessageCommand = function(self)
		if GAMESTATE:GetCurrentSong() ~= nil then
			firstSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
			lastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()
		end
		startFlag = false
		fcFlag = false
	end
}


t[#t+1] = Def.Actor{
	JudgmentMessageCommand=function(self,params)
		
	end
}


return t