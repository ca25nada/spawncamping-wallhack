local update = false

local hsTable
local rtTable
local rates
local rateIndex
local scoreIndex = 1
local score

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
			scoreIndex = ((scoreIndex)%(#rtTable[rates[rateIndex]]))+1
		elseif params.Name == "PrevScore" then
			scoreIndex = ((scoreIndex-2)%(#rtTable[rates[rateIndex]]))+1
		end;
		score = rtTable[rates[rateIndex]][scoreIndex]
	end;
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	CurrentSongChangedMessageCommand=cmd(queuecommand,"InitScore");
	InitScoreCommand=function(self)
		hsTable = getScoreList(PLAYER_1)
		if hsTable ~= nil then
			rtTable = getRateTable(hsTable)
			rates,rateIndex = getUsedRates(rtTable)
			score = rtTable[rates[rateIndex]][scoreIndex]
		end;
	end;
};

local frameX = 10
local frameY = 45
local frameWidth = capWideScale(320,400)
local frameHeight = 350
local fontScale = 0.4
local distY = 15
local offsetX1 = 100
local offsetX2 = 10
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

--[[
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+5,frameY+offsetY+9;zoom,0.6;halign,0;diffuse,getMainColor(1));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext("is nil "..tostring(rates==nil))
		--self:settext(rates[1])
		--self:settext(tostring(rateCompatator("1.1x","0.5x")))
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};
--]]

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+frameWidth-offsetX2,frameY+offsetY+50;zoom,0.4;halign,1;);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settextf("Rate %s - Showing %d/%d",rates[rateIndex],scoreIndex,#rtTable[rates[rateIndex]])
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};



local function makeText(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,offsetX1/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(rates[index])
			if index == rateIndex then
				self:diffuse(getMainColor(1))
			else
				self:diffuse(color("#FFFFFF"))
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};
end;

for i=1,3 do
	t[#t+1] =makeText(i)
end;

return t