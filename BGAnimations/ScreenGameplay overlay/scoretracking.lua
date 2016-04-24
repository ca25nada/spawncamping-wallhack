resetJudgeST() -- Reset scoretracking data.
resetGhostData() -- Reset ghostscore data.
readGhostData(PLAYER_1)
local i = 0
local started = false
local function Update(self)
	self.InitCommand=cmd(SetUpdateFunction,Update)
	local songPosition = GAMESTATE:GetSongPosition():GetMusicSeconds()
	setLastSecond(songPosition)

	if (GAMESTATE:GetCurrentSong():GetFirstSecond()-songPosition < 2 or songPosition > 3) and not started then
        MESSAGEMAN:Broadcast("SongStarting")
        started = true
    end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end;
}

if GAMESTATE:GetNumPlayersEnabled() >= 1 then
	t[#t+1] = Def.Actor{
		JudgmentMessageCommand=function(self,params)
			i = i+1
			local data = popGhostData(params.Player)
			MESSAGEMAN:Broadcast('GhostScore')
			--SCREENMAN:SystemMessage(i)
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
end;


return t