-- Dependencies: Scoretracking.lua
-- Simple Judgecounter that tracks #of occurences for each judgment and the current grade from the average DP score.

local t = Def.ActorFrame{}

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

--These should be moved to 02 colors.lua
local judgeColor = { -- Colors of each Judgment types
	TapNoteScore_W1 = color("#99ccff"),
	TapNoteScore_W2	= HSV(48,0.8,0.95),
	TapNoteScore_W3	 = HSV(160,0.9,0.8),
	TapNoteScore_W4	= HSV(200,0.9,1),
	TapNoteScore_W5	= HSV(320,0.9,1),
	TapNoteScore_Miss = HSV(0,0.8,0.8),			
	HoldNoteScore_Held = HSV(48,0.8,0.95),	
	HoldNoteScore_LetGo = HSV(0,0.8,0.8)
}

local highlightColor = { -- Colors of Judgment highlights
	TapNoteScore_W1 = color('0.2,0.773,0.953,0.5'),
	TapNoteScore_W2	= color("1,0.8,0,0.4"),
	TapNoteScore_W3	 = color("0.4,0.8,0.4,0.4"),
	TapNoteScore_W4	= color("0.35,0.46,0.73,0.5"),
	TapNoteScore_W5	= color("0.78,0.48,1,0.5"),
	TapNoteScore_Miss = color("0.85,0.33,0.33,0.5"),			
	HoldNoteScore_Held = color("1,0.8,0,0.4"),	
	HoldNoteScore_LetGo = color("0.85,0.33,0.33,0.5")
}

local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(); -- For relocating graph/judgecount frame
local center1P = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player")); -- For relocating graph/judgecount frame

local judgeTypeP1 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).JudgeType
local judgeTypeP2 = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).JudgeType

local spacing = 10 -- Spacing between the judgetypes
local frameWidth = 60 -- Width of the Frame
local frameHeight = ((#judges+1)*spacing)+8 -- Height of the Frame
local judgeFontSize = 0.40 -- Font sizes for different text elements 
local countFontSize = 0.35
local gradeFontSize = 0.45

local frameX1P = 20 -- X position of the frame when center1player is on
local frameY1P = (SCREEN_HEIGHT*0.62)-5 -- Y Position of the frame

local frameX2P = SCREEN_WIDTH-20-frameWidth -- X position of the frame when center1player is on
local frameY2P = (SCREEN_HEIGHT*0.62)-5 -- Y Position of the frame

--adjust for non-widescreen users.
if ((not center1P) and (not IsUsingWideScreen())) then
	frameX1P = SCREEN_CENTER_X+20
	frameX2P = SCREEN_CENTER_X-20-frameWidth
end

-- tl;dr: if theres no room, don't show.
local enabled1P = (GAMESTATE:IsPlayerEnabled(PLAYER_1) and judgeTypeP1 ~= 0) and (IsUsingWideScreen() or (GAMESTATE:GetNumPlayersEnabled() == 1 and cols <= 6))
local enabled2P = (GAMESTATE:IsPlayerEnabled(PLAYER_2) and judgeTypeP2 ~= 0) and (IsUsingWideScreen() or (GAMESTATE:GetNumPlayersEnabled() == 1 and cols <= 6))

--=========================================================================--
--=========================================================================--
--=========================================================================--

-- The Judgment text itself (MA for marvelous, etc.)
local function judgeText(pn,judge,index)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameX1P
		frameY = frameY1P
	elseif pn == PLAYER_2 then
		frameX = frameX2P
		frameY = frameY2P
	end
	local t = LoadFont("Common normal")..{
		InitCommand=cmd(xy,frameX+5,frameY+7+(index*spacing);zoom,judgeFontSize;halign,0);
		BeginCommand=function(self)
			self:settext(getShortJudgeStrings(judge))
			self:diffuse(judgeColor[judge])
		end;
	}
	return t
end;

-- The judgment count text
local function judgeCount(pn,judge,index)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameX1P
		frameY = frameY1P
	elseif pn == PLAYER_2 then
		frameX = frameX2P
		frameY = frameY2P
	end
	local t = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,frameWidth+frameX-5,frameY+7+(index*spacing);zoom,countFontSize;horizalign,right);
		BeginCommand=function(self)
			self:settext(0)
		end;
		SetCommand=function(self)
			self:settext(getJudgeST(pn,judge))
		end;
		JudgmentMessageCommand=function(self,params)
			if params.Player == pn then
				self:queuecommand("Set")
			end;
		end;
	};
	return t
end

-- A highlight that appears whenever the corresponding judgment occurs
local function judgeHighlight(pn,judge,index)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameX1P
		frameY = frameY1P
	elseif pn == PLAYER_2 then
		frameX = frameX2P
		frameY = frameY2P
	end
	local t = Def.Quad{ --JudgeHighlight
		InitCommand=cmd(xy,frameX,frameY+5+(index*spacing);zoomto,frameWidth,5;diffuse,color("1,1,1,0.0");horizalign,left;vertalign,top;visible,true);
		JudgmentMessageCommand=function(self,params)
			if (params.TapNoteScore == judge or params.HoldNoteScore == judge) and params.Player == pn then
				self:stoptweening();
				self:visible(true);
				self:diffusealpha(0);
				--self:y(framey+0);
				self:linear(0.1);
				self:diffuse(highlightColor[judge]);
				self:linear(0.5)
				self:diffusealpha(0)
			end
		end;
	}
	return t
end

--Make one for P1
if enabled1P then
	t[#t+1] = Def.Quad{ -- Judgecount Background
		InitCommand=cmd(xy,frameX1P,frameY1P;zoomto,frameWidth,frameHeight;diffuse,color("0,0,0,0.4");horizalign,left;vertalign,top);
	}

	local index = 0 --purely for positional purposes
	-- make judgecount thing
	for k,v in pairs(judges) do
		if judgeTypeP1 == 2 then
			t[#t+1] = judgeHighlight(PLAYER_1,v,index)
		end
		t[#t+1] = judgeText(PLAYER_1,v,index)
		t[#t+1] = judgeCount(PLAYER_1,v,index)
		index = index +1 
	end

	t[#t+1] = LoadFont("Common Normal") .. { --grade
	        InitCommand=cmd(xy,frameX1P+5,frameY1P+8+(index*spacing);zoom,gradeFontSize;horizalign,left);
			BeginCommand=function(self)
				self:settext(getGradeStrings(getGradeST(PLAYER_1)))
			end;
			SetCommand=function(self)
				local temp = GetGradeFromPercent(0)
				if curmaxdp ~= 0 then -- bunch of error messages pop up when getgradefrompercent is called with a undefined value
					temp = getGradeST(PLAYER_1)
				end
				self:settext(getGradeStrings(temp))
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set")
	}
end

--Make one for P2
if enabled2P then
	t[#t+1] = Def.Quad{ -- Judgecount Background
		InitCommand=cmd(xy,frameX2P,frameY2P;zoomto,frameWidth,frameHeight;diffuse,color("0,0,0,0.4");horizalign,left;vertalign,top);
	}

	local index = 0 --purely for positional purposes
	-- make judgecount thing
	for k,v in pairs(judges) do
		if judgeTypeP2 == 2 then
			t[#t+1] = judgeHighlight(PLAYER_2,v,index)
		end
		t[#t+1] = judgeText(PLAYER_2,v,index)
		t[#t+1] = judgeCount(PLAYER_2,v,index)
		index = index +1 
	end

	t[#t+1] = LoadFont("Common Normal") .. { --grade
	        InitCommand=cmd(xy,frameX2P+5,frameY2P+8+(index*spacing);zoom,gradeFontSize;horizalign,left);
			BeginCommand=function(self)
				self:settext(getGradeStrings(getGradeST(PLAYER_2)))
			end;
			SetCommand=function(self)
				local temp = GetGradeFromPercent(0)
				if curmaxdp ~= 0 then -- bunch of error messages pop up when getgradefrompercent is called with a undefined value
					temp = getGradeST(PLAYER_2)
				end
				self:settext(getGradeStrings(temp))
			end;
			JudgmentMessageCommand=cmd(queuecommand,"Set")
	}
end

return t