t = Def.ActorFrame{}
resetJudgeST()

local JudgeTableP1 = {}
local JudgeTableP2 = {}


local paramP1
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	t[#t+1] = Def.Actor{
		SetCommand=function(self)
			local params = paramP1
			if params.Player == PLAYER_1 then
				if params.HoldNoteScore then
					addJudgeST(PLAYER_1,params.HoldNoteScore,true)
				elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
					addJudgeST(PLAYER_1,params.TapNoteScore,false)
				else
					addJudgeST(PLAYER_1,params.TapNoteScore,false)
					if params.TapNoteScore ~= 'TapNoteScore_Miss' then
						if not params.Early then
							addOffsetST(PLAYER_1,params.TapNoteOffset)
						else
							addOffsetST(PLAYER_1,params.TapNoteOffset)
						end;
					end;
				end;
			end;
		end;
		JudgmentMessageCommand=function(self,params)
			paramP1 = params
			self:queuecommand("Set");
		end;
	}
end;

local paramP2
if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = Def.Actor{
		SetCommand=function(self)
			local params = paramP2
			if params.Player == PLAYER_2 then
				if params.HoldNoteScore then
					addJudgeST(PLAYER_2,params.HoldNoteScore,true)
				elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
					addJudgeST(PLAYER_2,params.TapNoteScore,false)
				else
					addJudgeST(PLAYER_2,params.TapNoteScore,false)
					if params.TapNoteScore ~= 'TapNoteScore_Miss' then
						if not params.Early then
							addOffsetST(PLAYER_2,params.TapNoteOffset)
						else
							addOffsetST(PLAYER_2,params.TapNoteOffset)
						end;
					end;
				end;
			end;
		end;
		JudgmentMessageCommand=function(self,params)
			paramP2 = params
			self:queuecommand("Set");
		end;
	}
end;


t[#t+1] = LoadFont("Common Normal") .. { --testing
        InitCommand=cmd(xy,200,200;zoom,1;horizalign,left;diffuse,color("#000000"));
		BeginCommand=function(self)
			self:settext("")
		end;
		SetCommand=function(self)
			self:settext("")
		end;
		JudgmentMessageCommand=cmd(queuecommand,"Set")
}

return t