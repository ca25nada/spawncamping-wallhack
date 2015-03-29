local t = Def.ActorFrame{};





t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_WIDTH-350,0;halign,0;valign,0;zoomto,SCREEN_WIDTH-350,SCREEN_HEIGHT;diffuse,color("#FFFFFF33"));
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_WIDTH-350,0;halign,0;valign,0;zoomto,4,SCREEN_HEIGHT;diffuse,color("#FFFFFF"));
};


return t