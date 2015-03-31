t = Def.ActorFrame{}

barXP1 = 157
barYP1 = 290
barWidth =300
barHeight = 4
showLetters = false

t[#t+1] = Def.Actor{
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		song = GAMESTATE:GetCurrentSong()
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
			stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
		end;
		initScoreListP1()
		initScoreP1(1)
		initJudgeStatsP1()
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
}


t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,barXP1-2,barYP1;zoom,0.30;halign,1);
	BeginCommand=cmd(settext,"Judge:");
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0;diffuse,color("#000000"););
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local notes = getMaxNotesP1()
		local judge = getJudgeStatsCountP1("TapNoteScore_W1")+
			getJudgeStatsCountP1("TapNoteScore_W2") + 
			getJudgeStatsCountP1("TapNoteScore_W3") +
			getJudgeStatsCountP1("TapNoteScore_W4") +
			getJudgeStatsCountP1("TapNoteScore_W5") +
			getJudgeStatsCountP1("TapNoteScore_Miss")
		if maxscore == 0 or maxscore == nil then
			maxscore = 1
		end;
		self:zoomx(0)
		self:sleep(0.5)
		self:smooth(1)
		self:diffuse(TapNoteScoreToColor("TapNoteScore_Miss"))
		self:zoomx((judge/notes)*barWidth)
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local notes = getMaxNotesP1()
		local judge = getJudgeStatsCountP1("TapNoteScore_W1")+
			getJudgeStatsCountP1("TapNoteScore_W2") + 
			getJudgeStatsCountP1("TapNoteScore_W3") +
			getJudgeStatsCountP1("TapNoteScore_W4") +
			getJudgeStatsCountP1("TapNoteScore_W5")
		if maxscore == 0 or maxscore == nil then
			maxscore = 1
		end;
		self:zoomx(0)
		self:sleep(0.5)
		self:smooth(1)
		self:diffuse(TapNoteScoreToColor("TapNoteScore_W5"))
		self:zoomx((judge/notes)*barWidth)
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local notes = getMaxNotesP1()
		local judge = getJudgeStatsCountP1("TapNoteScore_W1")+
			getJudgeStatsCountP1("TapNoteScore_W2") + 
			getJudgeStatsCountP1("TapNoteScore_W3") +
			getJudgeStatsCountP1("TapNoteScore_W4")
		if maxscore == 0 or maxscore == nil then
			maxscore = 1
		end;
		self:zoomx(0)
		self:sleep(0.5)
		self:smooth(1)
		self:diffuse(TapNoteScoreToColor("TapNoteScore_W4"))
		self:zoomx((judge/notes)*barWidth)
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local notes = getMaxNotesP1()
		local judge = getJudgeStatsCountP1("TapNoteScore_W1")+
			getJudgeStatsCountP1("TapNoteScore_W2") + 
			getJudgeStatsCountP1("TapNoteScore_W3")
		if maxscore == 0 or maxscore == nil then
			maxscore = 1
		end;
		self:zoomx(0)
		self:sleep(0.5)
		self:smooth(1)
		self:diffuse(TapNoteScoreToColor("TapNoteScore_W3"))
		self:zoomx((judge/notes)*barWidth)
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local notes = getMaxNotesP1()
		local judge = getJudgeStatsCountP1("TapNoteScore_W1")+
			getJudgeStatsCountP1("TapNoteScore_W2")
		if maxscore == 0 or maxscore == nil then
			maxscore = 1
		end;
		self:zoomx(0)
		self:sleep(0.5)
		self:smooth(1)
		self:diffuse(TapNoteScoreToColor("TapNoteScore_W2"))
		self:zoomx((judge/notes)*barWidth)
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local notes = getMaxNotesP1()
		local judge = getJudgeStatsCountP1("TapNoteScore_W1")
		if maxscore == 0 or maxscore == nil then
			maxscore = 1
		end;
		self:zoomx(0)
		self:sleep(0.5)
		self:smooth(1)
		self:diffuse(getMainColor(3))
		self:zoomx((judge/notes)*barWidth)
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:stoptweening()
		self:queuecommand("Set")
	end;
};





return t