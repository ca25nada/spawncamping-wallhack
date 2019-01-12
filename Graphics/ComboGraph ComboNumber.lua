return LoadFont("Common normal") .. {
	InitCommand=function(self)
		self:zoom(0.35):diffuse(color("#FFFFFF"))
	end
}