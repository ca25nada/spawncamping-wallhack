local t = Def.ActorFrame{}
t[#t+1] = LoadActor("_background")
t[#t+1] = LoadActor("_songbg")
t[#t+1] = LoadActor("_particles")

GHETTOGAMESTATE:resetGoalTable() -- refresh the goal table entering SSM
File.Write("nowplaying.txt", " ")

return t