local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:diffusealpha(0)
		self:Center()
		self:zoomto(200,50)
		self:smooth(1)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Loading Profiles"),
	InitCommand = function(self)
		self:Center()
		self:zoom(0.5)
		self:diffusealpha(0)
		self:smooth(1)
		self:diffusealpha(0.8)
		self:diffuseshift()
		self:effectcolor1(color("#FFFFFF")):effectcolor2(getMainColor("positive"))
	end,
	OffCommand=function(self)
		self:linear(0.15):diffusealpha(0)
	end
}

t[#t+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToLoad() then self:sleep(1) end
		self:queuecommand("Load")
	end,
	LoadCommand=function() SCREENMAN:GetTopScreen():Continue() end
}

return t