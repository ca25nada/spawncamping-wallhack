local t = Def.ActorFrame{}
local topFrameHeight = 20
local bottomFrameHeight = 20

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,0;halign,0;valign,0;zoomto,SCREEN_WIDTH,topFrameHeight;diffuse,color("#000000");diffusealpha,0.8);
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,SCREEN_HEIGHT;halign,0;valign,1;zoomto,SCREEN_WIDTH,bottomFrameHeight;diffuse,color("#000000");diffusealpha,0.8);
}

--[[
if themeConfig:get_data().global.TipType == 2 or themeConfig:get_data().global.TipType == 3 then
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-7;zoom,0.35;settext,getRandomQuotes(themeConfig:get_data().global.TipType);diffuse,getMainColor('highlight');diffusealpha,0;zoomy,0;maxwidth,(SCREEN_WIDTH-350)/0.35;);
		BeginCommand=function(self)
			self:sleep(2)
			self:smooth(1)
			self:diffusealpha(1)
			self:zoomy(0.35)
		end;
	};
end;
--]]

return t