t = Def.ActorFrame{}

local barXP1 = 157
local barYP1 = 170+capWideScale(get43size(120),120)

local playerDistY = 95

local barXP2 = 157
local barYP2 = barYP1+playerDistY


local barWidth = capWideScale(get43size(300),300)-(barXP1-capWideScale(get43size(barXP1),barXP1))
local barHeight = 4
local showLetters = false
local animationDelay = 0.8
local animationLength = 1


t[#t+1] = Def.Actor{
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		song = GAMESTATE:GetCurrentSong()
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
			stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
		end;
		initScoreList(PLAYER_1)
		initScore(PLAYER_1,1)
		initJudgeStats(PLAYER_1)
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
}

t[#t+1] = Def.ActorFrame{
	BeginCommand=function(self)
		if GAMESTATE:IsHumanPlayer(PLAYER_1) then
			self:visible(true)
		else
			self:visible(false)
		end;
	end;
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_1 then
			self:visible(true);
		end;
	end;
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_1 then
			self:visible(false);
		end;
	end;
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,barXP1-2,barYP1;zoom,0.30;halign,1);
		BeginCommand=cmd(settext,"Judge:");
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0;diffuse,color("#000000"););
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_1)
			local judge = getJudgeStatsCount(PLAYER_1,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W3") +
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W4") +
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W5") +
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_Miss")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_1)
			local judge = getJudgeStatsCount(PLAYER_1,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W3") +
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W4") +
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W5")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_1)
			local judge = getJudgeStatsCount(PLAYER_1,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W3") +
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W4")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};
	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_1)
			local judge = getJudgeStatsCount(PLAYER_1,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W3")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_1)
			local judge = getJudgeStatsCount(PLAYER_1,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_1,"TapNoteScore_W2")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP1,barYP1;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(glowshift;effectcolor1,color("1,1,1,0.325");effectcolor2,color("1,1,1,0");queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_1)
			local judge = getJudgeStatsCount(PLAYER_1,"TapNoteScore_W1")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
};

t[#t+1] = Def.ActorFrame{
	BeginCommand=function(self)
		if GAMESTATE:IsHumanPlayer(PLAYER_2) then
			self:visible(true)
		else
			self:visible(false)
		end;
	end;
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_2 then
			self:visible(true);
		end;
	end;
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_2 then
			self:visible(false);
		end;
	end;
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,barXP2-2,barYP2;zoom,0.30;halign,1);
		BeginCommand=cmd(settext,"Judge:");
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0;diffuse,color("#000000"););
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_2)
			local judge = getJudgeStatsCount(PLAYER_2,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W3") +
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W4") +
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W5") +
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_Miss")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_2)
			local judge = getJudgeStatsCount(PLAYER_2,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W3") +
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W4") +
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W5")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_2)
			local judge = getJudgeStatsCount(PLAYER_2,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W3") +
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W4")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};
	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_2)
			local judge = getJudgeStatsCount(PLAYER_2,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W2") + 
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W3")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_2)
			local judge = getJudgeStatsCount(PLAYER_2,"TapNoteScore_W1")+
				getJudgeStatsCount(PLAYER_2,"TapNoteScore_W2")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
	};

	Def.Quad{
		InitCommand=cmd(xy,barXP2,barYP2;zoomto,barWidth,barHeight;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local notes = getMaxNotes(PLAYER_2)
			local judge = getJudgeStatsCount(PLAYER_2,"TapNoteScore_W1")
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			self:zoomx(0)
			self:sleep(animationDelay)
			self:smooth(animationLength)
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
};



return t