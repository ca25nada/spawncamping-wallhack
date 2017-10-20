local t = Def.ActorFrame{}

t[#t+1] = LoadActor("profilecard") .. {
	InitCommand = function(self)
		self:xy(10,80)
	end;
}

t[#t+1] = LoadActor("ssrbreakdown") .. {
	InitCommand = function(self)
		self:xy(160,295)
	end;
}

t[#t+1] = LoadActor("infobox") .. {
	InitCommand = function(self)
		self:xy(320,30)
	end;
}

return t