local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(FullScreen;diffuse,getMainColor("background");diffusealpha,1);
	OnCommand=cmd(smooth,0.2;diffusealpha,0);
}

return t