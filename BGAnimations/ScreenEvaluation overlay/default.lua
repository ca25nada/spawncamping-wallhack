local t = Def.ActorFrame{}

t[#t+1] = LoadActor("../_frame");
t[#t+1] = LoadActor("avatar");
--t[#t+1] = LoadActor("temp");

t[#t+1] = LoadFont("Common Large")..{
	InitCommand=cmd(xy,5,32;halign,0;valign,1;zoom,0.55;diffuse,getMainColor(2);settext,"Results:";);
}

t[#t+1] = LoadFont("Common Large")..{
	InitCommand=cmd(xy,SCREEN_CENTER_X+20,70;halign,0;zoom,0.50;settext,"A SONG TITLE OR SOMETHING";);
}

return t