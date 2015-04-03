local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set";visible,false);
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 4 then
			self:queuecommand("On");
			self:visible(true)
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

local frameX = 10
local frameY = 45
local frameWidth = 400
local frameHeight = 350
local fontScale = 0.4
local distY = 15
local offsetX1 = 100
local offsetX2 = 10
local offsetY = 20

local stringList1 = {
	[1] = "StepMania Version:",
	[2] = "Build Date:",
	[3] = "Theme Version:",
	[4] = "Global Offset:",
	[5]	= "Life Difficulty:",
	[6] = "Timing Difficulty:",
	[7] = "Max Machine Scores:",
	[8] = "Max Personal Scores:",
}

local stringList2 = {
	[1] = ProductFamily().." "..ProductVersion(),
	[2] = VersionDate().." "..VersionTime(),
	[3] = getThemeName().." "..getThemeVersion(),
	[4] = string.format("%2.4f",(PREFSMAN:GetPreference("GlobalOffsetSeconds") or 0)*1000).." ms",
	[5] = GetLifeDifficulty(),
	[6] = GetTimingDifficulty(),
	[7] = PREFSMAN:GetPreference("MaxHighScoresPerListForMachine") or 0,
	[8] = PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer") or 0,
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;halign,0;valign,0;diffuse,color("#333333"));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,offsetY;halign,0;valign,0;diffuse,color("#FFFFFF"));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+5,frameY+offsetY-9;zoom,0.6;halign,0;diffuse,getMainColor(1));
	BeginCommand=cmd(settext,"Other Info")
};

local function makeText1(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,offsetX1/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList1[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

local function makeText2(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList2[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

for i=1,#stringList1 do 
	t[#t+1] = makeText1(i)
	t[#t+1] = makeText2(i)
end;


return t