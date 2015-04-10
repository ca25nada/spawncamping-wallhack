local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y-40;zoomto,400,50;diffuse,getMainColor(2);fadeleft,0.4;faderight,0.4;diffusealpha,0);
	OnCommand=cmd(smooth,0.5;diffusealpha,0.7;sleep,1;smooth,0.3;y,SCREEN_CENTER_Y-20;smooth,0.4;diffusealpha,0;y,SCREEN_TOP-500;);
};

t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y-50;zoom,0.5;diffusealpha,0;maxwidth,400/0.45);
	BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayMainTitle(););
	OnCommand=cmd(smooth,0.5;diffusealpha,1;sleep,1;smooth,0.3;y,SCREEN_CENTER_Y-30;smooth,0.4;diffusealpha,0;y,SCREEN_TOP-500;);
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y-35;zoom,0.45;diffusealpha,0;maxwidth,400/0.45);
	BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplaySubTitle());
	OnCommand=cmd(smooth,0.5;diffusealpha,1;sleep,1;smooth,0.3;y,SCREEN_CENTER_Y-15;smooth,0.4;diffusealpha,0;y,SCREEN_TOP-500;);
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y-25;zoom,0.45;;diffusealpha,0);
	BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayArtist());
	OnCommand=cmd(smooth,0.5;diffusealpha,1;sleep,1;smooth,0.3;y,SCREEN_CENTER_Y-5;smooth,0.4;diffusealpha,0;y,SCREEN_TOP-500;);
};

return t