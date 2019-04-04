local t = Def.ActorFrame{}
t[#t+1] = LoadActor("_background")
t[#t+1] = LoadActor("_particles")
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:FullScreen()
		self:Center()
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