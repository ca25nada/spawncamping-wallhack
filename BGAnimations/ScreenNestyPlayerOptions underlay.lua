local t = Def.ActorFrame{}
t[#t+1] = Def.Quad{
	InitCommand=cmd(FullScreen;diffuse,color("#FFFFFF"));
}
t[#t+1] = LoadActor("_songbg")
return t