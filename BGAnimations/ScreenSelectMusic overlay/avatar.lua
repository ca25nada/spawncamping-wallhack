local t = Def.ActorFrame{};

local profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
local profileP2 = GetPlayerOrMachineProfile(PLAYER_2)

t[#t+1] = LoadActor("../../"..getAvatarPath(PLAYER_1))..{
	Name="Avatar";
	InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,1;xy,0,SCREEN_HEIGHT);
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,53,SCREEN_HEIGHT-43;halign,0;zoom,0.6;diffuse,getMainColor(2));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext(profileP1:GetDisplayName())
	end;
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,53,SCREEN_HEIGHT-30;halign,0;zoom,0.35;diffuse,getMainColor(3));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext(profileP1:GetTotalNumSongsPlayed().." Plays");
	end;
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,53,SCREEN_HEIGHT-20;halign,0;zoom,0.35;diffuse,getMainColor(3));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext(profileP1:GetTotalTapsAndHolds().." Arrows Smashed")
	end;
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,53,SCREEN_HEIGHT-10;halign,0;zoom,0.35;diffuse,getMainColor(3));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local rawSeconds = profileP1:GetTotalSessionSeconds()
		local minutes = math.floor(rawSeconds/60)%60
		local hours = math.floor(math.floor(rawSeconds/60)/60)
		local seconds = rawSeconds%60
		self:settextf("%02d:%02d:%02d PlayTime",hours,minutes,seconds)
	end;
};

return t;