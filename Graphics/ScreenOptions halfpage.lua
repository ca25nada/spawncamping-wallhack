local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand = function(self) self:zoomto(270,390):diffuse(getMainColor("frame")):diffusealpha(0.8) end
}

return t