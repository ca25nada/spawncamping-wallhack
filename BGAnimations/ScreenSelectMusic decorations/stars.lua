local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 0 then
			self:queuecommand("On");
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

-- ohlookpso2stars
-- this became a mess rather quickly

local starsX = 10
local starsY = 230
local maxStars = 18
local starDistX = 23
local starDistY = 0
local starSize = 0.55
local playerDistY = 95
local frameWidth = 455

local song

local stepsP1
local stepsP2

local profileP1
local profileP2

local topScoreP1
local topScoreP2

function stars(ind,pn)
	return LoadActor("ossstar")..{
		InitCommand=cmd(xy,starsX+43+(ind*starDistX),starsY+2+(ind*starDistY););
		SetCommand=function(self)
			if update then
				local diff = 0;
				local steps = GAMESTATE:GetCurrentSteps(pn);
				local enabled = GAMESTATE:IsPlayerEnabled(pn);
				self:finishtweening();
				self:stopeffect();
				if enabled and pn == PLAYER_2 then
					self:y(starsY+(ind*starDistY)+playerDistY);
				end;
				if enabled and steps ~= nil then
					diff = steps:GetMeter() or 0;
					self:visible(true);
					self:zoom(0);
					self:rotationz(0);
					if ind < 3 then
						self:diffuse(getVividDifficultyColor('Difficulty_Beginner'))
					elseif ind < 6 then
						self:diffuse(getVividDifficultyColor('Difficulty_Easy'))
					elseif ind < 9 then
						self:diffuse(getVividDifficultyColor('Difficulty_Medium'))
					elseif ind < 12 then
						self:diffuse(getVividDifficultyColor('Difficulty_Hard'))
					elseif ind < 15 then
						self:diffuseshift()
						self:effectcolor1(color("#eeddff"))
						self:effectcolor2(color("#EE82EE"))
						self:effectperiod(2)
					else
						self:diffuse(color("#FFFFFF"))
						self:effectcolor1(color("#FFFFFF"))
						self:effectcolor2(color('Difficulty_Challenge'))
						self:glowshift()
						self:effectperiod(0.5)
					end;
					if ind < diff then
						self:sleep((ind/math.min(diff,maxStars))/2);
						self:decelerate(0.5);
						self:zoom(starSize);
						self:rotationz(360);
					else
						self:visible(false);
					end;
				else
					self:visible(false);
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentStepsP1ChangedMessageCommand=function(self)
			if pn == PLAYER_1 then
				self:playcommand("Set")
			end;
		end;
		CurrentStepsP2ChangedMessageCommand=function(self)
			if pn == PLAYER_2 then
				self:playcommand("Set")
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Set")
			end;
		end;
		PlayerUnjoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:visible(false);
			end;
		end;
	};
end;



--Things i need: 
-- Grades, Clearlamp, 3 scores, max score 
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

--1P

t[#t+1] = Def.ActorFrame{
	BeginCommand=function(self)
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
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
	--Upper Bar
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18;zoomto,frameWidth,30;halign,0;valign,0;diffuse,color("#333333"));
	};
	--Lower Bar
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY+18;zoomto,frameWidth,50;halign,0;valign,0;diffuse,color("#333333"));
	};

	--===Upper Bar Stuff===--

	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:diffuse(getClearType(PLAYER_1,2))
			end
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+13,starsY-12;zoom,0.3;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local diff;
				local stype;
				if stepsP1 ~= nil then
					diff = getDifficulty(stepsP1:GetDifficulty())
					stype = ToEnumShortString(stepsP1:GetStepsType()):gsub("%_"," ")
					self:settext(stype.." "..diff);
				else
					self:settext("Disabled");
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+frameWidth-5,starsY-12;zoom,0.3;halign,1);
		BeginCommand=function(self)
			self:settext("Player 1")
		end;
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+21,starsY+2;zoom,0.6;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local diff = 0;
				local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_1);
				if enabled and stepsP1 ~= nil then
					diff = stepsP1:GetMeter() or 0;
					self:settext(diff);
				else
					self:settext(0);
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	--===Lower Bar Stuff===--

	--Grades
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,starsX+60,starsY+35;zoom,0.6;maxwidth,110/0.6);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(getGradeStrings(getScoreGradeP1()))
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--ClearType
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+60,starsY+58;zoom,0.5;maxwidth,110/0.5);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(getClearType(PLAYER_1,0))
			self:diffuse(getClearType(PLAYER_1,2))
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	-- Percentage Score
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,starsX+195,starsY+30;zoom,0.45;halign,1;maxwidth,75/0.45);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local score = getScoreP1(0)
			local maxscore = getMaxScoreP1(0)
			if maxscore == 0 or maxscore == nil then
				maxscore = 1
			end;
			local pscore = (score/maxscore) * 100

			self:settextf("%05.2f%%",pscore)
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--Player DP/Exscore / Max DP/Exscore
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+182,starsY+48;zoom,0.5;halign,1;maxwidth,60/0.5);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local score = string.format("%04d",getScoreP1(0))
			local maxscore = string.format("%04d",getMaxScoreP1(0))
			self:settext(score.."/"..maxscore)
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--ScoreType superscript(?)
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+183,starsY+47;zoom,0.3;halign,0;);
		BeginCommand=function(self)
			self:settext(getScoreTypeText(0))
		end;
	};
	LoadActor("bargraph");
};

------------------------------------------2P
t[#t+1] = Def.ActorFrame{
	BeginCommand=function(self)
		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
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
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,frameWidth,30;halign,0;valign,0;diffuse,color("#333333"));
	};

	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			if update then
				self:diffuse(getClearType(PLAYER_2,2))
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		PlayerJoinedMessageCommand=cmd(playcommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
	};


	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+13,starsY-12+playerDistY;zoom,0.3;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local steps = GAMESTATE:GetCurrentSteps(PLAYER_2) ;
				local diff;
				local stype;
				if steps ~= nil then
					diff = getDifficulty(steps:GetDifficulty())
					stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
					self:settext(stype.." "..diff);
				else
					self:settext("Disabled");
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
		PlayerJoinedMessageCommand=cmd(playcommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+382,starsY-12+playerDistY;zoom,0.3;halign,1);
		BeginCommand=function(self)
			self:settext("Player 2")
		end;
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+21,starsY+playerDistY+2;zoom,0.6;);
		BeginCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			if update then
				local diff = 0;
				local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_2);
				local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
				if enabled and steps~= nil then
					diff = GAMESTATE:GetCurrentSteps(PLAYER_2):GetMeter() or 0;
					self:settext(diff);
				else
					self:settext(0);
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set");
		PlayerJoinedMessageCommand=cmd(playcommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
	};
};
local index = 0
while index < maxStars do
	t[#t+1] = stars(index,PLAYER_1)
	t[#t+1] = stars(index,PLAYER_2)
	index = index + 1
end;


return t