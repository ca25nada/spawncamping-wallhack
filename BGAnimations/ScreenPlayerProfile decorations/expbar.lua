
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
		self:xy(barWidth,-11)
		self:zoom(0.3)
		self:halign(1)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand('Set')
	end,
	SetCommand = function(self)
		if profile ~= nil then
			self:settextf("Lv.%d (%d/%d)",level, currentExp, nextExp)
		end
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(0, -11)
		self:zoom(0.3)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:playcommand('Set')
	end,

	LoginMessageCommand = function(self)
		self:playcommand('Set')
	end,

	LogOutMessageCommand = function(self)
		self:playcommand('Set')
	end,

	OnlineUpdateMessageCommand = function(self)
		self:playcommand('Set')
	end,

	OnlineTogglePressedMessageCommand = function(self)
		self:playcommand('Set')
	end,

	SetCommand = function(self)
		local rating = 0
		local rank = 0

		if GHETTOGAMESTATE:getOnlineStatus() == "Online" and DLMAN:IsLoggedIn() then
			rank = DLMAN:GetSkillsetRank("Overall")
			rating = DLMAN:GetSkillsetRating("Overall")

			self:settextf("Skill Rating: %0.2f (#%d)", rating, rank)

		else		
			if profile ~= nil then
				rating = profile:GetPlayerRating()
				self:settextf("Skill Rating: %0.2f",rating)
			end

		end

		self:AddAttribute(#"Skill Rating:", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(rating)})
	end
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
	end,
	SetCommand = function (self)
		if profile ~= nil then
			self:easeOut(1)
			self:zoomto((barWidth-2)*(currentExp/nextExp), barHeight-2)
		end
	end
}

return t