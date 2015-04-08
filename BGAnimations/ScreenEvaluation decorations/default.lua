local t = Def.ActorFrame{}

t[#t+1] = LoadActor("currenttime")
t[#t+1] = LoadActor("adefaultmoreripoff")

local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}

local pssP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local pssP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2)

local frameX = 20
local frameY = 150
local frameWidth = SCREEN_CENTER_X-60

function scoreBoard(pn,position)
	local t = Def.ActorFrame{
		BeginCommand=function(self)
			if position == 1 then
				self:x(SCREEN_WIDTH-(frameX*2)-frameWidth)
			end;
		end;
	}

	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX-5,frameY;zoomto,frameWidth+10,220;halign,0;valign,0;diffuse,color("#333333"););
	};

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY+40;zoomto,frameWidth,2;halign,0;)
	};

	t[#t+1] = LoadFont("Common Large")..{
		InitCommand=cmd(xy,frameX+45,frameY+20;zoom,0.8;maxwidth,70/0.8);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(THEME:GetString("Grade",ToEnumShortString(pss:GetGrade()))) 
			self:diffuse(getGradeColor(pss:GetGrade()))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+85,frameY+15;zoom,0.50;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = getCurScoreST(pn,0)
			local maxScore = getMaxScoreST(pn,0)
			local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
			self:settextf("%s %d/%d",percentText,score,maxScore)
			end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+85,frameY+28;zoom,0.50;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = pss:GetHighScore();
			if score ~= nil then
				self:settext(getClearTypeFromScore(pn,score,0)); 
				self:diffuse(getClearTypeFromScore(pn,score,2))
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth,frameY+37;zoom,0.35;halign,1;valign,1);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local steps = GAMESTATE:GetCurrentSteps(pn)
			local diff = getDifficulty(steps:GetDifficulty())
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = steps:GetMeter()
			self:settext(stype.." "..diff.." "..meter)
			self:diffuse(getDifficultyColor(diff))
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+10,frameY+65;zoom,0.40;halign,0;maxwidth,frameWidth/0.4);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(pss:GetHighScore():GetModifiers())
		end;
	};

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
				self:settext(pss:GetTapNoteScores(v))
			end;
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+frameWidth-38,frameY+80+((k-1)*22);zoom,0.30;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self) 
				self:settextf("(%03.2f%%)",pss:GetPercentageOfTaps(v)*100)
			end;
		};
	end;

	return t
end;

function rightScoreBoard(pn)
	local t = Def.ActorFrame{}

	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX-5,frameY;zoomto,frameWidth+10,220;halign,0;valign,0;diffuse,color("#333333"););
	};

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY+40;zoomto,frameWidth,2;halign,0;)
	};

	t[#t+1] = LoadFont("Common Large")..{
		InitCommand=cmd(xy,frameX+45,frameY+20;zoom,0.8;maxwidth,70/0.8);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(THEME:GetString("Grade",ToEnumShortString(pss:GetGrade()))) 
			self:diffuse(getGradeColor(pss:GetGrade()))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+85,frameY+15;zoom,0.50;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = getCurScoreST(pn,0)
			local maxScore = getMaxScoreST(pn,0)
			local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
			self:settextf("%s %d/%d",percentText,score,maxScore)
			end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+85,frameY+28;zoom,0.50;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = pss:GetHighScore();
			if score ~= nil then
				self:settext(getClearTypeFromScore(pn,score,0)); 
				self:diffuse(getClearTypeFromScore(pn,score,2))
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth,frameY+37;zoom,0.35;halign,1;valign,1);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local steps = GAMESTATE:GetCurrentSteps(pn)
			local diff = getDifficulty(steps:GetDifficulty())
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = steps:GetMeter()
			self:settext(stype.." "..diff.." "..meter)
			self:diffuse(getDifficultyColor(diff))
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+10,frameY+65;zoom,0.40;halign,0;maxwidth,frameWidth/0.4);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(pss:GetHighScore():GetModifiers())
		end;
	};

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
				self:settext(pss:GetTapNoteScores(v))
			end;
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+frameWidth-38,frameY+80+((k-1)*22);zoom,0.30;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self) 
				self:settextf("(%03.2f%%)",pss:GetPercentageOfTaps(v)*100)
			end;
		};
	end;

	return t
end;

if GAMESTATE:GetNumPlayersEnabled() >= 1 then
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		t[#t+1] = scoreBoard(PLAYER_1,0)
	elseif GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		t[#t+1] = scoreBoard(PLAYER_2,0)
	end;
end;

if GAMESTATE:GetNumPlayersEnabled() == 2 then
	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		t[#t+1] = scoreBoard(PLAYER_2,1)
	end;
end;

return t