local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(FullScreen;diffuse,getMainColor("background");diffusealpha,0);
	OnCommand=cmd(smooth,2;diffusealpha,1);
}

return t