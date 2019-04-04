return LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(0,0):zoom(0.4):rotationz(90)
	end,
	BeginCommand=function(self)
		self:settext("Autogen")
	end
}