--IIDX-esque scoregraph.
--Supports arbituary bar dimensions, number of bars so far. (although none of them are in preferences atm.)
--Support for arbituary display range to be added eventually.

--Disable for Doubles mode? idk

local ghostType
local target


local frameWidth = 105
local frameHeight = SCREEN_HEIGHT

local frameX = SCREEN_WIDTH-frameWidth
local frameY = 0

local barY = 420-- Starting point/bottom of graph
local barCount = 2 -- Number of graphs
local barWidth = 0.6
local barTrim = 0 -- Final width of each graph = ((frameWidth/barCount)*barWidth) - barTrim
local barHeight = 350 -- Max Height of graphs

local textSpacing = 10
local bottomTextY = barY+frameY+10
local topTextY = frameY+barY-barHeight-10-(textSpacing*barCount)

local enabled = GAMESTATE:GetNumPlayersEnabled() == 1 

local player = GAMESTATE:GetEnabledPlayers()[1]
if player == PLAYER_1 then
	ghostType = playerConfig:get_data(pn_to_profile_slot(player)).GhostScoreType; -- 0 = off, 1 = DP, 2 = PS, 3 = MIGS
	target = playerConfig:get_data(pn_to_profile_slot(player)).GhostTarget/100; -- target score from 0% to 100%.
	enabled =  enabled and playerConfig:get_data(pn_to_profile_slot(player)).PaceMaker
elseif player == PLAYER_2 then
	ghostType = playerConfig:get_data(pn_to_profile_slot(player)).GhostScoreType; -- 0 = off, 1 = DP, 2 = PS, 3 = MIGS
	target = playerConfig:get_data(pn_to_profile_slot(player)).GhostTarget/100; -- target score from 0% to 100%.
	enabled =  enabled and playerConfig:get_data(pn_to_profile_slot(player)).PaceMaker
	frameX = 0
end

--if ghost score is off, inherit from default scoring type.
if ghostType == nil or ghostType == 0 then
	ghostType = themeConfig:get_data().global.DefaultScoreType
end

local profile = GetPlayerOrMachineProfile(player)

--Strings and the percent value for the goal/grade
local markerPoints = { --DP/PS/MIGS in that order.
	[1] = {Grade_Tier02 = THEME:GetMetric("PlayerStageStats", "GradePercentTier02"), 
			Grade_Tier03 = THEME:GetMetric("PlayerStageStats", "GradePercentTier03") , 
			Grade_Tier04 = THEME:GetMetric("PlayerStageStats", "GradePercentTier04") , 
			Grade_Tier05 = THEME:GetMetric("PlayerStageStats", "GradePercentTier05") , 
			Grade_Tier06 = THEME:GetMetric("PlayerStageStats", "GradePercentTier06") , 
			Grade_Tier07=0 },

	[2] = {["100%"]=1,["90%"]=0.9,["80%"]=0.8,["70%"]=0.7,["60%"]=0.6,["50%"]=0.5,[""]=0},
	[3] = {["100%"]=1,["90%"]=0.9,["80%"]=0.8,["70%"]=0.7,["60%"]=0.6,["50%"]=0.5,[""]=0},
}

-- Dynamic Graph
-- Represents the current score/possible score for the specified scoreType
function currentScoreGraph(index,scoreType,color)
	local t = Def.ActorFrame{}
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoomto,(frameWidth/barCount)*barWidth,1;valign,1;diffuse,color;diffusealpha,0.7;);
		SetCommand=function(self)
			local curScore = getCurScoreST(player,scoreType)
			local maxScore = getMaxScoreST(player,scoreType)
			if maxScore <= 0 then
				self:zoomy(1)
			else
				self:zoomy(math.max(1,barHeight*(curScore/maxScore)))
			end;
		end;
		JudgmentMessageCommand=cmd(queuecommand,"Set");
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth/2,bottomTextY+textSpacing*(index-1);zoom,0.35;maxwidth,frameWidth/0.35;diffuse,color;settext,"Current Score";)
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,((frameWidth*0.8)-2)/0.35;halign,0;diffuse,color;);
		BeginCommand=function(self)
			local text = profile:GetDisplayName();
			if text == "" then
				self:settext("Machine Profile")
			else
				self:settext(text)
			end;
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth-2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,25/0.35;halign,1;settext,"0");
		SetCommand=function(self)
			local curScore = getCurScoreST(player,scoreType)
			self:settext(curScore)
		end;
		JudgmentMessageCommand=cmd(queuecommand,"Set");
	};
	return t
end;

-- Static Graph
-- Represents the best score achieved for the specified scoreType
function bestScoreGraph(index,scoreType,color)
	local t = Def.ActorFrame{}
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoomto,(frameWidth/barCount)*barWidth,1;valign,1;diffuse,color;diffusealpha,0.2;);
		BeginCommand=function(self)
			local bestScore = getBestScore(player,0,scoreType)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:zoomy(math.max(1,barHeight*(bestScore/maxScore)))
			end;
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY-12;zoom,0.35;maxwidth,((frameWidth/barCount)*barWidth)/0.35;diffusealpha,0);
		BeginCommand=function(self)
			local bestScore = getBestScore(player,0,scoreType)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			self:settext("Best\n"..bestScore)
			self:diffusealpha(1)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:y(frameY+barY-math.max(12,(barHeight*(bestScore/maxScore))))
			end;
			self:sleep(0.5)
			self:smooth(0.5)
			self:diffusealpha(0)
		end;
	};
	return t
end;

-- Dynamic Graph
-- Represents the current target score for the specified scoreType
function targetScoreGraph(index,scoreType,color)
	local t = Def.ActorFrame{}
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoomto,(frameWidth/barCount)*barWidth,1;valign,1;diffuse,color;diffusealpha,0.7;);
		SetCommand=function(self)
			local curScore = math.ceil(getCurMaxScoreST(player,scoreType)*target)
			local maxScore = getMaxScoreST(player,scoreType)
			if maxScore <= 0 then
				self:zoomy(1)
			else
				self:zoomy(math.max(1,barHeight*(curScore/maxScore)))
			end;
		end;
		JudgmentMessageCommand=cmd(queuecommand,"Set");
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth/2,bottomTextY+textSpacing*(index-1);zoom,0.35;maxwidth,frameWidth/0.35;diffuse,color;settext,"Target Score");
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,((frameWidth*0.8)-2)/0.35;halign,0;diffuse,color;settextf,"%s %0.2f%%",getScoreTypeText(ghostType),target*100);
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth-2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,25/0.35;halign,1;settext,"0");
		SetCommand=function(self)
			local curScore = math.ceil(getCurMaxScoreST(player,scoreType)*target)
			self:settext(curScore)
		end;
		JudgmentMessageCommand=cmd(queuecommand,"Set");
	};

	return t
end;

-- Static Graph
-- Represents the total target score for the specified scoreType
function targetMaxGraph(index,scoreType,color)
	local t = Def.ActorFrame{}
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoomto,(frameWidth/barCount)*barWidth,1;valign,1;diffuse,color;diffusealpha,0.2;);
		BeginCommand=function(self)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:zoomy(math.max(1,barHeight*(math.ceil(maxScore*target)/maxScore)))
			end;
		end;
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoom,0.35;maxwidth,((frameWidth/barCount)*barWidth)/0.35;diffusealpha,0);
		BeginCommand=function(self)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			self:settext("Target\n"..math.ceil(maxScore*target))
			self:diffusealpha(1)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:y(frameY+barY-math.max(12,(barHeight*(math.ceil(maxScore*target)/maxScore))))
			end;
			self:sleep(0.5)
			self:smooth(0.5)
			self:diffusealpha(0)
		end;
	};
	return t
end;

--The Background markers with the lines corresponding to the minimum required for the grade,etc.
function markers(scoreType,showMessage)
	local t = Def.ActorFrame{
		InitCommand=cmd(diffusealpha,0.3);
	}
	for k,v in pairs(markerPoints[scoreType]) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,frameX,frameY+barY-(barHeight*v);zoomto,frameWidth,2;halign,0);
			JudgmentMessageCommand=function(self)
				local percent = getCurScoreST(player,scoreType)/getMaxScoreST(player,scoreType)
				if percent >= v then
					self:diffuse(getMainColor(1))
				end;
			end;
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX,frameY+barY-(barHeight*v)-2;settext,getGradeStrings(k);zoom,0.3;halign,0;valign,1;);
			JudgmentMessageCommand=function(self)
				local percent = getCurScoreST(player,scoreType)/getMaxScoreST(player,scoreType)
				if percent >= v then
					self:diffuseshift()
					if scoreType == 1 then 
						self:effectcolor1(getGradeColor(k))
					else
						self:effectcolor1(getMainColor(1))
					end;
					self:effectcolor2(color("FFFFFF"))
				end;
			end;
		};
	end;
	return t

end;

--Make the graph...!
local t = Def.ActorFrame{}
if enabled then
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;halign,0;valign,0;diffuse,color("#333333");diffusealpha,0.7;)
	};
	t[#t+1] = targetMaxGraph(2,ghostType,getPaceMakerColor("Target"))
	t[#t+1] = bestScoreGraph(1,ghostType,getPaceMakerColor("Current"))
	t[#t+1] = currentScoreGraph(1,ghostType,getPaceMakerColor("Current"))
	t[#t+1] = targetScoreGraph(2,ghostType,getPaceMakerColor("Target"))
	t[#t+1] = markers(ghostType,true)
end;


return t