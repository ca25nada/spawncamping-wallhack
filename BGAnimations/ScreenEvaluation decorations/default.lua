addExtraQuotes()
local t = Def.ActorFrame{}

t[#t+1] = LoadActor("currenttime")
t[#t+1] = LoadActor("adefaultmoreripoff")

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,SCREEN_CENTER_X,135;zoom,0.4;maxwidth,400/0.4);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) 
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." // "..GAMESTATE:GetCurrentSong():GetDisplayArtist()) 
	end;
};

local function GraphDisplay( pn )
	local t = Def.ActorFrame {
		Def.GraphDisplay {
			InitCommand=cmd(Load,"GraphDisplay";);
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats();
				self:Set( ss, ss:GetPlayerStageStats(pn) );
				self:diffusealpha(0.7);
				self:GetChild("Line"):diffusealpha(0)
				if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)then
					self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35))
				end;
			end
		};
	};
	return t;
end

local function ComboGraph( pn )
	local t = Def.ActorFrame {
		Def.ComboGraph {
			InitCommand=cmd(Load,"ComboGraph"..ToEnumShortString(pn););
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats();
				self:Set( ss, ss:GetPlayerStageStats(pn) );
				if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
					self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35))
				end;
			end
		};
	};
	return t;
end;

--ScoreBoard
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

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+35,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Holds %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Holds"),pss:GetRadarPossible():GetValue("RadarCategory_Holds"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+105,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Rolls %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Rolls"),pss:GetRadarPossible():GetValue("RadarCategory_Rolls"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+175,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Mines %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Mines"),pss:GetRadarPossible():GetValue("RadarCategory_Mines"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+245,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Lifts %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Lifts"),pss:GetRadarPossible():GetValue("RadarCategory_Lifts"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+315,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Fakes %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Fakes"),pss:GetRadarPossible():GetValue("RadarCategory_Fakes"))
		end;
	};


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

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+35,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Holds %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Holds"),pss:GetRadarPossible():GetValue("RadarCategory_Holds"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+105,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Rolls %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Rolls"),pss:GetRadarPossible():GetValue("RadarCategory_Rolls"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+175,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Mines %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Mines"),pss:GetRadarPossible():GetValue("RadarCategory_Mines"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+245,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Lifts %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Lifts"),pss:GetRadarPossible():GetValue("RadarCategory_Lifts"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+315,frameY+210;zoom,0.35;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Fakes %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Fakes"),pss:GetRadarPossible():GetValue("RadarCategory_Fakes"))
		end;
	};

	return t
end;

if GAMESTATE:GetNumPlayersEnabled() >= 1 then
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		t[#t+1] = scoreBoard(PLAYER_1,0)
		if ShowStandardDecoration("GraphDisplay") then
			t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_1), GraphDisplay(PLAYER_1) )
		end;
		if ShowStandardDecoration("ComboGraph") then
			t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_1),ComboGraph(PLAYER_1) );
		end;
	elseif GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		t[#t+1] = scoreBoard(PLAYER_2,0)
		if ShowStandardDecoration("GraphDisplay") then
			t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_2), GraphDisplay(PLAYER_2) )
		end;
		if ShowStandardDecoration("ComboGraph") then
			t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_2),ComboGraph(PLAYER_2) );
		end;
	end;
end;
if GAMESTATE:GetNumPlayersEnabled() == 2 then
	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		t[#t+1] = scoreBoard(PLAYER_2,1)
		if ShowStandardDecoration("GraphDisplay") then
			t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_2), GraphDisplay(PLAYER_2) )
		end;
		if ShowStandardDecoration("ComboGraph") then
			t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_2),ComboGraph(PLAYER_2) );
		end;
	end;
end;

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-70;zoom,0.35;settext,getRandomQuotes();diffusealpha,0;zoomy,0;);
	BeginCommand=function(self)
		self:sleep(2)
		self:smooth(1)
		self:diffusealpha(0.7)
		self:zoomy(0.35)
	end;
};

return t