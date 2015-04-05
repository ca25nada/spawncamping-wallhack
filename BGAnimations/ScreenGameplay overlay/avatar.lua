--avatars should work minus in the case when a 2nd player joins midway, because i have no idea how to re-load the image.

local t = Def.ActorFrame{};

local profileP1
local profileP2

local profileNameP1 = "No Profile"
local playCountP1 = 0
local playTimeP1 = 0
local noteCountP1 = 0

local profileNameP2 = "No Profile"
local playCountP2 = 0
local playTimeP2 = 0
local noteCountP2 = 0


local AvatarXP1 = 0
local AvatarYP1 = SCREEN_HEIGHT-50
local AvatarXP2 = SCREEN_WIDTH-50
local AvatarYP2 = SCREEN_HEIGHT-50

-- P1 Avatar
t[#t+1] = Def.Actor{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
			if profileP1 ~= nil then
				profileNameP1 = profileP1:GetDisplayName()
				playCountP1 = profileP1:GetTotalNumSongsPlayed()
				playTimeP1 = profileP1:GetTotalSessionSeconds()
				noteCountP1 = profileP1:GetTotalTapsAndHolds()
			else 
				profileNameP1 = "Machine Profile"
				playCountP1 = 0
				playTimeP1 = 0
				noteCountP1 = 0
			end; 
			if profileNameP1 == "" then 
				profileNameP1 = "Machine Profile"
			end;
		else
			profileNameP1 = "No Player"
			playCountP1 = 0
			playTimeP1 = 0
			noteCountP1 = 0
		end;
	end;
}

-- P2 Avatar
t[#t+1] = Def.Actor{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			profileP2 = GetPlayerOrMachineProfile(PLAYER_2)
			if profileP2 ~= nil then
				profileNameP2 = profileP2:GetDisplayName()
				playCountP2 = profileP2:GetTotalNumSongsPlayed()
				playTimeP2 = profileP2:GetTotalSessionSeconds()
				noteCountP2 = profileP2:GetTotalTapsAndHolds()
			else 
				profileNameP2 = "Machine Profile"
				playCountP2 = 0
				playTimeP2 = 0
				noteCountP2 = 0
			end;
			if profileNameP2 == "" then 
				profileNameP2 = "Machine Profile"
			end;
		else
			profileNameP2 = "No Player"
			playCountP2 = 0
			playTimeP2 = 0
			noteCountP2 = 0
		end;
	end;
}

-- P1
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	t[#t+1] = Def.ActorFrame{
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if profileP1 == nil then
				self:visible(false)
			else
				self:visible(true)
			end;
		end;
		Def.Quad {
			InitCommand = cmd(halign,0;valign,0;xy,AvatarXP1,AvatarYP1;zoomto,200,50;faderight,0.7;);
			BeginCommand=function(self)
				local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
				local diff = steps:GetDifficulty()
				self:diffuse(getDifficultyColor(diff))
				self:diffusealpha(0.7)
			end;
		};
		Def.Sprite {
			InitCommand=cmd(visible,true;halign,0;valign,0;xy,AvatarXP1,AvatarYP1;);
			BeginCommand=cmd(queuecommand,"ModifyAvatar");
			ModifyAvatarCommand=function(self)
				self:finishtweening();
				self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(PLAYER_1)));
				self:zoomto(50,50)
			end;	
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+7;halign,0;zoom,0.6;shadowlength,1;maxwidth,180/0.6);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp1 = getCurScoreST(PLAYER_1,0)
				local temp2 = getMaxScoreST(PLAYER_1,0)
				temp2 = math.max(temp2,1)
				local text = string.format("%05.2f%%",math.floor((temp1/temp2)*10000)/100)
				self:settext(profileNameP1.." "..text)
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set");
		};


		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+20;halign,0;zoom,0.4;shadowlength,1;maxwidth,180/0.4);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
				local diff = getDifficulty(steps:GetDifficulty())
				local meter = steps:GetMeter()
				local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
				self:settext(stype.." "..diff.." "..meter)
			end;
		};

		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+32;halign,0;zoom,0.4;shadowlength,1;maxwidth,180/0.4);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext(GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString('ModsLevel_Current'))
			end;
		};

	};
end;



-- P2 Avatar
if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = Def.ActorFrame{
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if profileP2 == nil then
				self:visible(false)
			else
				self:visible(true)
			end;
		end;
		Def.Quad {
			InitCommand = cmd(halign,1;valign,0;xy,AvatarXP2+50,AvatarYP2;zoomto,200,50;fadeleft,0.7;);
			BeginCommand=function(self)
				local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
				local diff = steps:GetDifficulty()
				self:diffuse(getDifficultyColor(diff))
				self:diffusealpha(0.7)
			end;
		};
		Def.Sprite {
			InitCommand=cmd(visible,true;halign,0;valign,0;xy,AvatarXP2,AvatarYP2);
			BeginCommand=cmd(queuecommand,"ModifyAvatar");
			ModifyAvatarCommand=function(self)
				self:finishtweening();
				self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(PLAYER_2)));
				self:zoomto(50,50)
			end;	
		};
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+7;halign,1;zoom,0.6;shadowlength,1;maxwidth,180/0.6);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local temp1 = getCurScoreST(PLAYER_2,0)
				local temp2 = getMaxScoreST(PLAYER_2,0)
				temp2 = math.max(temp2,1)
				local text = string.format("%05.2f%%",math.floor((temp1/temp2)*10000)/100)
				self:settext(text.." "..profileNameP2)
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set");
		};

		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+20;halign,1;zoom,0.4;shadowlength,1;maxwidth,180/0.4);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
				local diff = getDifficulty(steps:GetDifficulty())
				local meter = steps:GetMeter()
				local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
				self:settext(stype.." "..diff.." "..meter)
			end;
		};

		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+32;halign,1;zoom,0.4;shadowlength,1;maxwidth,180/0.4);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext(GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptionsString('ModsLevel_Current'))
			end;
		};
	};
end;

return t;