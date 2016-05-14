local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand = function(self) self:zoomto(272,390):diffuse(color("#000000")):diffusealpha(0.8) end
}

return t