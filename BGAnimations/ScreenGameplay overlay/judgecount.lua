-- Simple Judgecounter that tracks #of occurences for each judgment and the current grade from the average DP score.

local judges = { -- do not edit
	"TapNoteScore_W1",
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	"TapNoteScore_W5",
	"TapNoteScore_Miss",			
	"HoldNoteScore_Held",
	"HoldNoteScore_LetGo",
}
local judges2 = {}
for k,v in pairs(judges) do
	judges2[v] = true
end

local bareBone = isBareBone()
local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() -- For relocating graph/judgecount frame
local center1P = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player")) -- For relocating graph/judgecount frame

local judgeTypeP1 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).JudgeType
local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay

local spacing = 12 -- Spacing between the judgetypes
local frameWidth = 80 -- Width of the Frame
local frameHeight = ((#judges+1)*spacing)+8 -- Height of the Frame
local judgeFontSize = 0.40 -- Font sizes for different text elements 
local countFontSize = 0.35
local gradeFontSize = 0.45
local highlightOpacity = 0.4
local backgroundOpacity = bareBone and 1 or 0.6

local position = {
	PlayerNumber_P1 = {
		X = MovableValues.JudgeCounterX,
		Y = MovableValues.JudgeCounterY
	}
}

--adjust for non-widescreen users.
if ((not center1P) and (not IsUsingWideScreen())) then
	position.PlayerNumber_P1.X = SCREEN_CENTER_X+20
end

local enabled1P = judgeTypeP1 ~= 0
if not enabled1P then
	return Def.ActorFrame {}
end
--=========================================================================--
--=========================================================================--
--=========================================================================--

-- The Judgment text itself (MA for marvelous, etc.)
local highlight = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).JudgeType == 2 and not bareBone
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)

local t = Def.ActorFrame {
	Name = "JudgeCounter",
	InitCommand = function(self)
		self:xy(position[PLAYER_1].X, position[PLAYER_1].Y)
		if (allowedCustomization) then
			Movable.DeviceButton_p.element = self
			Movable.DeviceButton_p.condition = enabled1P
		end
	end,
	JudgmentMessageCommand = function(self, params)
		if params.Player == PLAYER_1 then
			self:GetChild(PLAYER_1.."Grade"):playcommand("Set", params)
			if judges2[params.HoldNoteScore] then
				if highlight then
					self:GetChild(PLAYER_1..params.HoldNoteScore.."Highlight"):playcommand("Set")
				end
				self:GetChild(PLAYER_1..params.HoldNoteScore.."Count"):queuecommand("Set")
			elseif judges2[params.TapNoteScore] then
				if highlight then
					self:GetChild(PLAYER_1..params.TapNoteScore.."Highlight"):playcommand("Set")
				end
				self:GetChild(PLAYER_1..params.TapNoteScore.."Count"):queuecommand("Set")
			end
		end
	end,
	MovableBorder(frameWidth, frameHeight, 1, frameWidth/2, frameHeight/2)
}

t[#t+1] = Def.Quad{ -- Judgecount Background
	InitCommand = function(self)
		self:zoomto(frameWidth,frameHeight):halign(0):valign(0)
		self:diffuse(getMainColor("frame")):diffusealpha(backgroundOpacity)
	end
}

t[#t+1] = LoadFont("Common Bold") .. { --grade
	Name=PLAYER_1.."Grade",
	InitCommand = function(self)
		self:xy(5,8+(#judges*spacing)):halign(0)
		self:zoom(gradeFontSize)
		self:playcommand("Set")
	end,
	SetCommand = function(self, params)
		if not params then
			self:settext(getGradeStrings("Grade_Tier07"))
			return
		end
		self:settext(getGradeStrings(getWifeGradeTier(params.WifePercent)))

		
	end
}

for k,v in ipairs(judges) do

	if highlight then
		t[#t+1] = Def.Quad{ --JudgeHighlight
			Name=PLAYER_1..v.."Highlight",
			InitCommand = function(self)
				self:xy(0,5+((k-1)*spacing)):zoomto(frameWidth,5):halign(0):valign(0)
				self:diffuse(color(colorConfig:get_data().judgment[v])):diffusealpha(0)
			end,
			SetCommand=function(self)
				self:stoptweening()
				self:linear(0.1)
				self:diffusealpha(highlightOpacity)
				self:linear(0.5)
				self:diffusealpha(0)
			end
		}
	end

	t[#t+1] = LoadFont("Common normal")..{
		InitCommand = function(self)
			self:xy(5,7+((k-1)*spacing)):zoom(judgeFontSize):halign(0)
			if not bareBone then
				self:settext(getJudgeStrings(v))
				self:diffuse(color(colorConfig:get_data().judgment[v]))
			else
				self:settext(getShortJudgeStrings(v))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		Name=PLAYER_1..v.."Count",
		InitCommand = function(self)
			self:xy(frameWidth-5,7+((k-1)*spacing)):zoom(judgeFontSize):halign(1)
			self:settext(0)
		end,
		SetCommand=function(self)
			if k > 6 then -- HoldNoteScores
				self:settext(pss:GetHoldNoteScores(v))
			else
				self:settext(pss:GetTapNoteScores(v))
			end
		end,
		PracticeModeResetMessageCommand = function(self)
			self:finishtweening()
			self:settext(0)
		end
	}

end

return t