local t = Def.ActorFrame{}
local bareBone = isBareBone()

t[#t+1] = LoadActor("scoretracking")

t[#t+1] = LoadActor("judgecount")
if not bareBone then
	t[#t+1] = LoadActor("pacemaker")
	t[#t+1] = LoadActor("npscalc")
	t[#t+1] = LoadActor("lifepercent")
end
t[#t+1] = LoadActor("lanecover")

t[#t+1] = LoadActor("fullcombo")

t[#t+1] = LoadActor("progressbar")
t[#t+1] = LoadActor("errorbar")
t[#t+1] = LoadActor("avatar")
t[#t+1] = LoadActor("BPMDisplay")
t[#t+1] = LoadActor("title")




t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-10;zoom,0.35;settext,GAMESTATE:GetSongOptions('ModsLevel_Song');shadowlength,1;);
}
t[#t+1]= LoadActor(THEME:GetPathG("", "pause_menu"))
return t