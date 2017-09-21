
local t = Def.ActorFrame{}

local frameWidth = 300
local frameHeight = 60

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:zoomto(frameWidth,frameHeight)
		self:diffuse(color(colorConfig:get_data().main.frame)):diffusealpha(0.8)
	end
}


return t