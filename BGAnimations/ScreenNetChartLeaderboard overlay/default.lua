local pn = GAMESTATE:GetEnabledPlayers()[1]
local song = GAMESTATE:GetCurrentSong()
local steps = GAMESTATE:GetCurrentSteps(pn)
local stepsType = steps:GetStepsType()

local scoreList = {}
local maxItems = 10
local maxPages = math.ceil(#scoreList/maxItems)
local curPage = 1
local currentCountry = "Global"

local lbActor
local cheatIndex
local inDetail = false

local validStepsType = {
	'StepsType_Dance_Single',
	'StepsType_Dance_Solo',
	'StepsType_Dance_Double',
}
local maxNumDifficulties = 0
for _,st in pairs(validStepsType) do
	maxNumDifficulties = math.max(maxNumDifficulties, #song:GetStepsByStepsType(st))
end

local filts = {"All Rates", "Current Rate"}
local topfilts = {"Top Scores", "All Scores"}

local function getNextStepsType(n)
	for i = 1, #validStepsType do
		if validStepsType[i] == stepsType then
			stepsType = validStepsType[(i+n-1+#validStepsType)%#validStepsType+1] -- 1 index scks
			return stepsType
		end
	end
end

local function movePage(n)
	if n > 0 then 
		curPage = ((curPage+n-1) % maxPages + 1)
	else
		curPage = ((curPage+n+maxPages-1) % maxPages+1)
	end
	MESSAGEMAN:Broadcast("UpdateCLBList")
end

local function meterComparator(stepA, stepB)
	local diffA = stepA:GetDifficulty()
	local diffB = stepB:GetDifficulty()

	return Enum.Reverse(Difficulty)[diffA] < Enum.Reverse(Difficulty)[diffB]
end

local function updateLeaderBoardForCurrentChart()
	if steps then
		DLMAN:RequestChartLeaderBoardFromOnline(
			steps:GetChartKey(),
			function(leaderboard)
				lbActor:queuecommand("SetFromLeaderboard", leaderboard)
			end
		)
	else
		lbActor:queuecommand("SetFromLeaderboard", {})
	end
end


local function input(event)
	
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			MESSAGEMAN:Broadcast("WheelUpSlow")
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			MESSAGEMAN:Broadcast("WheelDownSlow")
		end

		if event.button == "EffectUp" and not inDetail then
			changeMusicRate(0.05)
		elseif event.button == "EffectDown" and not inDetail then
			changeMusicRate(-0.05)
		elseif event.button == "MenuLeft" and not inDetail then
			movePage(-1)
		elseif event.button == "MenuRight" and not inDetail then
			movePage(1)
		end
	end
	return false

end

local top
local frameWidth = 430
local frameHeight = 340

local verticalSpacing = 7
local horizontalSpacing = 10

local function topRow()
	local frameWidth = SCREEN_WIDTH - 20
	local frameHeight = 40

	local t = Def.ActorFrame {
		BeginCommand = function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth, frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
		end
	}

	t[#t+1] = Def.Sprite {
		Name = "Banner",
		InitCommand = function(self)
			self:x(-frameWidth/2 + 5)
			self:halign(0)
			local bnpath = song:GetBannerPath()
			if not bnpath then
				bnpath = THEME:GetPathG("Common", "fallback banner")
			end
			self:LoadBackground(bnpath)
			self:scaletoclipped(96, 30)
		end
	}

	t[#t+1] = LoadFont("Common BLarge") .. {
		Name = "SongTitle",
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, -9)
			self:zoom(0.25)
			self:halign(0)
			self:settext(song:GetMainTitle())
			if #song:GetDisplaySubTitle() == 0 then
				self:zoom(0.35):y(-5)
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			local actor = self:GetParent():GetChild("SongTitle")
			local x = actor:GetX() + actor:GetWidth()*actor:GetZoomX() + 2
			local y = actor:GetY() - 2

			self:xy(x,y)
			self:zoom(0.3)
			self:halign(0)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			local length = song:GetStepsSeconds()/getCurRateValue()
			self:settextf("%s",SecondsToMSS(length))
			self:diffuse(getSongLengthColor(length))
		end,
		CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end
	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, 1)
			self:zoom(0.35)
			self:halign(0)
			self:settext(song:GetDisplaySubTitle())
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, 9)
			self:zoom(0.35)
			self:halign(0)
			self:settext("// "..song:GetDisplayArtist())
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-1)
			self:zoom(0.5)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end,
		SetCommand = function(self, params)
			local curSteps = params.steps
			local diff = curSteps:GetDifficulty()
			local stype = curSteps:GetStepsType()
			local meter = math.floor(curSteps:GetMSD(getCurRateValue(),1))
			if meter == 0 then
				meter = curSteps:GetMeter()
			end

			local difftext
			if diff == 'Difficulty_Edit' then
				difftext = curSteps:GetDescription()
				difftext = difftext == '' and getDifficulty(diff) or difftext
			else
				difftext = getDifficulty(diff)
			end

			self:settext(ToEnumShortString(stype):gsub("%_"," ").." "..difftext.." "..meter)
			self:diffuse(getDifficultyColor(GetCustomDifficulty(stype,diff)))
		end,
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end

	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,9)
			self:zoom(0.35)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end,
		SetCommand = function(self, params)
			local curSteps = params.steps
			local notes = 0
			if curSteps ~= nil then
				notes = curSteps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			end
			self:settextf("%d Notes", notes)
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(curSteps:GetStepsType(),curSteps:GetDifficulty())),0.3))
		end,
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability",
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-11)
			self:zoom(0.30)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end,
		SetCommand = function(self, params)
			local curSteps = params.steps
			if curSteps ~= nil then

				local meter = math.floor(curSteps:GetMSD(getCurRateValue(),1))
				if meter == 0 then
					self:settext("Default")
					self:diffuse(color(colorConfig:get_data().main.disabled))
				else
					self:settext("MSD")
					self:diffuse(color(colorConfig:get_data().main.enabled))
				end
			end
		end,
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2+1,-frameHeight/2+1)
			self:zoom(0.3)
			self:wag()
			self:diffuse(Color.Yellow)

			if not song:IsFavorited() then
				self:visible(false)
			end
		end
	}

	return t
end

local function stepsListRow()
	local frameWidth = 150
	local frameHeight = 25
	local topRowFrameWidth = SCREEN_WIDTH - 20
	local topRowFrameHeight = 40


	local stepsTable = {}
	local t = Def.ActorFrame{
		SetStepsTypeMessageCommand = function(self, params)
			stepsTable = song:GetStepsByStepsType(params.st)
			table.sort(stepsTable, meterComparator)
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth, frameHeight)
			self:xy(-topRowFrameWidth/2, topRowFrameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
			self:halign(0)
		end

	}

	t[#t+1] = quadButton(6)..{
		InitCommand = function(self)
			self:zoomto(frameWidth/2, frameHeight)
			self:xy(-topRowFrameWidth/2, topRowFrameHeight)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
			self:halign(0)
			self:faderight(0.5)
		end,
		MouseDownCommand = function(self)
			MESSAGEMAN:Broadcast("SetStepsType", {st = getNextStepsType(-1)})
			self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")

			self:finishtweening()
			self:diffusealpha(0.2)
			self:smooth(0.3)
			self:diffusealpha(0)
		end
	}
	t[#t+1] = quadButton(6)..{
		InitCommand = function(self)
			self:zoomto(frameWidth/2, frameHeight)
			self:xy(-topRowFrameWidth/2+frameWidth/2, topRowFrameHeight)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
			self:halign(0)
			self:fadeleft(0.5)
		end,
		MouseDownCommand = function(self)
			MESSAGEMAN:Broadcast("SetStepsType", {st = getNextStepsType(1)})
			self:GetParent():GetChild("TriangleRight"):playcommand("Tween")

			self:finishtweening()
			self:diffusealpha(0.2)
			self:smooth(0.3)
			self:diffusealpha(0)
		end
	}
	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleLeft",
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(-topRowFrameWidth/2+10,topRowFrameHeight)
			self:rotationz(-90)
		end,
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleRight",
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(-topRowFrameWidth/2+frameWidth-10,topRowFrameHeight)
			self:rotationz(90)
		end,
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end
	}


	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:zoom(0.4)
			self:xy(-topRowFrameWidth/2+frameWidth/2,topRowFrameHeight)
		end,
		SetCommand = function(self)
			self:settext(ToEnumShortString(stepsType):gsub("%_"," "))
		end
	}

	for i = 1, maxNumDifficulties do


		t[#t+1] = quadButton(6)..{
			InitCommand = function(self)
				self:zoomto(40, frameHeight)
				self:y(topRowFrameHeight)
				self:diffuse(color("#000000")):diffusealpha(0)
				self:halign(0)
				self:x((-topRowFrameWidth/2)+frameWidth+5+45*(i-1)-10)
			end,
			SetCommand = function(self)
				local curSteps = stepsTable[i]
				if curSteps then
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end,
			ShowCommand = function(self)
				self:y(topRowFrameHeight)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:x((-topRowFrameWidth/2)+frameWidth+5+45*(i-1))
				self:diffusealpha(0.8)
			end,
			HideCommand = function(self)
				self:diffusealpha(0)
				self:y(SCREEN_HEIGHT*10)
				self:x((-topRowFrameWidth/2)+frameWidth+5+45*(i-1)-10)
			end,
			MouseDownCommand = function(self)
				MESSAGEMAN:Broadcast("SetSteps", {steps = stepsTable[i]})
			end
		}

		t[#t+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				local stype = steps:GetStepsType()
				self:zoom(0.4)
				self:diffusealpha(0)
				self:xy((-topRowFrameWidth/2)+frameWidth+25+45*(i-1)-10, topRowFrameHeight)
				self:settext("0")
			end,
			SetCommand = function(self)
				local curSteps = stepsTable[i]
				if curSteps then

					local meter = math.floor(curSteps:GetMSD(getCurRateValue(),1))
					if meter == 0 then
						meter = curSteps:GetMeter()
					end

					self:settext(meter)
					self:diffuse(color(colorConfig:get_data().difficulty[curSteps:GetDifficulty()]))
					self:diffusealpha(0)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end,
			ShowCommand = function(self)
				self:finishtweening()
				self:sleep((i-1)*0.05)
				self:easeOut(1)
				self:x((-topRowFrameWidth/2)+frameWidth+25+45*(i-1))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:finishtweening()
				self:easeOut(1)
				self:x((-topRowFrameWidth/2)+frameWidth+25+45*(i-1)-10)
				self:diffusealpha(0)
			end
		}
	end

	return t
end

local function stepsBPMRow()
	local topRowFrameWidth = 0
	local topRowFrameHeight = 40
	local frameWidth = 150
	local frameHeight = 25
	local t = Def.ActorFrame{}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth, 25)
			self:xy(topRowFrameWidth, topRowFrameHeight + frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
			self:halign(1)
		end
	}

	t[#t+1] = quadButton(6)..{
		InitCommand = function(self)
			self:zoomto(frameWidth/2, frameHeight)
			self:xy(topRowFrameWidth/2-frameWidth/2, topRowFrameHeight + frameHeight)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
			self:halign(1)
			self:faderight(0.5)
		end,
		MouseDownCommand = function(self)
			changeMusicRate(-0.05)
			self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")

			self:finishtweening()
			self:diffusealpha(0.2)
			self:smooth(0.3)
			self:diffusealpha(0)
		end
	}
	t[#t+1] = quadButton(6)..{
		InitCommand = function(self)
			self:zoomto(frameWidth/2, frameHeight)
			self:xy(topRowFrameWidth/2, topRowFrameHeight + frameHeight)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
			self:halign(1)
			self:fadeleft(0.5)
		end,
		MouseDownCommand = function(self)
			changeMusicRate(0.05)
			self:GetParent():GetChild("TriangleRight"):playcommand("Tween")

			self:finishtweening()
			self:diffusealpha(0.2)
			self:smooth(0.3)
			self:diffusealpha(0)
		end
	}


	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleLeft",
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(topRowFrameWidth/2-frameWidth+10,topRowFrameHeight + frameHeight)
			self:rotationz(-90)
		end,
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleRight",
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(topRowFrameWidth/2-10,topRowFrameHeight + frameHeight)
			self:rotationz(90)
		end,
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:zoom(0.35)
			self:xy(topRowFrameWidth/2-75,topRowFrameHeight-4 + frameHeight)
		end,
		SetStepsMessageCommand = function(self, params)
			if params.steps then
				local bpms = steps:GetTimingData():GetActualBPM()
				if bpms[1] == bpms[2] and bpms[1]~= nil then
					self:settext(string.format("BPM: %d",bpms[1]*getCurRateValue()))
				else
					self:settext(string.format("BPM: %d-%d (%d)",bpms[1]*getCurRateValue(),bpms[2]*getCurRateValue(),getCommonBPM(song:GetTimingData():GetBPMsAndTimes(true),song:GetLastBeat())))
				end
			end
		end
	}
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:zoom(0.3)
			self:xy(topRowFrameWidth/2-75,topRowFrameHeight+4 + frameHeight)
		end,
		SetStepsMessageCommand = function(self, params)
			self:settext(getCurRateDisplayString())
		end
	}

	return t
end


local function offsetInput(event)
	if event.type == "InputEventType_FirstPress" and inDetail then
		local outputName = ""
		if event.button == "EffectUp" then
			outputName = "NextJudge"
		elseif event.button == "EffectDown" then
			outputName = "PrevJudge"
		elseif event.button == "MenuDown" then
			outputName = "ToggleHands"
		elseif event.button == "MenuUp" then
			outputName = "ResetJudge"
		end

		if outputName ~= "" then
			MESSAGEMAN:Broadcast("OffsetPlotModification", {Name = outputName})
		end
	end
end


local function scoreList()
	local frameWidth = 430
	local frameHeight = 340
	local t = Def.ActorFrame{
		SetStepsMessageCommand = function(self, params)
			steps = params.steps
			scoreList = DLMAN:GetChartLeaderBoard(steps:GetChartKey(), currentCountry)
			if #scoreList == 0 then
				updateLeaderBoardForCurrentChart()
			end
			curPage = 1
			if scoreList ~= nil then
				maxPages = math.ceil(#scoreList/maxItems)
				MESSAGEMAN:Broadcast("UpdateCLBList")
				self:GetChild("NoScore"):visible(false)
			else
				maxPages = 1
				self:RunCommandsOnChildren(function(self) self:playcommand("Hide") end)
				self:GetChild("NoScore"):visible(true):playcommand("Set")
			end
		end,
		SetFromLeaderboardCommand = function(self, leaderboard)
			scoreList = DLMAN:GetChartLeaderBoard(steps:GetChartKey(), currentCountry)
			curPage = 1
			if scoreList ~= nil then
				maxPages = math.ceil(#scoreList/maxItems)
				MESSAGEMAN:Broadcast("UpdateCLBList")
				self:GetChild("NoScore"):visible(false)
			else
				maxPages = 1
				self:RunCommandsOnChildren(function(self) self:playcommand("Hide") end)
				self:GetChild("NoScore"):visible(true):playcommand("Set")
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "NoScore",
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight/2)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.6)
			self:settext("No scores here!\n(* ` ω´)")
		end,
		SetCommand = function(self)
			self:finishtweening()
			self:y(frameHeight/2-5)
			self:easeOut(0.5)
			self:y(frameHeight/2)
		end
	}

	local scoreItemWidth = frameWidth-30
	local scoreItemHeight = 25

	local scoreItemX = 20
	local scoreItemY = 30+scoreItemHeight/2
	local scoreItemYSpacing = 5

	local function scoreListItem(i)
		local scoreIndex = (curPage-1)*10+i
		local detail = false
		local hs

		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(scoreItemX, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing)-10)
			end,
			ShowCommand = function(self)
				self:y(scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
				self:y(SCREEN_HEIGHT*10) -- Throw it offscreen
			end,
			UpdateCLBListMessageCommand = function(self)
				detail = false
				scoreIndex = (curPage-1)*10+i
				hs = scoreList[scoreIndex]

				if scoreList ~= nil and scoreList[scoreIndex] ~= nil then
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				if params.index == i then
					detail = true
					self:finishtweening()
					self:easeOut(0.5)
					self:y(scoreItemY)
					self:valign(0)
				else
					self:playcommand("Hide")
				end
			end,
			HideOnlineScoreDetailMessageCommand = function(self)
				detail = false
				if scoreList ~= nil and scoreList[scoreIndex] ~= nil then
					self:playcommand("Show")
				end
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				self:settextf("%d", scoreIndex)
			end
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(scoreItemWidth, scoreItemHeight)
			end,
			MouseDownCommand = function(self, params)
				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
				if params.button == "DeviceButton_left mouse button" then
					if not detail then
						MESSAGEMAN:Broadcast("ShowOnlineScoreDetail", {index = i, scoreIndex = scoreIndex})
					end
				elseif params.button == "DeviceButton_right mouse button" then
					MESSAGEMAN:Broadcast("HideOnlineScoreDetail")
				end
			end,
			SetCommand = function(self)
				if scoreList[i]:GetEtternaValid() then
					self:diffuse(color("#FFFFFF"))
				else
					self:diffuse(color(colorConfig:get_data().clearType.ClearType_Invalid))
				end
				self:diffusealpha(0.2)
			end
		}

		t[#t+1] = getClearTypeLampQuad(3, scoreItemHeight)..{
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.8)
			end,
			SetCommand = function(self)
				self:playcommand("SetClearType", {clearType = getClearType(pn,steps,scoreList[scoreIndex])})
			end
		}


		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(20,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				local ssr = scoreList[scoreIndex]:GetSkillsetSSR("Overall")
				self:settextf("%0.2f",ssr)
				self:diffuse(getMSDColor(ssr))
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			Name = "DisplayName",
			InitCommand  = function(self)
				self:xy(40,-6)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
				self:halign(0)
			end,
			SetCommand = function(self)
				if hs:GetChordCohesion() then
					self:diffuse(color("#F0EEA6"))
				else
					self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				end
				self:settext(hs:GetDisplayName())
			end
			
		}

		t[#t+1] = LoadFont("Common Normal") .. {
			Name = "RateString",
			InitCommand = function(self)
				self:xy(40,-6)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:halign(0)
			end,
			SetCommand = function(self)
				local ratestring = "("..string.format("%.2f", scoreList[scoreIndex]:GetMusicRate()):gsub("%.?0$", "") .. "x)"
				self:settext(ratestring)
				self:x(self:GetParent():GetChild("DisplayName"):GetX()+(self:GetParent():GetChild("DisplayName"):GetWidth()*0.4)+5)
			end
		}
		t[#t+1] = LoadFont("Common Normal") .. {
			Name = "CCON",
			InitCommand = function(self)
				self:xy(40,-6)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:halign(0)
				self:settext("(CC On)")
			end,
			SetCommand = function(self)
				if hs:GetChordCohesion() then
					self:visible(true)
				else
					self:visible(false)
				end
				local ratewidth = self:GetParent():GetChild("RateString"):GetX()+(self:GetParent():GetChild("RateString"):GetWidth()*0.4)
				self:x(ratewidth)
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			Name = "Grade",
			InitCommand  = function(self)
				self:xy(40,5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
				self:halign(0)
			end,
			SetCommand = function(self)
				local grade = scoreList[scoreIndex]:GetWifeGrade()
				self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
				self:diffuse(getGradeColor(grade))
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "PercentScore",
			InitCommand  = function(self)
				self:xy(40,5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:halign(0)
			end,
			SetCommand = function(self)
				local score = scoreList[scoreIndex]:GetWifeScore()
				score = math.floor(score*1000000)/10000
				local w1 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W1")
				local w2 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W2")
				local w3 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W3")
				local w4 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W4")
				local w5 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W5")
				local miss = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_Miss")
				if score >= 99.5 then
					self:settextf("%0.4f%% - %d / %d / %d / %d / %d / %d",score, w1, w2, w3, w4, w5, miss)
				else
					self:settextf("%0.2f%% - %d / %d / %d / %d / %d / %d",score, w1, w2, w3, w4, w5, miss)
				end
				self:x(self:GetParent():GetChild("Grade"):GetX()+(self:GetParent():GetChild("Grade"):GetWidth()*0.4)+5)
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "ReplayAvailability",
			InitCommand  = function(self)
				self:xy(scoreItemWidth-5,5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:halign(1)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex]:HasReplayData() then
					self:settext("Replay Data Available.")
					self:diffuse(getMainColor("enabled"))
				else
					self:settext("Replay Data Unavailable.")
					self:diffuse(getMainColor("disabled"))
				end
			end
		}

		t[#t+1] = LoadFont("Common Normal") .. {
			Name = "Date",
			InitCommand = function(self)
				self:xy(scoreItemWidth-5,-5)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:halign(1)
			end,
			SetCommand = function(self)
				self:settext(scoreList[scoreIndex]:GetDate())
			end
		}

		return t
	end

	local function scoreDetail()
		local scoreIndex
		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(scoreItemX, scoreItemY+scoreItemYSpacing+scoreItemHeight/2)
			end,
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				scoreIndex = params.scoreIndex
				inDetail = true
				self:finishtweening()
				self:xy(scoreItemX, (params.index+1)*(scoreItemHeight+scoreItemYSpacing)+100+scoreItemHeight/2)
				self:easeOut(0.5)
				self:xy(scoreItemX, scoreItemY+scoreItemYSpacing+scoreItemHeight/2)
				self:diffusealpha(1)
			end,
			HideOnlineScoreDetailMessageCommand = function(self)
				inDetail = false
				self:playcommand("Hide")
			end,
			UpdateCLBListMessageCommand = function(self)
				inDetail = false
				self:playcommand("Hide")
			end
		}

		-- Watch online replay button
		t[#t+1] = quadButton(3)..{
			InitCommand = function (self)
				self:xy(95/2+3,30)
				self:zoomto(90,20)
				self:diffuse(color(colorConfig:get_data().main.disabled))
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				self:diffusealpha(0.2)
			end
		}
		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(95/2+3,30)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:diffusealpha(0.4)
				self:queuecommand('Set')
			end,
			SetCommand = function(self)
				self:settext("Watch")
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				self:diffusealpha(0.4)
			end,
		}

		-- View Online Profile Button
		t[#t+1] = quadButton(3)..{
			InitCommand = function (self)
				self:xy(95/2+3 + 95,30)
				self:zoomto(90,20)
				self:diffuse(color(colorConfig:get_data().main.disabled))
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				self:diffusealpha(0.8)
			end,

			MouseDownCommand = function(self)
				if not inDetail then
					return
				end
				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
				local urlstring = "https://etternaonline.com/user/" .. scoreList[scoreIndex]:GetDisplayName()
				GAMESTATE:ApplyGameCommand("urlnoexit," .. urlstring)
			end
		}
		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(95/2+3 + 95,30)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:queuecommand('Set')
			end,
			SetCommand = function(self)
				self:settext("View Profile")
			end
		}

		-- View Score On EtternaOnline Button
		t[#t+1] = quadButton(3)..{
			InitCommand = function (self)
				self:xy(95/2+3 + 95 + 95,30)
				self:zoomto(90,20)
				self:diffuse(color(colorConfig:get_data().main.disabled))
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				self:diffusealpha(0.8)
			end,

			MouseDownCommand = function(self)
				if not inDetail then
					return
				end
				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
				local urlstring = "https://etternaonline.com/score/view/" .. scoreList[scoreIndex]:GetScoreid() .. scoreList[scoreIndex]:GetUserid()
				GAMESTATE:ApplyGameCommand("urlnoexit," .. urlstring)
			end
		}
		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(95/2+3 + 95 + 95,30)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:queuecommand('Set')
			end,
			SetCommand = function(self)
				self:settext("View Online")
			end
		}


		t[#t+1] = Def.Quad{
			InitCommand = function(self)
				self:diffusealpha(0.2)
				self:halign(0):valign(0)
				self:zoomto(scoreItemWidth, frameHeight-80)
			end,
		}

		t[#t+1] = LoadActor(THEME:GetPathG("","OffsetGraph"))..{
			InitCommand = function(self, params)
				self:xy(5, 55)
			end,
			OnCommand = function(self)
				SCREENMAN:GetTopScreen():AddInputCallback(offsetInput)
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				cheatIndex = params.scoreIndex
				if scoreList[params.scoreIndex]:HasReplayData() then
					DLMAN:RequestOnlineScoreReplayData(
						scoreList[params.scoreIndex],
						function()
							MESSAGEMAN:Broadcast("DelayedShowOffset")
							--self:playcommand("DelayedShowOffset")
						end
					)
				else
					self:RunCommandsOnChildren(function(self) self:playcommand("Update", {width = scoreItemWidth-10, height = frameHeight-140,}) end)
				end
			end,
			DelayedShowOffsetMessageCommand = function(self)
				self:RunCommandsOnChildren(function(self)
					local params = 	{width = scoreItemWidth-10, 
									height = frameHeight-140, 
									song = song, 
									steps = steps, 
									nrv = scoreList[cheatIndex]:GetNoteRowVector(),
									dvt = scoreList[cheatIndex]:GetOffsetVector(),
									ctt = scoreList[cheatIndex]:GetTrackVector(),
									ntt = scoreList[cheatIndex]:GetTapNoteTypeVector(),
									columns = steps:GetNumColumns()}
					self:playcommand("Update", params) end
				)
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(scoreItemWidth/2, (frameHeight-100)/2)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.6)
				self:settext("No replay data\n(゜´Д｀゜)")
			end,
			ShowOnlineScoreDetailMessageCommand = function(self, params)
				if not scoreList[params.scoreIndex]:HasReplayData() then
					self:settext("No replay data\n(゜´Д｀゜)")
					self:visible(true)
				end
			end,
			DelayedShowOffsetMessageCommand = function(self)
				if scoreList[cheatIndex]:HasReplayData() and scoreList[cheatIndex]:GetNoteRowVector() == nil then
					self:settext("Missing Noterows from Online Replay\n(゜´Д｀゜)")
				else
					self:settext("No replay data\n(゜´Д｀゜)")
				end
				self:visible(not scoreList[cheatIndex]:HasReplayData() or scoreList[cheatIndex]:GetNoteRowVector() == nil)
			end
		}

		return t

	end

	for i=1, maxItems do
		t[#t+1] = scoreListItem(i)
	end

	t[#t+1] = scoreDetail()

	return t

end

local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		MESSAGEMAN:Broadcast("SetStepsType",{st = stepsType})
		MESSAGEMAN:Broadcast("SetSteps",{steps = steps})
		scoreList = DLMAN:GetChartLeaderBoard(steps:GetChartKey(), currentCountry)
		if #scoreList == 0 then
			updateLeaderBoardForCurrentChart()
		end
		top:AddInputCallback(input)
	end
}

t[#t+1] = LoadActor("../_mouse", "ScreenNetChartLeaderboard")

t[#t+1] = LoadActor("../_frame")

t[#t+1] = topRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
		self:delayedFadeIn(0)
	end
}

t[#t+1] = stepsListRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
		self:delayedFadeIn(1)
	end
}

t[#t+1] = stepsBPMRow() .. {
	InitCommand = function(self)
		self:xy(160, 58)
		self:delayedFadeIn(2)
	end
}

-- The main, central container (Online Leaderboard)
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X / 2, 110)
	end,

	Def.Quad {
		InitCommand = function (self)
			self:zoomto(frameWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
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
	},
	LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:xy(5,10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Online Scores")
		end
	},
	LoadFont("Common Normal") .. {
		Name = "RequestStatus",
		InitCommand = function(self)
			self:xy(5,30)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("")
		end,
		UpdateCLBListMessageCommand = function(self)
			if #scoreList == 0 then
				self:settext("Online scores not tracked or no scores recorded...")
			else
				self:settext("")
			end
		end
	}

}

-- Current Rate/All Rates Toggle Button
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(10,155)
	end,

	Def.Quad {
		InitCommand = function(self)
			self:diffuse(color("#000000"))
			self:xy(0,0)
			self:halign(0)
			self:diffusealpha(0.8)
			self:zoomto(150,25)
		end
	},

	quadButton(6) .. {
		Name = "ToggleRateFilter",
		InitCommand = function(self)
			self:diffuse(color("#FFFFFF"))
			self:xy(0, 0)
			self:halign(0)
			self:diffusealpha(0)
			self:zoomto(150, 25)
		end,
		MouseDownCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.0)
			MESSAGEMAN:Broadcast("ToggleRateFilter")
			updateLeaderBoardForCurrentChart()
		end
	},

	LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(75, 0)
			--self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if DLMAN:GetCurrentRateFilter() then
				self:settext(filts[2])
			else
				self:settext(filts[1])
			end
		end,
		ToggleRateFilterMessageCommand = function(self)
			DLMAN:ToggleRateFilter()
			self:playcommand("Set")
		end
	}
}


-- Top Scores/All Scores Toggle Button
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(10,185)
	end,

	Def.Quad {
		InitCommand = function(self)
			self:diffuse(color("#000000"))
			self:xy(0,0)
			self:halign(0)
			self:diffusealpha(0.8)
			self:zoomto(150,25)
		end
	},

	quadButton(6) .. {
		Name = "TopScoreToggle",
		InitCommand = function(self)
			self:diffuse(color("#FFFFFF"))
			self:xy(0, 0)
			self:halign(0)
			self:diffusealpha(0)
			self:zoomto(150, 25)
		end,
		MouseDownCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.0)
			MESSAGEMAN:Broadcast("TopScoreToggle")
			updateLeaderBoardForCurrentChart()
		end
	},

	LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(75, 0)
			--self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if DLMAN:GetTopScoresOnlyFilter() then
				self:settext(topfilts[1])
			else
				self:settext(topfilts[2])
			end
		end,
		TopScoreToggleMessageCommand = function(self)
			DLMAN:ToggleTopScoresOnlyFilter()
			self:playcommand("Set")
		end
	}
}


t[#t+1] = scoreList() .. {
	Name = "ScoreList",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X / 2, 110)
		self:delayedFadeIn(5)
		lbActor = self
	end
}


t[#t+1] = LoadActor("../_cursor")

return t
