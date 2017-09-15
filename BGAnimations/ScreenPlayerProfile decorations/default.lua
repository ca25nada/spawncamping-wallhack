local t = Def.ActorFrame{}

t[#t+1] = LoadActor("profilecard") .. {
	InitCommand = function(self)
		self:xy(25,100)
	end;
}

t[#t+1] = LoadActor("ssrbreakdown") .. {
	InitCommand = function(self)
		self:xy(175,300)
	end;
}

t[#t+1] = LoadActor("infobox") .. {
	InitCommand = function(self)
		self:xy(350,50)
	end;
}

return t