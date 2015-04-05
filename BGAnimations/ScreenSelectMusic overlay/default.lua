local t = Def.ActorFrame{}

t[#t+1] = LoadActor("../_frame");
t[#t+1] = LoadActor("avatar");
t[#t+1] = LoadActor("currentsort");

t[#t+1] = LoadFont("Common Large")..{
	InitCommand=cmd(xy,5,32;halign,0;valign,1;zoom,0.55;diffuse,getMainColor(2);settext,"Select Music:";);
}

return t