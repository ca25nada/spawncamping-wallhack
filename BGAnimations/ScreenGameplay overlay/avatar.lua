--Avatar frames which also includes current additive %score, mods, and the song stepsttype/difficulty.

local t = Def.ActorFrame{
	Name="Avatars";
};

local bareBone = isBareBone()

local profileP1
local profileP2

local profileNameP1 = "No Profile"
local profileNameP2 = "No Profile"


local AvatarXP1 = 0
local AvatarYP1 = SCREEN_HEIGHT-50
local AvatarXP2 = SCREEN_WIDTH-50
local AvatarYP2 = SCREEN_HEIGHT-50

local avatarPosition = {
	PlayerNumber_P1 = {
		X = 0,
		Y = SCREEN_HEIGHT-50
	},
	PlayerNumber_P2 = {
		X = SCREEN_WIDTH-50,
		Y = SCREEN_HEIGHT-50
	}
}

local function avatarFrame(pn)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(avatarPosition[pn].X,avatarPosition[pn].Y)
		end;
	}
	local profile = GetPlayerOrMachineProfile(pn)

	t[#t+1] = Def.Quad {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:zoomto(200,50):faderight(0.7)
				self:halign(0):valign(0)
			else
				self:x(50):zoomto(200,50):fadeleft(0.7)
				self:halign(1):valign(0)
			end
			self:queuecommand('Set')
		end;
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(pn);
			local diff = steps:GetDifficulty()
			self:diffuse(getDifficultyColor(diff))
			self:diffusealpha(0.7)
		end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = Def.Sprite {
		InitCommand = function(self)
			self:halign(0):valign(0)
		end;
		BeginCommand = function(self) self:queuecommand('ModifyAvatar') end;
		ModifyAvatarCommand=function(self)
			self:finishtweening();
			self:LoadBackground(PROFILEMAN:GetAvatarPath(pn));
			self:zoomto(50,50)
		end;	
	};

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand= function(self)
			local name = profile:GetDisplayName()
			if pn == PLAYER_1 then
				self:xy(53,7):zoom(0.6):shadowlength(1):halign(0):maxwidth(180/0.6)
			else
				self:xy(-3,7):zoom(0.6):shadowlength(1):halign(1):maxwidth(180/0.6)
			end
		    self:settext(name.." 0.00%")
		end;
		JudgmentMessageCommand = function(self, params) 
			self:settextf("%s %.2f%%", profile:GetDisplayName(), math.floor(params.TotalPercent*10000)/100)
		end;
	};

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(53,20):zoom(0.4):halign(0):maxwidth(180/0.4)
				self:shadowlength(1)
			else
				self:xy(-3,20):zoom(0.4):halign(1):maxwidth(180/0.4)
				self:shadowlength(1)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(pn);
			local diff = getDifficulty(steps:GetDifficulty())
			local meter = steps:GetMeter()
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			self:settext(stype.." "..diff.." "..meter)
		end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(53,32):zoom(0.4):halign(0):maxwidth(180/0.4)
				self:shadowlength(1)
			else
				self:xy(-3,32):zoom(0.4):halign(1):maxwidth(180/0.4)
				self:shadowlength(1)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		SetCommand=function(self)
			self:settext(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString('ModsLevel_Current'))
		end;
	};

	return t
end

local function bareBoneFrame(pn)
	local profile = GetPlayerOrMachineProfile(pn)
	local name = profile:GetDisplayName()

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(avatarPosition[pn].X,avatarPosition[pn].Y)
		end;
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(3,7):halign(0)
			else
				self:xy(-3,7):halign(1)
			end
			self:zoom(0.6):maxwidth(180/0.4)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		SetCommand=function(self)
			local temp1 = getCurScoreST(pn,0)
			local temp2 = getMaxScoreST(pn,0)
			temp2 = math.max(temp2,1)
			self:settextf("%s %.2f%%",name,math.floor((temp1/temp2)*10000)/100)
		end;
		JudgmentMessageCommand = function(self) self:queuecommand('Set') end;
	};

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(3,20):halign(0)
			else
				self:xy(-3,20):halign(1)
			end
			self:zoom(0.4):maxwidth(180/0.4)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(pn);
			local diff = getDifficulty(steps:GetDifficulty())
			local meter = steps:GetMeter()
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			self:settext(stype.." "..diff.." "..meter)
		end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(3,32):halign(0)
			else
				self:xy(-3,32):halign(1)
			end
			self:zoom(0.4):maxwidth(180/0.4)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		SetCommand=function(self)
			self:settext(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString('ModsLevel_Current'))
		end;
	};

	return t
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	if bareBone then
		t[#t+1] = bareBoneFrame(pn)
	else
		t[#t+1] = avatarFrame(pn)
	end
end

return t;