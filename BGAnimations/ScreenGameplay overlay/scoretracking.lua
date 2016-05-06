-- Most of the scoretracking function calls and message broadcasting are done here.


resetJudgeST() -- Reset scoretracking data.
resetGhostData() -- Reset ghostscore data.

local startFlag = false
local fcFlag = false
local fcFlagDelay = 0.1
local firstSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
local lastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	
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


local function Update(self)
	self.InitCommand=cmd(SetUpdateFunction,Update)
	local curSecond = GAMESTATE:GetSongPosition():GetMusicSeconds()

	setLastSecond(curSecond)

	if not startFlag and (firstSecond-curSecond < 2 or curSecond > 3) then
        MESSAGEMAN:Broadcast("SongStarting")
        startFlag = true
    end

    if not fcFlag and curSecond > lastSecond+fcFlagDelay then
    	for _,v in pairs(GAMESTATE:GetEnabledPlayers()) do
	    	if isFullCombo(v) then
	    		MESSAGEMAN:Broadcast("FullCombo",{pn = v})
	    	end
	    end
	    fcFlag = true
    end

end


local t = Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end
}


t[#t+1] = Def.Actor{
	JudgmentMessageCommand=function(self,params)

		popGhostData(params.Player)
		MESSAGEMAN:Broadcast('GhostScore')
		if getAutoplay() == 1 then
			if params.HoldNoteScore then
				addJudgeGD(params.Player,'HoldNoteScore_None',true)
			else
				addJudgeGD(params.Player,'TapNoteScore_None',false)
			end
			return
		end

		local songPosition = GAMESTATE:GetSongPosition():GetMusicSeconds()
		if params.HoldNoteScore then -- Hold/Rolls
			addJudgeST(params.Player,params.HoldNoteScore,true)
			addJudgeGD(params.Player,params.HoldNoteScore,true)
		elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then -- Mines
			addJudgeST(params.Player,params.TapNoteScore,false)
			addJudgeGD(params.Player,params.TapNoteScore,false)
		else -- Rest should be taps.
			addJudgeST(params.Player,params.TapNoteScore,false)
			addJudgeGD(params.Player,params.TapNoteScore,false)
			if params.TapNoteScore ~= 'TapNoteScore_Miss' then -- Add timing offset if it's not a miss
				addOffsetST(params.Player,params.TapNoteOffset)
			end
		end;
	end;
}


return t