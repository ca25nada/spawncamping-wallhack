return LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,0,0;zoom,0.4;rotationz,90);
	BeginCommand=function(self)
		self:settext("Autogen")
	end;
};