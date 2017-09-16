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
	UpdateRankingMessageCommand = function(self, params)
		self:settextf("Sorted by: %s",params.SSRType)
	end;
	DisplaySongMessageCommand = function(self, params)
		self:visible(false)
	end
}


local function scoreSSRTypes(i)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:playcommand("Tween")
		end;
		TweenCommand = function(self)
			self:finishtweening()
			self:xy(scoreSSRItemX, scoreSSRItemY + (i-1)*(scoreSSRItemHeight+scoreSSRItemYSpacing)-10)
			self:zoomy(0)
			self:diffusealpha(0)
			self:sleep((i-1)*0.05)
			self:easeOut(1)
			self:diffusealpha(1)
			self:zoomy(1)
			self:xy(scoreSSRItemX, scoreSSRItemY + (i-1)*(scoreSSRItemHeight+scoreSSRItemYSpacing))
		end;
		DisplaySongMessageCommand = function(self, params)
			self:visible(false)
			self:y(SCREEN_HEIGHT*10)
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
			self:playcommand("Tween")
		end;
		TweenCommand = function(self)
			self:finishtweening()
			self:xy(scoreItemX, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing)-10)
			self:zoomy(0)
			self:diffusealpha(0)
			self:sleep((i-1)*0.05)
			self:easeOut(1)
			self:diffusealpha(1)
			self:zoomy(1)
			self:xy(scoreItemX, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing))
		end;
		UpdateRankingMessageCommand = function(self, params)
			SCOREMAN:SortSSRs(params.SSRType)
			skillset = params.SSRType
			ths = SCOREMAN:GetTopSSRHighScore(i, params.SSRType)
			chartKey = ths:GetChartKey()
			song = SONGMAN:GetSongByChartKey(chartKey)
			steps = SONGMAN:GetStepsByChartKey(chartKey)
			self:playcommand("Tween")
			self:RunCommandsOnChildren(cmd(queuecommand, "Set"))
		end;
		DisplaySongMessageCommand = function(self, params)
			self:visible(false)
			self:y(SCREEN_HEIGHT*10) -- Send it off screen so buttons don't overlap.
		end
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(scoreItemWidth, scoreItemHeight)
		end;
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.5)
			self:diffusealpha(0.2)
			MESSAGEMAN:Broadcast("DisplaySong",{score = ths})
		end;
		SetCommand = function(self)
			if ths:GetEtternaValid() then
				self:diffuse(color("#FFFFFF"))
			else
				self:diffuse(color(colorConfig:get_data().clearType.ClearType_Invalid))
			end
			self:diffusealpha(0.2)
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
			self:settextf("%s (x%0.2f)",song:GetMainTitle(),ths:GetMusicRate())
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
			self:settextf("// %s",song:GetDisplayArtist())
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(0,-10)
			self:zoom(0.2)
			self:wag()
			self:diffuse(Color.Yellow)
			self:playcommand("Set")
		end;
		SetCommand = function(self,params)
			if song:IsFavorited() then
				self:visible(true)
			else
				self:visible(false)
			end
		end;
	}

	return t
end

local songDisplayX = 10
local songDisplayY = 100
local songDisplayWidth = frameWidth-20
local songDisplayHeight = 140

local function songDisplay()
	local ths
	local chartKey
	local steps
	local song

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:visible(false)
			self:xy(songDisplayX, SCREEN_HEIGHT*10)
		end;
		DisplaySongMessageCommand = function(self, params)
			self:xy(songDisplayX, songDisplayY)
			self:visible(true)
			ths = params.score
			chartKey = ths:GetChartKey()
			steps = SONGMAN:GetStepsByChartKey(chartKey)
			song = SONGMAN:GetSongByChartKey(chartKey)

			self:RunCommandsOnChildren(cmd(queuecommand, "Set"))
		end;
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(songDisplayWidth, songDisplayHeight)
		end;
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.5)
			self:diffusealpha(0.2)
			SCREENMAN:GetTopScreen():Cancel()
			MESSAGEMAN:Broadcast("MoveMusicWheelToSong",{song = song})
		end;
		SetCommand = function(self)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:x(10)
			self:diffuse(color("#000000")):diffusealpha(0.6)
			self:zoomto((songDisplayHeight-20)/3*4,songDisplayHeight-20)
			self:halign(0)
		end
	}

	t[#t+1] = Def.Sprite {
		SetCommand = function(self)
			if song:HasJacket() then
				self:visible(true);
				self:Load(song:GetJacketPath())
			elseif song:HasBackground() then
				self:visible(true)
				self:Load(song:GetBackgroundPath())
			else
				self:visible(false)
			end
			self:diffusealpha(0.8)
			self:scaletofit(10, -songDisplayHeight/2, (songDisplayHeight-20)/3*4+10 , songDisplayHeight/2)
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(songDisplayWidth-5,-songDisplayHeight/2+8)
			self:halign(1)
			self:diffusealpha(0.2)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.5)
		end;
		SetCommand = function(self)
			local diff = getDifficulty(steps:GetDifficulty())
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = math.floor(steps:GetMSD(ths:GetMusicRate(),1))
			if meter == 0 then
				meter = steps:GetMeter()
			end
			if IsUsingWideScreen() then
				self:settext(stype.." "..diff.." "..meter)
			else
				self:settext(diff.." "..meter)
			end
			self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(songDisplayWidth-5,-songDisplayHeight/2+20)
			self:halign(1)
			self:diffusealpha(0.2)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
		end;
		SetCommand = function(self)
			local length = song:GetStepsSeconds()
			local notecount = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			self:settext(string.format("%0.2f %s",notecount/length,THEME:GetString("ScreenSelectMusic","SimfileInfoAvgNPS")))
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())),0.3))
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability";
		InitCommand = function(self)
			self:xy(songDisplayWidth-5,-songDisplayHeight/2+30)
			self:zoom(0.3)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
		SetCommand = function(self)
			local meter = math.floor(steps:GetMSD(getCurRateValue(),1))
			if meter == 0 then
				self:settext("Default")
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			else
				self:settext("MSD")
				self:diffuse(color(colorConfig:get_data().main.enabled))
			end
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
	Name = "Song Title";
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,-15)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
		SetCommand = function(self)
			self:settext(song:GetDisplayMainTitle())
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:GetParent():GetChild("Song Length"):x(songDisplayHeight+40+(self:GetWidth()*0.60))
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "Song Length";
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,-18)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
		SetCommand = function(self)
			local length = song:GetStepsSeconds()
			self:settext(string.format("%s",SecondsToMSS(length)))
			self:diffuse(getSongLengthColor(length))
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "Song SubTitle";
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,0)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
		SetCommand = function(self)
			self:settext(song:GetDisplaySubTitle())
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "Song Artist";
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,13)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
		SetCommand = function(self)
			self:settext(song:GetDisplayArtist())
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			if #song:GetDisplaySubTitle() == 0 then
				self:y(0)
			else
				self:y(13)
			end
		end;
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(10,-songDisplayHeight/2+10)
			self:zoom(0.3)
			self:wag()
			self:diffuse(Color.Yellow)
		end;
		SetCommand = function(self)
			if song:IsFavorited() then
				self:visible(true)
			else
				self:visible(false)
			end
		end;
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

t[#t+1] = songDisplay()


return t