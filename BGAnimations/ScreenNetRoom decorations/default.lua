local t = Def.ActorFrame{}

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:rotationz(-90):xy(SCREEN_CENTER_X/2-WideScale(get43size(150),150),270)
		self:delayedFadeIn(5)
	end,
	OffCommand=function(self)
		self:stoptweening()
		self:sleep(0.025)
		self:smooth(0.2)
		self:diffusealpha(0) 
	end,

	OnCommand=function(self)
		wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
	end,
}

return t