local t = Def.ActorFrame{};

--ohlookpso2stars
-- bit messy atm

local starsX = 10
local starsY = 250
local maxStars = 18
local starDistX = 20
local starDistY = 0
local starSize = 0.5
local playerDistY = 20


function stars(ind,pn)
	return LoadActor("ossstar")..{
		InitCommand=cmd(xy,starsX+35+(ind*starDistX),starsY+(ind*starDistY););
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
					self:sleep(ind/20);
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

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,starsX,starsY;halign,0;zoomto,384,20;diffuse,color("#000000");diffusealpha,0.6;);
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+8,starsY;zoom,0.7;);
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		local diff = 0;
		local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_1);
		if enabled then
			diff = GAMESTATE:GetCurrentSteps(PLAYER_1):GetMeter() or 0;
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


t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,starsX+8,starsY+playerDistY;zoom,0.7;);
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		local diff = 0;
		local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_2);
		if enabled then
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