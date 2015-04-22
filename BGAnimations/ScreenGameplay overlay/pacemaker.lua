local ghostTypeP1 = tonumber(GetUserPref("GhostScoreTypeP1")); -- 1 = off, 2 = DP, 3 = PS, 4 = MIGS
local targetP1 = (tonumber(GetUserPref("GhostTargetP1") or "0")+1)/100; -- target score from 0% to 100%.

local ghostTypeP2 = tonumber(GetUserPref("GhostScoreTypeP2")); -- 1 = off, 2 = DP, 3 = PS, 4 = MIGS
local targetP2 = (tonumber(GetUserPref("GhostTargetP2") or "0")+1)/100; -- target score from 0% to 100%.

local enabled = true

local player = PLAYER_1

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

local markerPoints = { --DP/PS/MIGS in that order.
	[1] = {["AAA"] = THEME:GetMetric("PlayerStageStats", "GradePercentTier02"), 
			["AA"] = THEME:GetMetric("PlayerStageStats", "GradePercentTier03") , 
			["A"] = THEME:GetMetric("PlayerStageStats", "GradePercentTier04") , 
			["B"] = THEME:GetMetric("PlayerStageStats", "GradePercentTier05") , 
			["C"]=THEME:GetMetric("PlayerStageStats", "GradePercentTier06") , 
			[""]=0 },

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
		InitCommand=cmd(xy,frameX+frameWidth/2,bottomTextY+textSpacing*(index-1);zoom,0.35;maxwidth,frameWidth/0.35;diffuse,color;settext,"BOTTOM TEXT 1";)
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,((frameWidth*0.8)-2)/0.35;halign,0;diffuse,color;settext,"TOP TEXT 1";)
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
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoomto,(frameWidth/barCount)*barWidth,1;valign,1;diffuse,color;diffusealpha,0.1;);
		BeginCommand=function(self)
			local bestScore = getHighestScore(player,0,scoreType)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:zoomy(math.max(1,barHeight*(bestScore/maxScore)))
			end;
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
			local curScore = math.ceil(getCurMaxScoreST(player,scoreType)*targetP1)
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
		InitCommand=cmd(xy,frameX+frameWidth/2,bottomTextY+textSpacing*(index-1);zoom,0.35;maxwidth,frameWidth/0.35;diffuse,color;settext,"BOTTOM TEXT 2";)
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,((frameWidth*0.8)-2)/0.35;halign,0;diffuse,color;settext,"TOP TEXT 2";)
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth-2,topTextY+textSpacing*(index-1);zoom,0.35;maxwidth,25/0.35;halign,1;settext,"0");
		SetCommand=function(self)
			local curScore = math.ceil(getCurMaxScoreST(player,scoreType)*targetP1)
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
		InitCommand=cmd(xy,frameX+((1+(2*(index-1)))*(frameWidth/(barCount*2))),frameY+barY;zoomto,(frameWidth/barCount)*barWidth,1;valign,1;diffuse,color;diffusealpha,0.1;);
		BeginCommand=function(self)
			local maxScore = getMaxScoreST(player,scoreType)
			self:smooth(1.5)
			if maxScore <= 0 then
				self:visible(false)
			else
				self:zoomy(math.max(1,barHeight*(math.ceil(maxScore*targetP1)/maxScore)))
			end;
		end;
	};
	return t
end;

function markers(scoreType,showMessage)
	local t = Def.ActorFrame{
		InitCommand=cmd(diffusealpha,0.3);
	}
	for k,v in pairs(markerPoints[scoreType]) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,frameX,frameY+barY-(barHeight*v);zoomto,frameWidth,2;halign,0);
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX,frameY+barY-(barHeight*v)-2;settext,k;zoom,0.3;halign,0;valign,1;)
		};
	end;
	return t

end;

local t = Def.ActorFrame{}

if enabled then
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;halign,0;valign,0;diffuse,color("#333333");diffusealpha,0.7;)
	};
	t[#t+1] = targetMaxGraph(2,ghostTypeP1-1,getMainColor(2))
	t[#t+1] = bestScoreGraph(1,ghostTypeP1-1,getMainColor(1))
	t[#t+1] = currentScoreGraph(1,ghostTypeP1-1,getMainColor(1))
	t[#t+1] = targetScoreGraph(2,ghostTypeP1-1,getMainColor(2))
	t[#t+1] = markers(ghostTypeP1-1,true)
end;


return t