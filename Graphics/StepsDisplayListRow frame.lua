t = Def.ActorFrame{}


t[#t+1] = Def.Quad{
	InitCommand=cmd(zoomto,60,60;diffuse,color("#111111");diffusealpha,0.7;rotationz,90);
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(x,-10;zoomto,50,25;diffuse,color("#ffffff");diffusealpha,0.5;rotationz,90);
};



return t