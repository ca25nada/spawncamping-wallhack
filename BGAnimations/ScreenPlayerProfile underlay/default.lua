local t = Def.ActorFrame{}

-- This prevents pressing buttons on the parent screen.
t[#t+1] = quadButton(5) .. {
	InitCommand = function(self)
		self:diffusealpha(0.8)
		self:FullScreen()
	end	
}

return t