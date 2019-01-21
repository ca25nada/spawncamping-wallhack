local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(150,40)
		self:Center()
		self:diffuse(getMainColor("frame")):diffusealpha(0)
	end,
	OnCommand = function(self)
		self:smooth(0.2)
		self:diffusealpha(0.8)
	end,
	OffCommand = function(self)
		self:smooth(0.2)
		self:diffusealpha(0)
	end
}

return t