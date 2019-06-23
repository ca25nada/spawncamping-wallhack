local pn = GAMESTATE:GetEnabledPlayers()[1]
local song = GAMESTATE:GetCurrentSong()
local steps = GAMESTATE:GetCurrentSteps(pn)
local stepsType = steps:GetStepsType()
local usingreverse = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingReverse()

local ssm
local NF
local NFParent
local musicratio = 1
local snapGraph
local densityGraph
local previewType = 1

local validStepsType = {
	'StepsType_Dance_Single',
	'StepsType_Dance_Solo',
	'StepsType_Dance_Double',
}
local maxNumDifficulties = 0
for _,st in pairs(validStepsType) do
	maxNumDifficulties = math.max(maxNumDifficulties, #song:GetStepsByStepsType(st))
end

local function getNextStepsType(n)
	for i = 1, #validStepsType do
		if validStepsType[i] == stepsType then
			stepsType = validStepsType[(i+n-1+#validStepsType)%#validStepsType+1] -- 1 index scks
			return stepsType
		end
	end
end

local function meterComparator(stepA, stepB)
	local diffA = stepA:GetDifficulty()
	local diffB = stepB:GetDifficulty()

	return Enum.Reverse(Difficulty)[diffA] < Enum.Reverse(Difficulty)[diffB]
end

local stepsTable = {}

-- I can't believe I have to do this
local function findCurStepIndex(givenSteps)
	for i = 1, #stepsTable do
		if stepsTable[i]:GetChartKey() == givenSteps:GetChartKey() then
			return i
		end
	end
end

local curStepIndex = 0

local function input(event)
	
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" or event.DeviceInput.button == "DeviceButton_space" then
			SCREENMAN:GetTopScreen():Cancel()
			ssm:DeletePreviewNoteField(NFParent)
			MESSAGEMAN:Broadcast("PreviewNoteFieldDeleted")
		end

		if event.button == "EffectUp" then
			changeMusicRate(0.05)
		end

		if event.button == "EffectDown" then
			changeMusicRate(-0.05)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			MESSAGEMAN:Broadcast("WheelUpSlow")
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			MESSAGEMAN:Broadcast("WheelDownSlow")
		end

		if event.DeviceInput.button == "DeviceButton_right mouse button" then
			ssm:PausePreviewNoteField()
			MESSAGEMAN:Broadcast("PreviewPaused")
		end

	end
	return false

end

local top
local frameWidth = SCREEN_WIDTH/2 - capWideScale(35,-5)
local frameHeight = 340

local verticalSpacing = 7
local horizontalSpacing = 10

local function topRow()
	local frameWidth = SCREEN_WIDTH - 20
	local frameHeight = 40

	local t = Def.ActorFrame{
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
				curStepIndex = findCurStepIndex(curSteps)

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
				local dir = i - curStepIndex
				if dir ~= 0 then
					ssm:ChangeSteps(dir)
					MESSAGEMAN:Broadcast("SetSteps", {steps = stepsTable[i]})
				end
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

local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		MESSAGEMAN:Broadcast("SetStepsType",{st = stepsType})
		MESSAGEMAN:Broadcast("SetSteps",{steps = steps})
		top:AddInputCallback(input)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
	end,
	ExitScreenMessageCommand = function(self)
		ssm:DeletePreviewNoteField(NFParent)
		MESSAGEMAN:Broadcast("PreviewNoteFieldDeleted")
	end
}

t[#t+1] = LoadActor("../_mouse", "ScreenChartPreview")

t[#t+1] = LoadActor("../_frame") .. {
	InitCommand = function(self)
		self:draworder(101)
	end
}

t[#t+1] = topRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
		self:delayedFadeIn(0)
		self:draworder(100000)
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
		self:xy(SCREEN_CENTER_X + frameWidth - 13, 25)
		self:delayedFadeIn(2)
	end
}

t[#t+1] = LoadActor("../ScreenMusicInfo overlay/stepsinfo") .. {
	InitCommand = function(self)
		self:xy(capWideScale(135,160),140)
		self:delayedFadeIn(3)
	end
}

t[#t+1] = LoadActor("../ScreenMusicInfo overlay/ssrbreakdown") .. {
	InitCommand = function(self)
		self:xy(capWideScale(135,160),315)
		self:delayedFadeIn(4)
	end
}

local densityGraphWidth = capWideScale(64,84)

local function getColorForDensity(density, nColumns)
	-- Generically (generally? intelligently? i dont know) set a range
	-- Colors are color(0.1,0.1,0.1) to color(0.7,0.7,0.7)
	-- The value var describes the level of density.
	-- Beginning at 0.1 for 0, to 0.7 for nColumns.
	-- You wouldn't give nColumns = 1 to this function or else something is wrong with you.
	local value = 0.1 + (nColumns - (density - 1)) * (0.6 / (nColumns - 1))
	return color(tostring(value)..","..tostring(value)..","..tostring(value))
end

local function makeABar(vertices, x, y, barWidth, barHeight, thecolor)
	-- These bars are horizontal, progressively going down the screen
	-- Their corners are: (x,y), (x+barHeight,y), (x,y+barWidth), (x+barHeight, y+barWidth)
	vertices[#vertices + 1] = {{x,y-barWidth,0},thecolor}
	vertices[#vertices + 1] = {{x+barHeight,y-barWidth,0},thecolor}
	vertices[#vertices + 1] = {{x+barHeight,y,0},thecolor}
	vertices[#vertices + 1] = {{x,y,0},getMiscColor("ChordGraphGradientDark")}
end

local function seekOrHighlight(self)
	local pos = ssm:GetPreviewNoteFieldMusicPosition() / musicratio
	self:GetChild("PreviewProgress"):zoomto(densityGraphWidth, math.min(pos, frameHeight-20))
	self:queuecommand("Highlight")
end

local function togglePreviewType()
	if previewType == 1 then
		previewType = 0
		densityGraph:visible(false)
		snapGraph:visible(true)
		snapGraph:queuecommand("DrawSnapGraph")
	else
		previewType = 1
		densityGraph:visible(true)
		snapGraph:visible(false)
	end
end


-- The container for the density graph and scrollbar
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X / 1.2 + 5 + frameWidth + horizontalSpacing - capWideScale(0,45), 110)
		self:GetChild("ChordDensityGraph"):queuecommand("GraphUpdate")
		self:SetUpdateFunction(seekOrHighlight)
		self:queuecommand("DelayedUpdateHack")
	end,
	DelayedUpdateHackCommand = function(self)
		-- i dunno maybe the song might not be ready in time, just in case bro
		musicratio = GAMESTATE:GetCurrentSong():GetLastSecond() / (frameHeight - 20)
	end,
	OnCommand = function(self)
		densityGraph = self:GetChild("ChordDensityGraph")
	end,

	-- container bg
	Def.Quad {
		InitCommand = function (self)
			self:zoomto(densityGraphWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	},

	Def.Quad {
		Name = "PreviewProgress",
		InitCommand = function(self)
			self:xy(densityGraphWidth/2, 20)
			self:zoomto(densityGraphWidth, 200)
			self:diffuse(getMiscColor("PreviewProgress"))
			self:diffusealpha(0.5)
			self:valign(0)
		end
	},

	Def.ActorMultiVertex {
		Name = "ChordDensityGraph",
		SetStepsMessageCommand = function(self, params)
			if params.steps then
				self:queuecommand("GraphUpdate")
			end
		end,
		CurrentRateChangedMessageCommand = function(self)
			if steps then
				self:queuecommand("GraphUpdate")
			end
		end,
		GraphUpdateCommand = function(self)
			steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			if steps then
				local nColumns = steps:GetNumColumns()
				local rate = math.max(1, getCurRateValue())
				local graphVectors = steps:GetCDGraphVectors(rate)
				if graphVectors == nil then
					self:SetVertices({})
					self:SetDrawState( {Mode = "DrawMode_Quads", First = 0, Num = 0} )
					return
				end
				local npsVector = graphVectors[1] -- CPS Vector 1 (Taps per second)
				local numberOfRows = #npsVector
				local rowWidth = (frameHeight - 20) / numberOfRows * rate

				-- Width scale of graph relative to max nps
				local mWidth = 0
				for i = 1, #npsVector do
					if npsVector[i] * 2 > mWidth then
						mWidth = npsVector[i] * 2
					end
				end

				self:GetParent():GetChild("NPSText"):settext(mWidth / 2 .. " max NPS")
				mWidth = densityGraphWidth / mWidth
				local verts = {}
				for density = 1, nColumns do
					for row = 1, numberOfRows do
						if graphVectors[density][row] > 0 then
							local barColor = getColorForDensity(density, nColumns)
							makeABar(verts, 0, 20+math.min(row * rowWidth, frameHeight-20), rowWidth, graphVectors[density][row] * 2 * mWidth, barColor)
						end
					end
				end
				
				self:SetVertices(verts)
				self:SetDrawState( {Mode = "DrawMode_Quads", First = 1, Num = #verts} )

			end
		end
	},

	LoadFont("Common Bold") .. {
		Name = "NPSText",
		InitCommand = function(self)
			self:xy(densityGraphWidth/2,10)
			self:zoom(0.4)
			--self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("")
			self:maxwidth(densityGraphWidth * 2.2)
		end
	},

	-- Invisible button to toggle secret scuffed graph
	quadButton(8) .. {
		Name = "spooky",
		InitCommand = function(self)
			self:zoomto(densityGraphWidth,20)
			self:halign(0)
			self:valign(0)
			self:diffusealpha(0)
		end,
		MouseDownCommand = function(self)
			togglePreviewType()
		end
	},

	-- This handles the seeking through the preview
	quadButton(7) .. {
		Name = "PreviewClickable",
		InitCommand = function(self)
			self:diffuse(color("#000000"))
			self:y(20)
			self:zoomto(densityGraphWidth,frameHeight-20)
			self:halign(0):valign(0)
			self:diffusealpha(0)
		end,
		HighlightCommand = function(self)
			if isOver(self) then
				self:GetParent():GetChild("PreviewSeek"):visible(true)
				self:GetParent():GetChild("PreviewSeek"):y(INPUTFILTER:GetMouseY() - self:GetParent():GetY())
			else
				self:GetParent():GetChild("PreviewSeek"):visible(false)
			end
		end,
		MouseDownCommand = function(self, params)
			if params.button == "DeviceButton_left mouse button" then
				ssm:SetPreviewNoteFieldMusicPosition( (INPUTFILTER:GetMouseY() - self:GetParent():GetY() - 20) * musicratio)
			end
		end,
		WheelUpSlowMessageCommand = function(self)
			if isOver(self) then
				ssm:SetPreviewNoteFieldMusicPosition( ssm:GetPreviewNoteFieldMusicPosition() - 0.1 )
			end
		end,
		WheelDownSlowMessageCommand = function(self)
			if isOver(self) then
				ssm:SetPreviewNoteFieldMusicPosition( ssm:GetPreviewNoteFieldMusicPosition() + 0.1 )
			end
		end
	},
	
	-- This is the position bar for seeking
	Def.Quad {
		Name = "PreviewSeek",
		InitCommand = function(self)
			self:y(20)
			self:zoomto(densityGraphWidth, 1)
			self:diffuse(getMiscColor("PreviewSeek"))
			self:halign(0)
		end
	}

}

local dotWidth = 7
local dotHeight = 0.75
local function fillVertStruct( vt, x, y, givencolor )
	vt[#vt + 1] = {{x - dotWidth, y + dotHeight, 0}, givencolor}
	vt[#vt + 1] = {{x + dotWidth, y + dotHeight, 0}, givencolor}
	vt[#vt + 1] = {{x + dotWidth, y - dotHeight, 0}, givencolor}
	vt[#vt + 1] = {{x - dotWidth, y - dotHeight, 0}, givencolor}
end
local function fitX( number, totalnumber ) -- find X relative to the center of the plot
	return -densityGraphWidth / 2 + densityGraphWidth * (number / totalnumber) - (densityGraphWidth/(totalnumber*2))
end

local function fitY( number, tracks ) -- find Y relative to the middle of the screen
	return -SCREEN_HEIGHT / 2 + SCREEN_HEIGHT * (number / tracks) * (usingreverse and -1 or 1)
end

local noteData

t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X / 1.2 + 5 + frameWidth + horizontalSpacing + densityGraphWidth/2 - capWideScale(0,45), 110)
		self:valign(0)
	end,
	OnCommand = function(self)
		if song and steps then
			noteData = steps:GetNonEmptyNoteData()
		else
			noteData = nil
		end
		snapGraph = self:GetChild("SnapGraph")
	end,
	Def.ActorMultiVertex {
		Name = "SnapGraph",
		OnCommand = function(self)
			self:visible(false)
			self:queuecommand("DrawSnapGraph")
		end,
		SetStepsMessageCommand = function(self, params)
			if params.steps then
				if song then
					noteData = params.steps:GetNonEmptyNoteData()
				else
					noteData = nil
				end
				if previewType == 0 then
					self:queuecommand("DrawSnapGraph")
				end
			end
		end,
		DrawSnapGraphCommand = function(self)
			local verts = {}
			local numtracks = #noteData - 2
			local numrows = noteData[1][#noteData[1]]
			dotWidth = (densityGraphWidth - numtracks) / (numtracks*2)
			local specificwidth = (frameHeight - 20) / numrows
			for row = 1, #noteData[1] do
				--local y = fitY(noteData[1][row], numrows)
				local y = 20 + math.min(noteData[1][row] * specificwidth, frameHeight-20)
				for track = 1, numtracks do
					local x = fitX(track, numtracks)
					if noteData[track + 1][row] == 1 then
						local dotcolor = color("#da5757") 
						if noteData[6][row] == 1 then 
							dotcolor = color("#da5757")
						elseif noteData[6][row] == 2 then 
							dotcolor = color("#003EFF")
						elseif noteData[6][row] == 3 then 
							dotcolor = color("#3F6826")
						elseif noteData[6][row] == 4 then 
							dotcolor = color("#dff442")
						elseif noteData[6][row] == 5 then 
							dotcolor = color("#7a11d6")
						elseif noteData[6][row] == 6 then 
							dotcolor = color("#d68311")
						elseif noteData[6][row] == 7 then 
							dotcolor = color("#11d6bb")
						elseif noteData[6][row] == 8 then 
							dotcolor = color("#5e5d60")
						elseif noteData[6][row] == 9 then 
							dotcolor = color("#f9f9f9")
						end
							
						fillVertStruct( verts, x, y, dotcolor )
					end
				end
			end
			self:SetVertices(verts)
			self:SetDrawState {Mode = "DrawMode_Quads", First = 1, Num = #verts}

		end
	}
}

-- The main, central container (Preview Notefield)
t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(capWideScale(SCREEN_WIDTH/2 - 50, SCREEN_CENTER_X / 1.2 - 36), 110)
	end,

	Def.Quad {
		InitCommand = function (self)
			self:zoomto(frameWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	},
	LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:xy(5,10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("")
		end
	},
	-- The Preview Notefield.
	Def.ActorFrame {
		InitCommand = function(self)
			NFParent = self
			ssm = GHETTOGAMESTATE:getSSM()
			self:queuecommand("StartPreview")
		end,

		StartPreviewCommand = function(self)
			NF = ssm:CreatePreviewNoteField()
			if NF == nil then
				return
			end
			NF:zoom(0.5):draworder(100)
			ssm:dootforkfive(NFParent)
			NF:xy(frameWidth / 2, 50)
			if usingreverse then
				NF:y(50 * 1.5 + 215)
			end
			NFParent:SortByDrawOrder()
		end
	},
}

t[#t+1] = LoadActor("../_cursor")

return t
