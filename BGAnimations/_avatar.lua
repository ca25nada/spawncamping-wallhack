--avatars should work minus in the case when a 2nd player joins midway, because i have no idea how to re-load the image.

local t = Def.ActorFrame{
	Name="PlayerAvatar";
};

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
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
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
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
}


t[#t+1] = Def.ActorFrame{
	Name="Avatar"..PLAYER_1;
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if profileP1 == nil then
			self:visible(false)
		else
			self:visible(true)
		end;
	end;
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");

	Def.Sprite {
		Name="Image";
		InitCommand=cmd(visible,true;halign,0;valign,0;xy,AvatarXP1,AvatarYP1);
		BeginCommand=cmd(queuecommand,"ModifyAvatar");
		PlayerJoinedMessageCommand=cmd(queuecommand,"ModifyAvatar");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"ModifyAvatar");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"ModifyAvatar");
		ModifyAvatarCommand=function(self)
			self:finishtweening();
			self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(PLAYER_1)));
			self:zoomto(50,50)
		end;	
	};
	--[[
	LoadActor("../../"..getAvatarPath(PLAYER_1))..{
		Name="Avatar";
		InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,0;xy,AvatarXP1,AvatarYP1);
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	--]]
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+7;halign,0;zoom,0.6;diffuse,getMainColor(2));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(profileNameP1)
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+20;halign,0;zoom,0.35;diffuse,getMainColor(3));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(playCountP1.." Plays");
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+30;halign,0;zoom,0.35;diffuse,getMainColor(3));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(noteCountP1.." Arrows Smashed")
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP1+53,AvatarYP1+40;halign,0;zoom,0.35;diffuse,getMainColor(3));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local time = SecondsToHHMMSS(playTimeP1)
			self:settextf(time.." PlayTime")
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
};

-- P2 Avatar
t[#t+1] = Def.ActorFrame{
	Name="Avatar"..PLAYER_2;
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if profileP2 == nil then
			self:visible(false)
		else
			self:visible(true)
		end;
	end;
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");

	Def.Sprite {
		Name="Image";
		InitCommand=cmd(visible,true;halign,0;valign,0;xy,AvatarXP2,AvatarYP2);
		BeginCommand=cmd(queuecommand,"ModifyAvatar");
		PlayerJoinedMessageCommand=cmd(queuecommand,"ModifyAvatar");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"ModifyAvatar");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"ModifyAvatar");
		ModifyAvatarCommand=function(self)
			self:finishtweening();
			self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(PLAYER_2)));
			self:zoomto(50,50)
		end;	
	};

	--[[
	LoadActor("../../"..getAvatarPath(PLAYER_2))..{
		Name="Avatar";
		InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,0;xy,AvatarXP2,AvatarYP2);
	};--]]
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+7;halign,1;zoom,0.6;diffuse,getMainColor(2));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(profileNameP2)
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+20;halign,1;zoom,0.35;diffuse,getMainColor(3));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(playCountP2.." Plays");
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+30;halign,1;zoom,0.35;diffuse,getMainColor(3));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(noteCountP2.." Arrows Smashed")
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+40;halign,1;zoom,0.35;diffuse,getMainColor(3));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local time = SecondsToHHMMSS(playTimeP2)
			self:settextf(time.." PlayTime")
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
};


return t;