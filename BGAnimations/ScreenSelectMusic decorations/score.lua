local update = false

local hsTable
local rtTable
local rates
local rateIndex = 1
local scoreIndex = 1
local score
local pn = PLAYER_1

local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set";visible,false);
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=function(self)
		self:bouncebegin(0.2);
		self:xy(0,0);
	end;
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 2 then
			self:queuecommand("On");
			self:visible(true)
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	TabChangedMessageCommand=cmd(queuecommand,"Set");
	CodeMessageCommand=function(self,params)
		if params.Name == "NextRate" then
			rateIndex = ((rateIndex)%(#rates))+1
			scoreIndex = 1
		elseif params.Name == "PrevRate" then
			rateIndex = ((rateIndex-2)%(#rates))+1
			scoreIndex = 1
		elseif params.Name == "NextScore" then
			if rtTable[rates[rateIndex]] ~= nil then
				scoreIndex = ((scoreIndex)%(#rtTable[rates[rateIndex]]))+1
			end
		elseif params.Name == "PrevScore" then
			if rtTable[rates[rateIndex]] ~= nil then
				scoreIndex = ((scoreIndex-2)%(#rtTable[rates[rateIndex]]))+1
			end
		end;
		score = rtTable[rates[rateIndex]][scoreIndex]
		MESSAGEMAN:Broadcast("ScoreUpdate")
	end;
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	CurrentSongChangedMessageCommand=cmd(queuecommand,"InitScore");
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"InitScore");
	CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"InitScore");
	InitScoreCommand=function(self)
		if GAMESTATE:GetCurrentSong() ~= nil then
			hsTable = getScoreList(pn)
			if hsTable ~= nil and hsTable[1] ~= nil then
				rtTable = getRateTable(hsTable)
				rates,rateIndex = getUsedRates(rtTable)
				scoreIndex = 1
				score = rtTable[rates[rateIndex]][scoreIndex]
			else
				rtTable = {}
				rates,rateIndex = {"1.0x"},1
				scoreIndex = 1
				score = nil
			end;
		else
			hsTable = {}
			rtTable = {}
			rates,rateIndex = {"1.0x"},1
			scoreIndex = 1
			score = nil
		end;
		MESSAGEMAN:Broadcast("ScoreUpdate")
	end;
};

local frameX = 10
local frameY = 45
local frameWidth = capWideScale(320,400)
local frameHeight = 350
local fontScale = 0.4
local offsetX = 10
local offsetY = 20


t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;halign,0;valign,0;diffuse,color("#333333CC"));

};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,offsetY;halign,0;valign,0;diffuse,color("#FFFFFF"));
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+5,frameY+offsetY-9;zoom,0.6;halign,0;diffuse,getMainColor(1));
	BeginCommand=cmd(settext,"Score Info")
};

t[#t+1] = LoadFont("Common Large")..{
	Name="Grades";
	InitCommand=cmd(xy,frameX+offsetX,frameY+offsetY+20;zoom,0.6;halign,0;maxwidth,110/0.6);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if score ~= nil then
			self:settext(THEME:GetString("Grade",ToEnumShortString(score:GetGrade())))
		else
			self:settext("")
		end;
	end;
	ScoreUpdateMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	Name="ClearType";
	InitCommand=cmd(xy,frameX+offsetX,frameY+offsetY+43;zoom,0.5;halign,0);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if score ~= nil then
			self:settext(getClearTypeFromScore(pn,score,0))
		else
			self:settext("")
		end;
	end;
	ScoreUpdateMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	Name="StepsAndMeter";
	InitCommand=cmd(xy,frameX+frameWidth-offsetX,frameY+offsetY+10;zoom,0.5;halign,1;);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(pn)
		local diff = getDifficulty(steps:GetDifficulty())
		local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
		local meter = steps:GetMeter()
		self:settext(stype.." "..diff.." "..meter)
		self:diffuse(getDifficultyColor(diff))
	end;
	ScoreUpdateMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+frameWidth-offsetX,frameY+frameHeight-10;zoom,0.4;halign,1;);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if hsTable ~= nil and rates ~= nil and rtTable[rates[rateIndex]] ~= nil then
			self:settextf("Rate %s - Showing %d/%d",rates[rateIndex],scoreIndex,#rtTable[rates[rateIndex]])
		else
			self:settext("No Scores Saved")
		end;
	end;
	ScoreUpdateMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = Def.Quad{
	Name="ScrollBar";
	InitCommand=cmd(xy,frameX+frameWidth,frameY+frameHeight;zoomto,4,0;halign,1;valign,1;diffuse,getMainColor(1));
	BeginCommand=cmd(queuecommand,"Set");
	ScoreUpdateMessageCommand=cmd(queuecommand,"Set");
	SetCommand=function(self,params)
		self:finishtweening()
		self:smooth(0.2)
		if hsTable ~= nil and rates ~= nil and rtTable[rates[rateIndex]] ~= nil then
			self:zoomy(((frameHeight-offsetY)/#rtTable[rates[rateIndex]]))
			self:y(frameY+offsetY+(((frameHeight-offsetY)/#rtTable[rates[rateIndex]])*scoreIndex))
		else
			self:zoomy(frameHeight-offsetY)
			self:y(frameY+frameHeight)
		end;
	end;
};


local function makeText(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth-offsetX,frameY+offsetY+15+(index*15);zoom,fontScale;halign,1;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local count = 0
			if rtTable[rates[index]] ~= nil then
				count = #rtTable[rates[index]]
			end;
			if index <= #rates then
				self:settextf("%s (%d)",rates[index],count)
				if index == rateIndex then
					self:diffuse(getMainColor(1))
				else
					self:diffuse(color("#FFFFFF"))
				end;
			else
				self:settext("")
			end;
		end;
		ScoreUpdateMessageCommand=cmd(queuecommand,"Set");
	};
end;

for i=1,10 do
	t[#t+1] =makeText(i)
end;

return t