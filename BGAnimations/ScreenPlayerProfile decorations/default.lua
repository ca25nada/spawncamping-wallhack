local t = Def.ActorFrame{}

t[#t+1] = LoadActor("profilecard") .. {
	InitCommand = function(self)
		self:xy(10,80)
		self:diffusealpha(0)
		self:smooth(0.2)
		self:diffusealpha(1)
	end;
}

t[#t+1] = LoadActor("ssrbreakdown") .. {
	InitCommand = function(self)
		self:xy(160,295)
		self:diffusealpha(0)
		self:sleep(0.025)
		self:smooth(0.2)
		self:diffusealpha(1)
	end;
}

t[#t+1] = LoadActor("infobox") .. {
	InitCommand = function(self)
		self:xy(320,30)
		self:diffusealpha(0)
		self:sleep(0.05)
		self:smooth(0.2)
		self:diffusealpha(1)
	end;
}

return t