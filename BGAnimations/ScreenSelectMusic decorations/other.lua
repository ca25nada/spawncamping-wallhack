local update = false
local t = Def.ActorFrame{
	InitCommand = function(self) self:xy(0,-100):diffusealpha(0):visible(false) end;
	BeginCommand = cmd(queuecommand,"Set");
	OffCommand = function(self) self:finishtweening() self:bouncy(0.3) self:xy(0,-100):diffusealpha(0) end;
	OnCommand = function(self) self:bouncy(0.3) self:xy(0,0):diffusealpha(1) end;
	SetCommand = function(self)
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
	TabChangedMessageCommand = cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand = cmd(queuecommand,"Set");
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
	{THEME:GetString("ScreenSelectMusic","OtherInfoGlobalOffset")..":",			string.format("%2.4f",(PREFSMAN:GetPreference("GlobalOffsetSeconds") or 0)*1000).." ms"},
	{THEME:GetString("ScreenSelectMusic","OtherInfoLifeDifficulty")..":",			GetLifeDifficulty()},
	{THEME:GetString("ScreenSelectMusic","OtherInfoTimingDifficulty")..":",		GetTimingDifficulty()},
}

t[#t+1] = Def.Quad{
	InitCommand = cmd(xy,frameX,frameY+offsetY;zoomto,frameWidth,frameHeight-offsetY;halign,0;valign,0;diffuse,getMainColor("frame");diffusealpha,0.6);
};

t[#t+1] = Def.Quad{
	InitCommand = cmd(xy,frameX,frameY;zoomto,frameWidth,offsetY;halign,0;valign,0;diffuse,getMainColor("frame");diffusealpha,0.8);
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = cmd(xy,frameX+5,frameY+offsetY-9;zoom,0.45;halign,0;diffuse,getMainColor('highlight'));
	BeginCommand = cmd(settext,THEME:GetString("ScreenSelectMusic","OtherInfoHeader"))
};

local function makeText1(index)
	return LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameX+offsetX2,frameY+offsetY+(index*distY))
			self:zoom(fontScale):maxwidth(offsetX1/fontScale)
			self:halign(0)
			self:settext(stringList[index][1])
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end
	};
end;

local function makeText2(index)
	return LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameX+offsetX1+offsetX2*2,frameY+offsetY+(index*distY))
			self:zoom(fontScale):maxwidth((frameWidth-offsetX1)/fontScale)
			self:halign(0)
			self:settext(stringList[index][2])
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end
	};
end;

for i=1,#stringList do 
	t[#t+1] = makeText1(i)
	t[#t+1] = makeText2(i)
end;


return t