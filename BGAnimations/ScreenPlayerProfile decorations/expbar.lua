
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = PROFILEMAN:GetProfile(pn)

local level = getLevel(getProfileExp(pn))
local currentExp = getProfileExp(pn) - getLvExp(level)
local nextExp = getNextLvExp(level)

local barHeight = 10
local barWidth = 190

local t = Def.ActorFrame{}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(0,-10)
		self:zoom(0.3)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand('Set')
	end;
	SetCommand = function(self)
		if profile ~= nil then
			self:settextf("Lv.%d (%d/%d)",level, currentExp, nextExp)
		end
	end;
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:halign(0)
		self:zoomto(barWidth, barHeight)
	end
}
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:halign(0)
		self:x(1)
		self:zoomto(0, barHeight-2)
		self:diffuse(color(colorConfig:get_data().main.highlight))
		self:queuecommand('Set')
	end;
	SetCommand = function (self)
		if profile ~= nil then
			self:easeOut(2)
			self:zoomto((barWidth-2)*(currentExp/nextExp), barHeight-2)
		end
	end
}

return t