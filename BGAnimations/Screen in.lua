local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:FullScreen():diffuse(getMainColor("transition")):diffusealpha(0):smooth(0.1):diffusealpha(1)
	end,
	OnCommand=function(self)
		self:smooth(0.1):diffusealpha(0)
	end
}

return t