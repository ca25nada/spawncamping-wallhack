local t = Def.ActorFrame{}
local topFrameHeight = 35
local bottomFrameHeight = 54
local borderWidth = 4


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


local AvatarXP1 = SCREEN_CENTER_X/2 - 270/2 + 5
local AvatarYP1 = 60
local AvatarXP2 = SCREEN_CENTER_X/2*3 + 270/2 + 5
local AvatarYP2 = 60

local bpms = {}
if GAMESTATE:GetCurrentSong() then
	bpms= GAMESTATE:GetCurrentSong():GetDisplayBpms()
	bpms[1] = math.round(bpms[1])
	bpms[2] = math.round(bpms[2])
end

-- P1 Avatar
t[#t+1] = Def.Actor{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
			if profileP1 ~= nil then
				if profileP1 == PROFILEMAN:GetMachineProfile() then
					profileNameP1 = "Machine Profile"
				else
					profileNameP1 = profileP1:GetDisplayName()
				end
				playCountP1 = profileP1:GetTotalNumSongsPlayed()
				playTimeP1 = profileP1:GetTotalSessionSeconds()
				noteCountP1 = profileP1:GetTotalTapsAndHolds()
			else 
				profileNameP1 = "No Profile"
				playCountP1 = 0
				playTimeP1 = 0
				noteCountP1 = 0
			end; 
		else
			profileNameP1 = "No Profile"
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
				if profileP2 == PROFILEMAN:GetMachineProfile() then
					profileNameP2 = "Machine Profile"
				else
					profileNameP2 = profileP2:GetDisplayName()
				end
				playCountP2 = profileP2:GetTotalNumSongsPlayed()
				playTimeP2 = profileP2:GetTotalSessionSeconds()
				noteCountP2 = profileP2:GetTotalTapsAndHolds()
			else 
				profileNameP2 = "No Profile"
				playCountP2 = 0
				playTimeP2 = 0
				noteCountP2 = 0
			end;
		else
			profileNameP2 = "No Profile"
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
		ModifyAvatarCommand=function(self)
			self:finishtweening();
			self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(PLAYER_1)));
			self:zoomto(30,30)
		end;
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP1+33,AvatarYP1+6;halign,0;zoom,0.45;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(profileNameP1.."'s Scroll Speed:")
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP1+33,AvatarYP1+19;halign,0;zoom,0.40;);
		BeginCommand=function(self)
			--local speed, mode= GetSpeedModeAndValueFromPoptions(PLAYER_1)
			--self:playcommand("SpeedChoiceChanged", {pn= PLAYER_1, mode= mode, speed= speed})
			self:playcommand("ConfigValueChanged", {pn= PLAYER_1, field_name= "speed_mod"})
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
		ConfigValueChangedMessageCommand= function(self, param)
			if param.pn == PLAYER_1 then
				if param.field_name == "speed_mod" or param.field_name == "speed_type" then
					local prefs= newfield_prefs_config:get_data(param.pn)
					local mode_conversion= {maximum= "m", multiple= "x", constant= "C"}
					local speed= prefs.speed_mod
					local mode= mode_conversion[prefs.speed_type]
					if mode == "x" then
						speed= speed * 100
					end
					self:playcommand(
						"SpeedChoiceChanged", {pn= param.pn, speed= speed, mode= mode})
				end
			end
		end,


		SpeedChoiceChangedMessageCommand=function(self,param)
			if param.pn == PLAYER_1 then
				local rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate() or 1
				local text = ""
				if param.mode == "x" then
					if not bpms[1] then
						text = "??? - ???"
					elseif bpms[1] == bpms[2] then
						text = math.round(bpms[1]*rate*param.speed/100)
					else
						text = string.format("%d - %d",math.round(bpms[1]*rate*param.speed/100),math.round(bpms[2]*rate*param.speed/100))
					end
				elseif param.mode == "C" then
					text = param.speed
				else
					if not bpms[1] then
						text = "??? - "..param.speed
					elseif bpms[1] == bpms[2] then
						text = param.speed
					else
						local factor = param.speed/bpms[2]
						text = string.format("%d - %d",math.round(bpms[1]*factor),param.speed)
					end
				end
				self:settext(text)
			end
		end;
	}
}

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
		ModifyAvatarCommand=function(self)
			self:finishtweening();
			self:LoadBackground(THEME:GetPathG("","../"..getAvatarPath(PLAYER_2)));
			self:zoomto(30,30)
		end;	
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+7;halign,1;zoom,0.45;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(profileNameP2.."'s Scroll Speed:")
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarXP2-3,AvatarYP2+19;halign,1;zoom,0.45;);
		BeginCommand=function(self)
			--local speed, mode= GetSpeedModeAndValueFromPoptions(PLAYER_2)
			--self:playcommand("SpeedChoiceChanged", {pn= PLAYER_2, mode= mode, speed= speed})
			self:playcommand("ConfigValueChanged", {pn= PLAYER_2, field_name= "speed_mod"})
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
		ConfigValueChangedMessageCommand= function(self, param)
			if param.pn == PLAYER_2 then
				if param.field_name == "speed_mod" or param.field_name == "speed_type" then
					local prefs= newfield_prefs_config:get_data(param.pn)
					local mode_conversion= {maximum= "m", multiple= "x", constant= "C"}
					local speed= prefs.speed_mod
					local mode= mode_conversion[prefs.speed_type]
					if mode == "x" then
						speed= speed * 100
					end
					self:playcommand(
						"SpeedChoiceChanged", {pn= param.pn, speed= speed, mode= mode})
				end
			end
		end,
		SpeedChoiceChangedMessageCommand=function(self,param)
			if param.pn == PLAYER_2 then
				local text = ""
				local rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Current'):MusicRate() or 1
				if param.mode == "x" then
					if not bpms[1] then
						text = "??? - ???"
					elseif bpms[1] == bpms[2] then
						text = math.round(bpms[1]*rate*param.speed/100)
					else
						text = string.format("%d - %d",math.round(bpms[1]*rate*param.speed/100),math.round(bpms[2]*rate*param.speed/100))
					end
				elseif param.mode == "C" then
					text = param.speed
				else
					if not bpms[1] then
						text = "??? - "..param.speed
					elseif bpms[1] == bpms[2] then
						text = param.speed
					else
						local factor = param.speed/bpms[2]
						text = string.format("%d - %d",math.round(bpms[1]*factor),param.speed)
					end
				end
				self:settext(text)
			end
		end;
	}
}

t[#t+1] = LoadActor("_frame");

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function (self)
		self:diffuse(color("#FFFFFF"))
		self:zoom(0.5)
		self:halign(0)
		self:xy(10,10)
		self:settext("Player Options")
	end;
};

return t