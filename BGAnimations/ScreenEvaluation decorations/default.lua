t = Def.ActorFrame{}

t[#t+1] = LoadActor("currenttime")
t[#t+1] = LoadActor("adefaultmoreripoff")

local pssP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)

local frameX = 20
local frameY = 150
local frameWidth = SCREEN_CENTER_X-60

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX-5,frameY;zoomto,frameWidth+10,220;halign,0;valign,0;diffuse,color("#333333"););
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY+40;zoomto,frameWidth,2;halign,0;)
};

t[#t+1] = LoadFont("Common Large")..{
	InitCommand=cmd(xy,frameX+45,frameY+20;zoom,0.8;maxwidth,70/0.8);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) self:settext(getGradeStrings(pssP1:GetGrade())) end;
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+85,frameY+15;zoom,0.50;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) 
		local score = getCurScoreST(PLAYER_1,0)
		local maxScore = getMaxScoreST(PLAYER_1,0)
		local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
		self:settextf("%s %d/%d",percentText,score,maxScore)
		end;
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+85,frameY+28;zoom,0.50;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) 
		local score = pssP1:GetHighScore();
		if score ~= nil then
			self:settext(getClearTypeFromScore(PLAYER_1,score,0)); 
			self:diffuse(getClearTypeFromScore(PLAYER_1,score,2))
		end;
	end;
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+frameWidth,frameY+37;zoom,0.35;halign,1;valign,1);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) 
		local stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
		local diff = getDifficulty(stepsP1:GetDifficulty())
		local stype = ToEnumShortString(stepsP1:GetStepsType()):gsub("%_"," ")
		local meter = stepsP1:GetMeter()
		self:settext(stype.." "..diff.." "..meter)
		self:diffuse(getDifficultyColor(diff))
	end;
};
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+10,frameY+65;zoom,0.40;halign,0;maxwidth,frameWidth/0.4);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) 
		self:settext(pssP1:GetHighScore():GetModifiers())
	end;
};

local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}
for k,v in ipairs(judges) do
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY+80+((k-1)*22);zoomto,frameWidth,18;halign,0;diffuse,TapNoteScoreToColor(v);diffusealpha,0.5;);
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+10,frameY+80+((k-1)*22);zoom,0.50;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(getJudgeStrings(v))
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth-40,frameY+80+((k-1)*22);zoom,0.50;halign,1);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(pssP1:GetTapNoteScores(v))
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth-38,frameY+80+((k-1)*22);zoom,0.30;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("(%03.2f%%)",pssP1:GetPercentageOfTaps(v)*100)
		end;
	};
end;





return t