local t = Def.ActorFrame{}

t[#t+1] = Def.Actor{
	CodeMessageCommand=function(self,params)
		if params.Name == "AvatarShow" then
			SCREENMAN:AddNewScreenToTop("ScreenAvatarSwitch")
		end
	end
}
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("currentsort")


t[#t+1] = LoadActor("../_cursor")
t[#t+1] = LoadActor("../_halppls")

return t