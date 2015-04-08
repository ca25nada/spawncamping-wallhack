local t = Def.ActorFrame{}
if not(GAMESTATE:IsCourseMode()) then
	t[#t+1] = LoadSongBackground()..{
		InitCommand=cmd(scaletocover,0,0,SCREEN_WIDTH,SCREEN_BOTTOM;diffusealpha,0.3;);
	};
end;

return t