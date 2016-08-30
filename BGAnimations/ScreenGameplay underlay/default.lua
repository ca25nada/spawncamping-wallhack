local t = Def.ActorFrame{}
local bareBone = isBareBone()

if bareBone then
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:FullScreen():diffuse(color("#000000"))
		end
	}
else
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,0,0;halign,0;valign,0;zoomto,SCREEN_WIDTH,30;diffuse,color("#00000099");fadebottom,0.8);
	};
end

return t