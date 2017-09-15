local t = Def.ActorFrame{}

local frameWidth = 475
local frameHeight = 385


local scoreItemX = 100
local scoreItemY = 75
local scoreItemYSpacing = 5
local scoreItemWidth = 350
local scoreItemHeight = 25

local maxScoreItems = 10


local scoreSSRItemX = 50
local scoreSSRItemY = 80
local scoreSSRItemYSpacing = 5
local scoreSSRItemWidth = 80
local scoreSSRItemHeight = 35

local SkillSets = {
	"Stream", 
	"Jumpstream", 
	"Handstream", 
	"Stamina",
	"JackSpeed",
	"JackStamina",
	"Technical"
}

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:zoomto(475,385)
		self:halign(0):valign(0)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(5, 10)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settext("Scores")
	end;
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(5, 50)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settextf("Sorted by: %s",SkillSets[1])
	end;
}


local function scoreSSRTypes(i)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(scoreSSRItemX, scoreSSRItemY + (i-1)*(scoreSSRItemHeight+scoreSSRItemYSpacing))
		end
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:diffusealpha(0.2)
			self:zoomto(scoreSSRItemWidth, scoreSSRItemHeight)
		end;
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.5)
			self:diffusealpha(0.2)
			SCREENMAN:SystemMessage(string.format("Sort by %s",SkillSets[i]))
			MESSAGEMAN:Broadcast("UpdateRanking",{SSRType = SkillSets[i]})
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(0,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext(SkillSets[i])
			self:zoom(0.4)
		end;
	}

	return t

end

local function scoreListItem(i)
	local skillset = SkillSets[1]
	local ths = SCOREMAN:GetTopSSRHighScore(i, SkillSets[1])
	local chartKey = ths:GetChartKey()
	local steps = SONGMAN:GetStepsByChartKey(chartKey)
	local song = SONGMAN:GetSongByChartKey(chartKey)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(scoreItemX, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing))
		end;
		UpdateRankingMessageCommand = function(self, params)
			SCOREMAN:SortSSRs(params.SSRType)
			skillset = params.SSRType
			ths = SCOREMAN:GetTopSSRHighScore(i, params.SSRType)
			chartKey = ths:GetChartKey()
			song = SONGMAN:GetSongByChartKey(chartKey)
			steps = SONGMAN:GetStepsByChartKey(chartKey)

			self:RunCommandsOnChildren(cmd(queuecommand, "Set"))
		end
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(scoreItemWidth, scoreItemHeight)
		end;
		TopPressedCommand = function(self)
			self:diffusealpha(0.4)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().main.highlight))
			self:diffusealpha(0.8)
			self:xy(30, 0)
			self:zoomto(2, scoreItemHeight)
			self:playcommand("Set")
		end;
		SetCommand = function(self)
			self:diffuse(color(colorConfig:get_data().difficulty[steps:GetDifficulty()]))
		end;
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(15,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:playcommand("Set")
		end;
		SetCommand = function(self)
			self:settextf("%0.2f", ths:GetSkillsetSSR(skillset))
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(35,-6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:playcommand("Set")
		end;
		SetCommand = function(self)
			self:settext(song:GetMainTitle())
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(35,5)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.3)
			self:playcommand("Set")
		end;
		SetCommand = function(self)
			self:settext(song:GetDisplayArtist())
		end
	}

	return t
end

SCOREMAN:SortSSRs(SkillSets[1])

for i=1, #SkillSets do
	t[#t+1] = scoreSSRTypes(i)
end

for i=1, maxScoreItems do
	t[#t+1] = scoreListItem(i)
end




return t