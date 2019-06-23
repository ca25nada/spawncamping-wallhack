local t = Def.ActorFrame{}

local frameWidth = capWideScale(SCREEN_WIDTH/2 - 5, SCREEN_WIDTH/3*1.85) ---SCREEN_WIDTH/2 - capWideScale(5,-75)
local frameHeight = SCREEN_HEIGHT - 60


local scoreItemX = capWideScale(75,110)
local scoreItemY = 75
local scoreItemYSpacing = 5
local scoreItemWidth = frameWidth - (capWideScale(50,115) + 5) - capWideScale(30,0)
local scoreItemHeight = 25

local maxScoreItems = 10
local scoreSSRItemX = capWideScale(30,50)
local scoreSSRItemY = 80
local scoreSSRItemYSpacing = 5
local scoreSSRItemWidth = capWideScale(50,80)
local scoreSSRItemHeight = 35
local maxPages = 10
local curPage = 1

local function movePage(n)
	if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
		curPage = 1
		n = 0
	end
	if maxPages > 1 then
		if n > 0 then 
			curPage = ((curPage+n-1) % maxPages + 1)
		else
			curPage = ((curPage+n+maxPages-1) % maxPages+1)
		end
	end
	MESSAGEMAN:Broadcast("UpdateList")
end

local function input(event)
	if event.type == "InputEventType_FirstPress" then

		if event.button == "MenuLeft" then
			movePage(-1)
		end

		if event.button == "MenuRight" then
			movePage(1)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			MESSAGEMAN:Broadcast("WheelUpSlow")
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			MESSAGEMAN:Broadcast("WheelDownSlow")
		end

		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end

	end
end

local SkillSets = {
	"Overall",
	"Stream", 
	"Jumpstream", 
	"Handstream", 
	"Stamina",
	"JackSpeed",
	"Chordjack",
	"Technical"
}

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:zoomto(frameWidth,frameHeight)
		self:halign(0):valign(0)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end,
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	WheelUpSlowMessageCommand = function(self)
		if self:isOver() then
			movePage(-1)
		end
	end,
	WheelDownSlowMessageCommand = function(self)
		if self:isOver() then
			movePage(1)
		end
	end
}

t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(5, 10)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settext("Top Scores")
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(5, 50)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settextf("Sorted by: %s",SkillSets[1])
	end,
	UpdateRankingMessageCommand = function(self, params)
		self:settextf("Sorted by: %s",params.SSRType)
	end,
	OnlineTogglePressedMessageCommand = function(self)
		self:settext("Sorted by: Overall")
	end,
	LoginMessageCommand = function(self)
		self:settext("Sorted by: Overall")
	end,
	LogOutMessageCommand = function(self)
		self:settext("Sorted by: Overall")
	end,
	DisplaySongMessageCommand = function(self, params)
		self:visible(false)
	end
}


local function scoreSSRTypes(i)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:playcommand("Tween")
		end,
		TweenCommand = function(self)
			self:finishtweening()
			self:xy(scoreSSRItemX, scoreSSRItemY + (i-1)*(scoreSSRItemHeight+scoreSSRItemYSpacing)-10)
			self:diffusealpha(0)
			self:sleep((i-1)*0.03)
			self:easeOut(0.5)
			self:diffusealpha(1)
			self:xy(scoreSSRItemX, scoreSSRItemY + (i-1)*(scoreSSRItemHeight+scoreSSRItemYSpacing))
		end,
		DisplaySongMessageCommand = function(self, params)
			self:visible(false)
			self:y(SCREEN_HEIGHT*10)
		end
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:diffusealpha(0.2)
			self:zoomto(scoreSSRItemWidth, scoreSSRItemHeight)
		end,
		MouseDownCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			curPage = 1
			MESSAGEMAN:Broadcast("UpdateRanking",{SSRType = SkillSets[i]})
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(0,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext(SkillSets[i])
			self:zoom(0.4)
			self:maxwidth((scoreSSRItemWidth - 5)/0.4)
		end
	}

	return t

end

local function scoreListItem(i)
	local skillset = SkillSets[1]
	local ths = SCOREMAN:GetTopSSRHighScore(i, SkillSets[1])

	if ths == nil then
		return
	end

	local chartKey = ths:GetChartKey()
	local steps = SONGMAN:GetStepsByChartKey(chartKey)
	local song = SONGMAN:GetSongByChartKey(chartKey)
	local onlineScore = DLMAN:GetTopSkillsetScore(i, "Overall")

	local index = (curPage-1)*maxScoreItems+i

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:playcommand("Tween")
		end,
		TweenCommand = function(self)
			self:finishtweening()
			self:xy(scoreItemX, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing)-10)
			self:diffusealpha(0)
			self:sleep((i-1)*0.03)
			self:easeOut(1)
			self:diffusealpha(1)
			self:xy(scoreItemX, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing))
		end,
		UpdateRankingMessageCommand = function(self, params)
			index = (curPage-1)*maxScoreItems+i
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				onlineScore = DLMAN:GetTopSkillsetScore(index, params.SSRType)
				if not onlineScore then
					self:visible(false)
				else
					self:visible(true)
				end
			else
				SCOREMAN:SortSSRs(params.SSRType)
				skillset = params.SSRType
				ths = SCOREMAN:GetTopSSRHighScore(index, params.SSRType)
				chartKey = ths:GetChartKey()
				song = SONGMAN:GetSongByChartKey(chartKey)
				steps = SONGMAN:GetStepsByChartKey(chartKey)
				self:visible(true)
			end
			self:playcommand("Tween")
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,
		UpdateListMessageCommand = function(self)
			self:playcommand("UpdateRanking", {SSRType = skillset})
		end,
		LoginMessageCommand = function(self)
			GHETTOGAMESTATE:setOnlineStatus("Online")
			self:visible(false)
			self:playcommand("Tween")
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,
		LogOutMessageCommand = function(self)
			index = (curPage-1)*maxScoreItems+i
			GHETTOGAMESTATE:setOnlineStatus("Local")
			SCOREMAN:SortSSRs("Overall")
			skillset = "Overall"
			ths = SCOREMAN:GetTopSSRHighScore(index, "Overall")
			chartKey = ths:GetChartKey()
			song = SONGMAN:GetSongByChartKey(chartKey)
			steps = SONGMAN:GetStepsByChartKey(chartKey)
			self:visible(true)
			self:playcommand("Tween")
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,
		OnlineTogglePressedMessageCommand = function(self)
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				curPage = 1
				index = i
				onlineScore = DLMAN:GetTopSkillsetScore(i, SkillSets[1])
				if not onlineScore then
					self:visible(false)
				else
					self:visible(true)
				end
			else
				SCOREMAN:SortSSRs("Overall")
				skillset = "Overall"
				ths = SCOREMAN:GetTopSSRHighScore(i, "Overall")
				chartKey = ths:GetChartKey()
				song = SONGMAN:GetSongByChartKey(chartKey)
				steps = SONGMAN:GetStepsByChartKey(chartKey)
				self:visible(true)
			end
			self:playcommand("Tween")
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,
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
			self:playcommand("Set")
		end,
		MouseDownCommand = function(self, params)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			if params.button == "DeviceButton_right mouse button" then
				ths:ToggleEtternaValidation()
				MESSAGEMAN:Broadcast("UpdateRanking", {SSRType = skillset})
			elseif params.button == "DeviceButton_left mouse button" then
				--MESSAGEMAN:Broadcast("DisplaySong",{score = ths})
				SCREENMAN:GetTopScreen():Cancel()
				MESSAGEMAN:Broadcast("MoveMusicWheelToSong",{song = song})
			end
		end,
		SetCommand = function(self)
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" or ths:GetEtternaValid() then
				self:diffuse(color("#FFFFFF"))
			else
				self:diffuse(color(colorConfig:get_data().clearType.ClearType_Invalid))
			end
			self:diffusealpha(0.2)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().main.highlight))
			self:diffusealpha(0.8)
			self:xy(30, 0)
			self:zoomto(2, scoreItemHeight)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				self:diffuse(color("#AAAAAA"))
			else
				self:diffuse(color(colorConfig:get_data().difficulty[steps:GetDifficulty()]))
			end
		end
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(15,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				if onlineScore then
					self:settextf("%0.2f", onlineScore.ssr)
					self:diffuse(getMSDColor(onlineScore.ssr))
				end
			else
				local rating = ths:GetSkillsetSSR(skillset)
				self:settextf("%0.2f", rating)
				self:diffuse(getMSDColor(rating))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(-10,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.36)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			self:settextf("%d.", index)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(35,-6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:maxwidth((scoreItemWidth-40)/0.4)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				if onlineScore then
					self:settextf("%s (x%0.2f)", onlineScore.songName, onlineScore.rate)
				end
			else
				self:settextf("%s (x%0.2f)",song:GetMainTitle(),ths:GetMusicRate())
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(35,5)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.3)
			self:maxwidth((scoreItemWidth-40)/0.3)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if GHETTOGAMESTATE:getOnlineStatus() ~= "Online" then
				self:settextf("// %s",song:GetDisplayArtist())
			else
				self:settext("")
			end
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(0,-10)
			self:zoom(0.2)
			self:wag()
			self:diffuse(Color.Yellow)
			self:playcommand("Set")
		end,
		SetCommand = function(self,params)
			if song:IsFavorited() and GHETTOGAMESTATE:getOnlineStatus() ~= "Online" then
				self:visible(true)
			else
				self:visible(false)
			end
		end
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
		end,
		DisplaySongMessageCommand = function(self, params)
			self:xy(songDisplayX, songDisplayY)
			self:visible(true)
			ths = params.score
			chartKey = ths:GetChartKey()
			steps = SONGMAN:GetStepsByChartKey(chartKey)
			song = SONGMAN:GetSongByChartKey(chartKey)

			self:RunCommandsOnChildren(function(self) self:queuecommand("Set") end)
		end
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(songDisplayWidth, songDisplayHeight)
		end,
		MouseDownCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.5)
			self:diffusealpha(0.2)
			SCREENMAN:GetTopScreen():Cancel()
			MESSAGEMAN:Broadcast("MoveMusicWheelToSong",{song = song})
		end,
		SetCommand = function(self)
		end
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
				self:visible(true)
				self:Load(song:GetJacketPath())
			elseif song:HasBackground() then
				self:visible(true)
				self:Load(song:GetBackgroundPath())
			else
				self:visible(false)
			end
			self:diffusealpha(0.8)
			self:scaletofit(10, -songDisplayHeight/2, (songDisplayHeight-20)/3*4+10 , songDisplayHeight/2)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(songDisplayWidth-5,-songDisplayHeight/2+8)
			self:halign(1)
			self:diffusealpha(0.2)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.5)
		end,
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
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(songDisplayWidth-5,-songDisplayHeight/2+20)
			self:halign(1)
			self:diffusealpha(0.2)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
		end,
		SetCommand = function(self)
			local length = song:GetStepsSeconds()
			local notecount = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			self:settext(string.format("%0.2f %s",notecount/length,THEME:GetString("ScreenSelectMusic","SimfileInfoAvgNPS")))
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())),0.3))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability",
		InitCommand = function(self)
			self:xy(songDisplayWidth-5,-songDisplayHeight/2+30)
			self:zoom(0.3)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end,
		SetCommand = function(self)
			local meter = math.floor(steps:GetMSD(getCurRateValue(),1))
			if meter == 0 then
				self:settext("Default")
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			else
				self:settext("MSD")
				self:diffuse(color(colorConfig:get_data().main.enabled))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
	Name = "Song Title",
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,-15)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end,
		SetCommand = function(self)
			self:settext(song:GetDisplayMainTitle())
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:GetParent():GetChild("Song Length"):x(songDisplayHeight+40+(self:GetWidth()*0.60))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "Song Length",
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,-18)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end,
		SetCommand = function(self)
			local length = song:GetStepsSeconds()
			self:settext(string.format("%s",SecondsToMSS(length)))
			self:diffuse(getSongLengthColor(length))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "Song SubTitle",
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,0)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end,
		SetCommand = function(self)
			self:settext(song:GetDisplaySubTitle())
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "Song Artist",
		InitCommand = function(self)
			self:xy(songDisplayHeight+40,13)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end,
		SetCommand = function(self)
			self:settext(song:GetDisplayArtist())
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			if #song:GetDisplaySubTitle() == 0 then
				self:y(0)
			else
				self:y(13)
			end
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(10,-songDisplayHeight/2+10)
			self:zoom(0.3)
			self:wag()
			self:diffuse(Color.Yellow)
		end,
		SetCommand = function(self)
			if song:IsFavorited() then
				self:visible(true)
			else
				self:visible(false)
			end
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

-- t[#t+1] = songDisplay()


return t