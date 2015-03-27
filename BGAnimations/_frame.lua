local t = Def.ActorFrame{};

local topFrameHeight = 35
local bottomFrameHeight = 54
local borderWidth = 4

--Frames
t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,0;halign,0;valign,0;zoomto,SCREEN_WIDTH,topFrameHeight;diffuse,color("#FFFFFF"););
};


t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,SCREEN_HEIGHT;halign,0;valign,1;zoomto,SCREEN_WIDTH,bottomFrameHeight;diffuse,color("#FFFFFF"););
};


--FrameBorders
t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,topFrameHeight;halign,0;valign,1;zoomto,SCREEN_WIDTH,borderWidth;diffuse,getMainColor(2));
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,SCREEN_HEIGHT-bottomFrameHeight;halign,0;valign,0;zoomto,SCREEN_WIDTH,borderWidth;diffuse,getMainColor(2));
};

return t;