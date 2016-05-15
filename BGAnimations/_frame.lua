local t = Def.ActorFrame{}
local topFrameHeight = 20
local bottomFrameHeight = 20

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,0)
		self:valign(0)
		self:zoomto(SCREEN_WIDTH,topFrameHeight)
		self:diffuse(color("#000000")):diffusealpha(0.8)
	end;
	OnCommand = function(self)
		self:zoomy(0)
		self:smooth(0.5)
		self:zoomy(topFrameHeight)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:zoomy(0)
	end;
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_HEIGHT)
		self:valign(1)
		self:zoomto(SCREEN_WIDTH,bottomFrameHeight)
		self:diffuse(color("#000000")):diffusealpha(0.8)
	end;
	OnCommand = function(self)
		self:zoomy(0)
		self:smooth(0.5)
		self:zoomy(bottomFrameHeight)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:zoomy(0)
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	Name = "currentTime";
	InitCommand=cmd(xy,SCREEN_WIDTH-5,SCREEN_HEIGHT-bottomFrameHeight/2;zoom,0.45;halign,1);
	OnCommand = function(self)
		self:y(SCREEN_HEIGHT+bottomFrameHeight/2)
		self:smooth(0.5)
		self:y(SCREEN_HEIGHT-bottomFrameHeight/2)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(SCREEN_HEIGHT+bottomFrameHeight/2)
	end;
};

local function Update(self)
	local year = Year()
	local month = MonthOfYear()+1
	local day = DayOfMonth()
	local hour = Hour()
	local minute = Minute()
	local second = Second()
	self:GetChild("currentTime"):settextf("%04d-%02d-%02d %02d:%02d:%02d",year,month,day,hour,minute,second)
end;

t.InitCommand=cmd(SetUpdateFunction,Update)



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