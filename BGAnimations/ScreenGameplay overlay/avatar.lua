--Avatar frames which also includes current additive %score, mods, and the song stepsttype/difficulty.

local t = Def.ActorFrame{
	Name="Avatars"
}

local bareBone = isBareBone()

local profileP1

local profileNameP1 = "No Profile"

local avatarPosition = {
	PlayerNumber_P1 = {
		X = 10,
		Y = 10
	}
}

local function PLife(pn)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentLife() or 0
end

local function avatarFrame(pn)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(avatarPosition[pn].X,avatarPosition[pn].Y)
		end
	}
	local profile = GetPlayerOrMachineProfile(pn)

	t[#t+1] = Def.Quad {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:zoomto(200,50)
				self:halign(0):valign(0)
			else
				self:x(50):zoomto(200,50)
				self:halign(1):valign(0)
			end
			self:queuecommand('Set')
		end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(pn)
			local diff = steps:GetDifficulty()
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:zoomto(200,50)
				self:halign(0):valign(0)
				self:xy(-3,-3)
			else
				self:xy(53,-3):zoomto(200,50)
				self:halign(1):valign(0)
			end
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

	t[#t+1] = Def.Sprite {
		InitCommand = function(self)
			self:halign(0):valign(0)
		end,
		BeginCommand = function(self) self:queuecommand('ModifyAvatar') end,
		ModifyAvatarCommand=function(self)
			self:finishtweening()
			self:LoadBackground(PROFILEMAN:GetAvatarPath(pn))
			self:zoomto(50,50)
		end
	}



	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand= function(self)
			local name = profile:GetDisplayName()
			if pn == PLAYER_1 then
				self:xy(56,12):zoom(0.6):shadowlength(1):halign(0):maxwidth(180/0.6)
			else
				self:xy(-6,12):zoom(0.6):shadowlength(1):halign(1):maxwidth(180/0.6)
			end
		    self:settext(name)
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(56,26):zoom(0.4):halign(0):maxwidth(180/0.4)
			else
				self:xy(-6,26):zoom(0.4):halign(1):maxwidth(180/0.4)
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(pn)
			local diff = getDifficulty(steps:GetDifficulty())
			local meter = steps:GetMSD(getCurRateValue(),1)
			meter = meter == 0 and steps:GetMeter() or math.floor(meter)


			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			self:settext(stype.." "..diff.." "..math.floor(meter))
			self:diffuse(getDifficultyColor(steps:GetDifficulty()))
		end,
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:zoomto(200,50)
				self:halign(0)
				self:xy(57, 40)
			else
				self:xy(-7, 40):zoomto(200,50)
				self:halign(1)
			end
			self:zoomto(120,10)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			if pn == PLAYER_1 then
				self:halign(0)
				self:xy(57, 40)
			else
				self:halign(1)
				self:xy(-7, 40)
			end
			self:zoomto(0,10)
			self:diffuse(getMainColor("highlight"))
			self:queuecommand("Set")
		end,
		JudgmentMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			self:finishtweening()
			self:smooth(0.1)
			self:zoomx(PLife(pn)*120)
		end
	}

	t[#t+1] = LoadFont("Common Bold") .. {
		OnCommand = function(self)
			if pn == PLAYER_1 then
				self:xy(57+120+10, 40-1)
			else
				self:xy(-7-120-10, 40-1)
			end
			self:zoom(0.35)
			self:queuecommand("Set")
		end,
		JudgmentMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			local life = PLife(pn)
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
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = avatarFrame(pn)
end

return t