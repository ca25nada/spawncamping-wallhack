local t =  Def.ActorFrame{
}


t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(capWideScale(get43size(340),340),44)
		self:halign(0)
	end,
	SetCommand = function(self)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.9)
	end,
	BeginCommand = function(self) self:queuecommand('Set') end,
	OffCommand = function(self) self:visible(false) end
}


return t
