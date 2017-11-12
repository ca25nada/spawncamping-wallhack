local t = Def.ActorFrame{}


t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(60,60):diffuse(getMainColor("frame")):diffusealpha(0.7):rotationz(90)
	end;
};

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:x(-10):zoomto(50,25):diffuse(color("#ffffff")):diffusealpha(0.5):rotationz(90)
	end;
};



return t