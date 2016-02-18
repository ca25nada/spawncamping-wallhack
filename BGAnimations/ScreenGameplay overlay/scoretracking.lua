t = Def.ActorFrame{}
resetJudgeST()

local JudgeTableP1 = {}
local JudgeTableP2 = {}


if GAMESTATE:IsPlayerEnabled(PLAYER_1) or GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = Def.Actor{
		JudgmentMessageCommand=function(self,params)
			if params.Player == PLAYER_1 then
				if params.HoldNoteScore then
					addJudgeST(PLAYER_1,params.HoldNoteScore,true)
				elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
					addJudgeST(PLAYER_1,params.TapNoteScore,false)
				else
					addJudgeST(PLAYER_1,params.TapNoteScore,false)
					if params.TapNoteScore ~= 'TapNoteScore_Miss' then
						addOffsetST(PLAYER_1,params.TapNoteOffset)
					end;
				end;
			end;
			if params.Player == PLAYER_2 then
				if params.HoldNoteScore then
					addJudgeST(PLAYER_2,params.HoldNoteScore,true)
				elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
					addJudgeST(PLAYER_2,params.TapNoteScore,false)
				else
					addJudgeST(PLAYER_2,params.TapNoteScore,false)
					if params.TapNoteScore ~= 'TapNoteScore_Miss' then
						addOffsetST(PLAYER_2,params.TapNoteOffset)
					end;
				end;
			end;
		end;
	}
end;

return t