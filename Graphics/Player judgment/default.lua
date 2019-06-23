local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local c
local player = Var "Player"
local bareBone = isBareBone()
local JTDisabled = not useJudgmentTween()
local enabled = isJudgmentEnabled()
if not enabled then
	return Def.ActorFrame {}
end

--[[
Removed from metrics:
# Things the judgment does when you bang on it.
JudgmentW1Command=shadowlength,0;diffusealpha,1;zoom,1.3;linear,0.05;zoom,1;sleep,0.8;linear,0.1;zoomy,0.5;zoomx,2;diffusealpha,0;glowblink;effectperiod,0.05;effectcolor1,color("1,1,1,0");effectcolor2,color("1,1,1,0.25")
JudgmentW2Command=shadowlength,0;diffusealpha,1;zoom,1.3;linear,0.05;zoom,1;sleep,0.8;linear,0.1;zoomy,0.5;zoomx,2;diffusealpha,0
JudgmentW3Command=shadowlength,0;diffusealpha,1;zoom,1.2;linear,0.05;zoom,1;sleep,0.8;linear,0.1;zoomy,0.5;zoomx,2;diffusealpha,0;
JudgmentW4Command=shadowlength,0;diffusealpha,1;zoom,1.1;linear,0.05;zoom,1;sleep,0.8;linear,0.1;zoomy,0.5;zoomx,2;diffusealpha,0;
JudgmentW5Command=shadowlength,0;diffusealpha,1;zoom,1.0;vibrate;effectmagnitude,4,8,8;sleep,0.8;linear,0.1;zoomy,0.5;zoomx,2;diffusealpha,0
JudgmentMissCommand=shadowlength,0;diffusealpha,1;zoom,1;linear,0.8;sleep,0.8;linear,0.1;zoomy,0.5;zoomx,2;diffusealpha,0
]]

local JudgeCmds = {
	TapNoteScore_W1 = function(self)
		self:shadowlength(0):diffusealpha(1):zoom(1.3 * MovableValues.JudgeZoom)
		self:linear(0.05):zoom(1 * MovableValues.JudgeZoom)
		self:sleep(0.8):linear(0.1)
		self:zoomx(0.5 * MovableValues.JudgeZoom)
		self:zoomy(2 * MovableValues.JudgeZoom)
		self:diffusealpha(0)
		self:glowblink():effectperiod(0.05):effectcolor1(color("1,1,1,0")):effectcolor2(color("1,1,1,0.25"))
	end,
	TapNoteScore_W2 = function(self)
		self:shadowlength(0):diffusealpha(1):zoom(1.3 * MovableValues.JudgeZoom)
		self:linear(0.05):zoom(1 * MovableValues.JudgeZoom)
		self:sleep(0.8):linear(0.1)
		self:zoomx(0.5 * MovableValues.JudgeZoom)
		self:zoomy(2 * MovableValues.JudgeZoom)
		self:diffusealpha(0)
	end,
	TapNoteScore_W3 = function(self)
		self:shadowlength(0):diffusealpha(1):zoom(1.2 * MovableValues.JudgeZoom)
		self:linear(0.05):zoom(1 * MovableValues.JudgeZoom)
		self:sleep(0.8):linear(0.1)
		self:zoomx(0.5 * MovableValues.JudgeZoom)
		self:zoomy(2 * MovableValues.JudgeZoom)
		self:diffusealpha(0)
	end,
	TapNoteScore_W4 = function(self)
		self:shadowlength(0):diffusealpha(1):zoom(1.1 * MovableValues.JudgeZoom)
		self:linear(0.05):zoom(1 * MovableValues.JudgeZoom)
		self:sleep(0.8):linear(0.1)
		self:zoomx(0.5 * MovableValues.JudgeZoom)
		self:zoomy(2 * MovableValues.JudgeZoom)
		self:diffusealpha(0)
	end,
	TapNoteScore_W5 = function(self)
		self:shadowlength(0):diffusealpha(1):zoom(1.0 * MovableValues.JudgeZoom)
		self:vibrate()
		self:effectmagnitude(0.01,0.02,0.02)
		self:sleep(0.8)
		self:linear(0.1)
		self:zoomx(0.5 * MovableValues.JudgeZoom)
		self:zoomy(2 * MovableValues.JudgeZoom)
		self:diffusealpha(0)
	end,
	TapNoteScore_Miss = function(self)
		self:shadowlength(0):diffusealpha(1):zoom(1.0 * MovableValues.JudgeZoom)
		self:linear(0.8)
		self:sleep(0.8):linear(0.1)
		self:zoomx(0.5 * MovableValues.JudgeZoom)
		self:zoomy(2 * MovableValues.JudgeZoom)
		self:diffusealpha(0)
	end
}

local TNSFrames = {
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 1,
	TapNoteScore_W3 = 2,
	TapNoteScore_W4 = 3,
	TapNoteScore_W5 = 4,
	TapNoteScore_Miss = 5
}


local function judgmentZoom(value)
    c.Judgment:zoom(value)
    if allowedCustomization then
	    c.Border:playcommand("ChangeWidth", {val = c.Judgment:GetZoomedWidth()})
	    c.Border:playcommand("ChangeHeight", {val = c.Judgment:GetZoomedHeight()})
	end
end

local t = Def.ActorFrame {
	InitCommand = function(self)
		self:draworder(350)
	end,
	Def.Sprite {
		Texture = "../../../../" .. getAssetPath("judgment"),
		Name="Judgment",
		InitCommand=function(self)
			self:pause():visible(false):xy(MovableValues.JudgeX, MovableValues.JudgeY)
		end,
		OnCommand=THEME:GetMetric("Judgment","JudgmentOnCommand"),
		ResetCommand=function(self)
			self:finishtweening():stopeffect():visible(false)
		end
	},
	OnCommand = function(self)
		c = self:GetChildren()
		judgmentZoom(MovableValues.JudgeZoom)
		if allowedCustomization then
			Movable.DeviceButton_1.element = c
			Movable.DeviceButton_2.element = c
			Movable.DeviceButton_1.condition = true
			Movable.DeviceButton_2.condition = true
			Movable.DeviceButton_2.DeviceButton_up.arbitraryFunction = judgmentZoom
			Movable.DeviceButton_2.DeviceButton_down.arbitraryFunction = judgmentZoom
			Movable.DeviceButton_1.propertyOffsets = {self:GetTrueX() , self:GetTrueY() - c.Judgment:GetHeight()}	-- centered to screen/valigned
		end
	end,

	JudgmentMessageCommand=function(self, param)
		if param.Player ~= player then return end
		if param.HoldNoteScore then return end

		local iNumStates = c.Judgment:GetNumStates()
		local iFrame = TNSFrames[param.TapNoteScore]
		
		local iTapNoteOffset = param.TapNoteOffset
		
		if not iFrame then return end
		if iNumStates == 12 then
			iFrame = iFrame * 2
			if not param.Early then
				iFrame = iFrame + 1
			end
		end
		
		self:playcommand("Reset")

		c.Judgment:visible( true )
		c.Judgment:setstate( iFrame )
		if not bareBone and not JTDisabled then
			JudgeCmds[param.TapNoteScore](c.Judgment)
		end

	end,
	MovableBorder(0, 0, 1, MovableValues.JudgeX, MovableValues.JudgeY)
}

return t
