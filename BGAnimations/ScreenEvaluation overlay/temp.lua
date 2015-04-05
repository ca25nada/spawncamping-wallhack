--Temp Eval Screen 
t = Def.ActorFrame{};

local judgeStatsP1 = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	HoldNoteScore_Held = 0,
	TapNoteScore_HitMine = 0,
	HoldNoteScore_LetGo = 0,
	HoldNoteScore_MissedHold = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
}

local judgeStatsP2 = { -- Table containing the # of judgements made so far
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 0,
	TapNoteScore_W3 = 0,
	TapNoteScore_W4 = 0,
	TapNoteScore_W5 = 0,
	TapNoteScore_Miss = 0,
	HoldNoteScore_Held = 0,
	TapNoteScore_HitMine = 0,
	HoldNoteScore_LetGo = 0,
	HoldNoteScore_MissedHold = 0,
	TapNoteScore_AvoidMine		= 0,
	TapNoteScore_CheckpointHit		= 0,
	TapNoteScore_CheckpointMiss 	= 0,
}
local temptextP1 = "PLAYER1 \n"
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	for k,_ in pairs(judgeStatsP1) do
		if k == "HoldNoteScore_LetGo" or k == "HoldNoteScore_Held" or k == "HoldNoteScore_MissedHold" then
			judgeStatsP1[k] = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetHoldNoteScores(k)
		else
			judgeStatsP1[k] = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetTapNoteScores(k)
		end;
		temptextP1 = temptextP1..k..":"..judgeStatsP1[k].."\n" 
	end;
end;

local temptextP2 = "PLAYER2 \n"
if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	for k,_ in pairs(judgeStatsP2) do
		if k == "HoldNoteScore_LetGo" or k == "HoldNoteScore_Held" or k == "HoldNoteScore_MissedHold" then
			judgeStatsP1[k] = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetHoldNoteScores(k)
		else
			judgeStatsP1[k] = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetTapNoteScores(k)
		end;
		temptextP2 = temptextP2..k..":"..judgeStatsP2[k].."\n" 
	end;
end;
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,10,60;settext,temptextP1;halign,0;valign,0;zoom,0.35;);
};
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,300,60;settext,temptextP2;halign,0;valign,0;zoom,0.35;);
};


return t