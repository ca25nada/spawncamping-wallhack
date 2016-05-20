local t = Def.ActorFrame{}
local height = 20

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_HEIGHT)
		self:valign(1)
		self:zoomto(SCREEN_WIDTH,height)
		self:diffuse(color("#000000")):diffusealpha(0.8)
	end;
	OnCommand = function(self)
		self:zoomy(0)
		self:smooth(0.5)
		self:zoomy(height)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:zoomy(0)
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	Name = "currentTime";
	InitCommand=cmd(xy,SCREEN_WIDTH-5,SCREEN_HEIGHT-height/2;zoom,0.45;halign,1);
	OnCommand = function(self)
		self:y(SCREEN_HEIGHT+height/2)
		self:smooth(0.5)
		self:y(SCREEN_HEIGHT-height/2)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(SCREEN_HEIGHT+height/2)
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

if themeConfig:get_data().global.TipType >= 2 then
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,10,SCREEN_HEIGHT-10;zoom,0.4;maxwidth,(SCREEN_WIDTH-150)/0.4;halign,0);
		OnCommand = function(self)
			if SCREENMAN:GetTopScreen():GetName() ~= "ScreenSelectMusic" then
				self:settext(getRandomQuotes(themeConfig:get_data().global.TipType))
			end
			self:y(SCREEN_HEIGHT+height/2)
			self:smooth(0.5)
			self:y(SCREEN_HEIGHT-height/2)
		end;
		OffCommand = function(self)
			self:smooth(0.5)
			self:y(SCREEN_HEIGHT+height/2)
		end
	}
end;

return t