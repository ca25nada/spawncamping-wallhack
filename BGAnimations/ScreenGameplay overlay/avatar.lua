local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local fullPlayerInfo = themeConfig:get_data().global.PlayerInfoType -- true for full, false for minimal (lifebar only)
--Avatar frames which also includes current additive %score, mods, and the song stepsttype/difficulty.
local profileP1

local profileNameP1 = "No Profile"

local avatarPosition = {
	X = MovableValues.PlayerInfoP1X,
	Y = MovableValues.PlayerInfoP1Y
}

local function PLife(pn)
	local life = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentLife() or 0
	if life < 0 then
		return 0
	else
		return life
	end
end

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local profile = GetPlayerOrMachineProfile(PLAYER_1)

-- whole frame actorframe
local t = Def.ActorFrame {
	OnCommand = function(self)
		self:xy(avatarPosition.X,avatarPosition.Y)
		self:zoomto(MovableValues.PlayerInfoP1Width, MovableValues.PlayerInfoP1Height)
		if (allowedCustomization) then
			Movable.DeviceButton_j.element = self
			Movable.DeviceButton_j.condition = true
			Movable.DeviceButton_k.element = self
			Movable.DeviceButton_k.condition = true
		end
	end,
}

if fullPlayerInfo then
	-- whole frame bg quad
	t[#t+1] = Def.Quad {
		InitCommand = function(self)
			self:zoomto(200,50)
			self:halign(0):valign(0)
			self:queuecommand('Set')
		end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			local diff = steps:GetDifficulty()
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
	}

	-- border?
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(200,50)
			self:halign(0):valign(0)
			self:xy(-3,-3)
			self:zoomto(56,56)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			self:stoptweening()
			self:smooth(0.5)
			self:diffuse(getBorderColor())
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	-- avatar
	t[#t+1] = Def.Sprite {
		InitCommand = function(self)
			self:halign(0):valign(0)
		end,
		BeginCommand = function(self) self:queuecommand('ModifyAvatar') end,
		ModifyAvatarCommand=function(self)
			self:finishtweening()
			self:Load(getAvatarPath(PLAYER_1))
			self:zoomto(50,50)
		end
	}


	-- profile name
	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand= function(self)
			local name = profile:GetDisplayName()
			self:xy(56,7):zoom(0.6):shadowlength(1):halign(0):maxwidth(180/0.6)
			self:settext(name)
		end
	}

	-- diff name
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(56,21):zoom(0.4):halign(0):maxwidth(180/0.4)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			local diff = getDifficulty(steps:GetDifficulty())
			local meter = steps:GetMSD(getCurRateValue(),1)
			meter = meter == 0 and steps:GetMeter() or meter


			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			self:settextf("%s %s %5.2f",stype, diff, meter)
			self:diffuse(getDifficultyColor(steps:GetDifficulty()))
		end,
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
	}

	
	t[#t+1] = LoadFont("Common Bold") .. {
		OnCommand = function(self)
			self:xy(57, 47)
			self:zoom(0.35)
			self:queuecommand("Set")
			self:halign(0)
			self:maxwidth(200 * 2)
		end,
		SetCommand = function(self)
			local mods = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString("ModsLevel_Current")
			self:settext(mods)
		end

	}
end

-- life bg
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(200,50)
		self:halign(0)
		self:xy(57, 35)
		self:zoomto(120,10)
	end
}

-- life bar
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:halign(0)
		self:xy(57, 35)
		self:zoomto(0,10)
		self:diffuse(getMainColor("highlight"))
		self:queuecommand("Set")
	end,
	JudgmentMessageCommand = function(self, params)
		self:playcommand("Set", params)
	end,
	SetCommand = function(self, params)
		if params ~= nil and params.TapNoteScore == "TapNoteScore_AvoidMine" then
			return
		end
		self:finishtweening()
		self:smooth(0.1)
		self:zoomx(PLife(PLAYER_1)*120)
	end
}

-- life counter
t[#t+1] = LoadFont("Common Bold") .. {
	OnCommand = function(self)
		self:xy(57+120+10, 35-1)
		self:zoom(0.35)
		self:queuecommand("Set")
	end,
	JudgmentMessageCommand = function(self, params)
		self:playcommand("Set", params)
	end,
	SetCommand = function(self, params)
		if params ~= nil and params.TapNoteScore == "TapNoteScore_AvoidMine" then
			return
		end
		local life = PLife(PLAYER_1)
		self:settextf("%0.0f",life*100)
		if life*100 < 30 and life*100 ~= 0 then -- replace with lifemeter danger later
			self:diffuseshift()
			self:effectcolor1(1,1,1,1)
			self:effectcolor2(1,0.9,0.9,0.5)
			self:effectperiod(0.9*life+0.15)
		elseif life*100 <= 0 then
			self:stopeffect()
			self:diffuse(color("0,0,0,1"))
		else
			self:stopeffect()
			self:diffuse(color("1,1,1,1"))
		end
	end
}


return t