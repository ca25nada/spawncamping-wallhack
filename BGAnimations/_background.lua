return Def.Quad{
	InitCommand=function(self)
		self:FullScreen():diffuse(getMainColor("background"))
	end
}