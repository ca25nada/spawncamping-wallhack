local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set";visible,false);
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;diffusealpha,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;diffusealpha,1;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 5 then
			self:queuecommand("On");
			self:visible(true)
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	TabChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
};

local frameX = 18
local frameY = 30
local frameWidth = capWideScale(get43size(390),390)
local frameHeight = 320
local fontScale = 0.4
local distY = 15
local offsetX1 = 100
local offsetX2 = 10
local offsetY = 20

local stringList = {
	{THEME:GetString("ScreenSelectMusic","OtherInfoSMVersion")..":",		ProductFamily().." "..ProductVersion()},
	{THEME:GetString("ScreenSelectMusic","OtherInfoSMBuildDate")..":",				VersionDate().." "..VersionTime()},
	{THEME:GetString("ScreenSelectMusic","OtherInfoThemeVersion")..":",			getThemeName().." "..getThemeVersion()},
	{THEME:GetString("ScreenSelectMusic","OtherInfoTotalSongs")..":",			SONGMAN:GetNumSongs().." Songs in "..SONGMAN:GetNumSongGroups().." Groups"},
	{THEME:GetString("ScreenSelectMusic","OtherInfoTotalCourses")..":",			SONGMAN:GetNumCourses().." Courses in "..SONGMAN:GetNumCourseGroups().." Groups"},
	{THEME:GetString("ScreenSelectMusic","OtherInfoGlobalOffset")..":",			string.format("%2.4f",(PREFSMAN:GetPreference("GlobalOffsetSeconds") or 0)*1000).." ms"},
	{THEME:GetString("ScreenSelectMusic","OtherInfoLifeDifficulty")..":",			GetLifeDifficulty()},
	{THEME:GetString("ScreenSelectMusic","OtherInfoTimingDifficulty")..":",		GetTimingDifficulty()},
	{THEME:GetString("ScreenSelectMusic","OtherInfoMaxMachineScores")..":",		PREFSMAN:GetPreference("MaxHighScoresPerListForMachine") or 0},
	{THEME:GetString("ScreenSelectMusic","OtherInfoMaxPersonalScores")..":",		PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer") or 0}
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY+offsetY;zoomto,frameWidth,frameHeight-offsetY;halign,0;valign,0;diffuse,color("#000000");diffusealpha,0.6);
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,offsetY;halign,0;valign,0;diffuse,color("#000000");diffusealpha,0.8);
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+5,frameY+offsetY-9;zoom,0.4;halign,0;diffuse,getMainColor('highlight'));
	BeginCommand=cmd(settext,THEME:GetString("ScreenSelectMusic","OtherInfoHeader"))
};

local function makeText1(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,offsetX1/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList[index][1])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

local function makeText2(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList[index][2])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

for i=1,#stringList do 
	t[#t+1] = makeText1(i)
	t[#t+1] = makeText2(i)
end;


return t