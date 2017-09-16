local t = Def.ActorFrame{}

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:diffusealpha(0.8)
		self:FullScreen()
	end	
}

return t