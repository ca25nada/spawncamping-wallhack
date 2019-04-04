local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(SCREEN_WIDTH*0.8,400)
		self:diffuse(getMainColor("frame")):diffusealpha(0)
	end,
	OnCommand = function(self)
		self:smooth(0.5)
		self:diffusealpha(0.8)
	end,
	OffCommand = function(self)
		self:smooth(0.5)
		self:diffusealpha(0)
	end
}

return t