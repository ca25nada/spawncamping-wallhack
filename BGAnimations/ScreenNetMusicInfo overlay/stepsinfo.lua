
local t = Def.ActorFrame{}

local frameWidth = capWideScale(250,300)
local frameHeight = 60

local pn = GAMESTATE:GetEnabledPlayers()[1]
local song = GAMESTATE:GetCurrentSong()
local steps = GAMESTATE:GetCurrentSteps(pn)

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:zoomto(frameWidth,frameHeight)
		self:diffuse(color(colorConfig:get_data().main.frame)):diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(-frameWidth/2+5,frameHeight/2-8)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:zoom(0.3)
		self:settextf("ChartKey: %s","")
	end,
	SetStepsMessageCommand = function(self, params)
		self:settextf("ChartKey: %s",params.steps:GetChartKey())
	end
}


local parameters = {
	{"Notes","RadarCategory_Notes"},
	{"Jumps","RadarCategory_Jumps"},
	{"Hands","RadarCategory_Hands"},
	{"Holds","RadarCategory_Holds"},
	{"Rolls","RadarCategory_Rolls"},
	{"Mines","RadarCategory_Mines"},
	{"Lifts","RadarCategory_Lifts"},
	{"Fakes","RadarCategory_Fakes"}
}

for i,v in ipairs(parameters) do
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy((-frameWidth/2)+frameWidth/(#parameters+1)*i,-10)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:settext(v[1])
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy((-frameWidth/2)+frameWidth/(#parameters+1)*i,3)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.3)
		end,
		SetStepsMessageCommand = function(self, params)
			self:settext(params.steps:GetRadarValues(pn):GetValue(v[2]))
			self:finishtweening()
			self:diffusealpha(0):y(0)
			self:easeOut(1)
			self:diffusealpha(1):y(3)
		end
	}

end

return t