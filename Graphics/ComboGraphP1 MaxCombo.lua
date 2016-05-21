return Def.Quad{
	InitCommand=cmd(setsize,1,8;diffuse,getMainColor('highlight'));
	BeginCommand=cmd(glowshift;effectcolor1,color("1,1,1,0.325");effectcolor2,color("1,1,1,0"););
};