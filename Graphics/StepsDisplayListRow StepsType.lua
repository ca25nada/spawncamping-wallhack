local t = LoadFont("Common normal")..{
	InitCommand=function(self)
		self:x(30):zoom(0.3):rotationz(90)
	end
}

return t