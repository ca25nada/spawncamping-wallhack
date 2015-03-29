local t = Def.ActorFrame{};

-- ohlookpso2stars
-- this became a mess rather quickly

local starsX = 10
local starsY = 208
local maxStars = 18
local starDistX = 18
local starDistY = 0
local starSize = 0.5
local playerDistY = 40


function stars(ind,pn)
	return LoadActor("ossstar")..{
		InitCommand=cmd(xy,starsX+43+(ind*starDistX),starsY+2+(ind*starDistY););
		SetCommand=function(self)
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


--1P


t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,starsX,starsY-18;zoomto,384,30;halign,0;valign,0;diffuse,color("#333333"));
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,starsX,starsY-18;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		self:diffuse(getClearType(PLAYER_1,2))
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(playcommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+13,starsY-12;zoom,0.3;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(PLAYER_1) ;
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
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(playcommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+379,starsY-12;zoom,0.3;halign,1);
	BeginCommand=function(self)
		self:settext("Player 1")
	end;
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+21,starsY+2;zoom,0.6;);
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		local diff = 0;
		local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_1);
		local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);

		if enabled and steps~= nil then
			diff = steps:GetMeter() or 0;
			self:settext(diff);
		else
			self:settext(0);
		end;
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
	PlayerJoinedMessageCommand=cmd(playcommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
};


------------------------------------------2P
t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,384,30;halign,0;valign,0;diffuse,color("#333333"));
};


t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		self:diffuse(getClearType(PLAYER_2,2))
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(playcommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
};


t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+13,starsY-12+playerDistY;zoom,0.3;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
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
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(playcommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+379,starsY-12+playerDistY;zoom,0.3;halign,1);
	BeginCommand=function(self)
		self:settext("Player 2")
	end;
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+21,starsY+playerDistY+2;zoom,0.6;);
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
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
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set");
	PlayerJoinedMessageCommand=cmd(playcommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
};

local index = 0
while index < maxStars do
	t[#t+1] = stars(index,PLAYER_1)
	t[#t+1] = stars(index,PLAYER_2)
	index = index + 1
end;


return t