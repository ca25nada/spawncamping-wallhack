local t = Def.ActorFrame{}
local topFrameHeight = 20
local bottomFrameHeight = 20

local screenName = {
	ScreenSelectStyle = "Select Style",
    ScreenSelectPlayMode = "Select Mode", 
    ScreenSelectMusic = "Select Music", 
    ScreenSelectCourse = "Select Course",
    ScreenPlayerOptions = "Player Options",
    ScreenNestyPlayerOptions = "Player Options",
    ScreenOptionsService = "Service Menu",
    ScreenEvaluationNormal = "Results", 
    ScreenColorChange = "Color Config",
    ScreenSelectProfile = "Select Profile",
    ScreenColorEdit = "Color Config"
}

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

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function (self)
		self:diffuse(color("#FFFFFF"))
		self:zoom(0.5)
		self:halign(0)
		self:xy(10,10)
	end;
	OnCommand = function(self)
		self:y(-10)
		self:smooth(0.5)
		self:y(10)

		self:settext(screenName[SCREENMAN:GetTopScreen():GetName()] or "")
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-10)
	end;
};

if themeConfig:get_data().global.TipType >= 2 then
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,10,SCREEN_HEIGHT-10;zoom,0.4;maxwidth,(SCREEN_WIDTH-150)/0.4;halign,0);
		OnCommand = function(self)
			if SCREENMAN:GetTopScreen():GetName() ~= "ScreenSelectMusic" then
				self:settext(getRandomQuotes(themeConfig:get_data().global.TipType))
			end
			self:y(SCREEN_HEIGHT+bottomFrameHeight/2)
			self:smooth(0.5)
			self:y(SCREEN_HEIGHT-bottomFrameHeight/2)
		end;
		OffCommand = function(self)
			self:smooth(0.5)
			self:y(SCREEN_HEIGHT+bottomFrameHeight/2)
		end
	}
end;

return t