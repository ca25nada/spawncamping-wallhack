local t = Def.ActorFrame {
    BeginCommand = function(self)
        SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
    end
}
t[#t+1] = LoadActor("../_background")
t[#t+1] = LoadActor("../_particles")

return t