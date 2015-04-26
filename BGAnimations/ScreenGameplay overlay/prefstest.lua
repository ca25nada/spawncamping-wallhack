--for debug only

local stringListP1 = {
	ScreenFilter = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ScreenFilter,
	JudgeType = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).JudgeType,
	AvgScoreType = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).AvgScoreType,
	GhostScoreType = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GhostScoreType,
	GhostTarget = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GhostTarget,
	ErrorBar = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ErrorBar,
	PaceMaker = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).PaceMaker,
}

local stringListP2 = {
	ScreenFilter = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).ScreenFilter,
	JudgeType = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).JudgeType,
	AvgScoreType = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).AvgScoreType,
	GhostScoreType = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).GhostScoreType,
	GhostTarget = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).GhostTarget,
	ErrorBar = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).ErrorBar,
	PaceMaker = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).PaceMaker,
}

local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_CENTER_X+200,SCREEN_CENTER_Y;zoomto,150,200;diffuse,color("#33333399"));
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_CENTER_X-200,SCREEN_CENTER_Y;zoomto,150,200;diffuse,color("#33333399"));
};

t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X+200,SCREEN_CENTER_Y;zoom,0.6;shadowlength,1);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local str = ""
			for k,v in pairs(stringListP2) do 
				str = str..tostring(k)..":"..tostring(v).."\n"
			end;
			self:settext(str)
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X-200,SCREEN_CENTER_Y;zoom,0.6;shadowlength,1												);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local str = ""
			for k,v in pairs(stringListP1) do 
				str = str..tostring(k)..":"..tostring(v).."\n"
			end;
			self:settext(str)
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};

return t