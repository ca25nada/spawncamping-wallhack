

local pn = GAMESTATE:GetEnabledPlayers()[1]
local song = GAMESTATE:GetCurrentSong()
local steps = GAMESTATE:GetCurrentSteps(pn)
local stepsType = steps:GetStepsType()

local frameWidth = SCREEN_WIDTH - 20
local frameHeight = 40

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

local function topRow()
	local t = Def.ActorFrame{
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth, frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
		end;
	}

	t[#t+1] = Def.Banner{
		Name = "Banner";
		InitCommand = function(self)
			self:x(-frameWidth/2 + 5)
			self:halign(0)
			self:LoadFromSong(song)
			self:scaletoclipped(96, 30)
		end
	}

	t[#t+1] = LoadFont("Common BLarge") .. {
		Name = "SongTitle";
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, -9)
			self:zoom(0.25)
			self:halign(0)
			self:settext(song:GetMainTitle())
			if #song:GetDisplaySubTitle() == 0 then
				self:zoom(0.35):y(-5)
			end
		end;
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
		end;
		SetCommand = function(self)
			local length = song:GetStepsSeconds()/getCurRateValue()
			self:settextf("%s",SecondsToMSS(length))
			self:diffuse(getSongLengthColor(length))
		end;
		CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end;
	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, 1)
			self:zoom(0.35)
			self:halign(0)
			self:settext(song:GetDisplaySubTitle())
		end;
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, 9)
			self:zoom(0.35)
			self:halign(0)
			self:settext("// "..song:GetDisplayArtist())
		end;
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-1)
			self:zoom(0.5)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end;
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
		end;
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end;

	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,9)
			self:zoom(0.35)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end;
		SetCommand = function(self, params)
			local curSteps = params.steps
			local notes = 0
			if curSteps ~= nil then
				notes = curSteps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			end
			self:settextf("%d Notes", notes)
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(curSteps:GetStepsType(),curSteps:GetDifficulty())),0.3))
		end;
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability";
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-11)
			self:zoom(0.30)
			self:halign(1)
			self:playcommand("Set", {steps = steps})
		end;
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
		end;
		SetStepsMessageCommand = function(self, params)
			self:playcommand("Set",{steps = params.steps})
		end;
	};

	t[#t+1] = LoadActor(THEME:GetPathG("", "round_star")) .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2+1,-frameHeight/2+1)
			self:zoom(0.3)
			self:wag()
			self:diffuse(Color.Yellow)

			if not song:IsFavorited() then
				self:visible(false)
			end
		end;
	}

	return t
end

local function meterComparator(stepA, stepB)
	local diffA = stepA:GetDifficulty()
	local diffB = stepB:GetDifficulty()

	return Enum.Reverse(Difficulty)[diffA] < Enum.Reverse(Difficulty)[diffB]
end

local function stepsListRow()
	local stepsTable = {}
	local t = Def.ActorFrame{
		SetStepsTypeMessageCommand = function(self, params)
			stepsTable = song:GetStepsByStepsType(params.st)
			table.sort(stepsTable, meterComparator)
			self:RunCommandsOnChildren(cmd(playcommand, "Set"))
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(150, 25)
			self:xy(-frameWidth/2, frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
			self:halign(0)
		end;

	}

	t[#t+1] = quadButton(6)..{
		InitCommand = function(self)
			self:zoomto(150, 25)
			self:xy(-frameWidth/2, frameHeight)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
			self:halign(0)
		end;
		TopPressedCommand = function(self, params)
			if params.input == "DeviceButton_right mouse button" then
				MESSAGEMAN:Broadcast("SetStepsType", {st = getNextStepsType(1)})
				self:GetParent():GetChild("TriangleRight"):playcommand("Tween")
			else
				MESSAGEMAN:Broadcast("SetStepsType", {st = getNextStepsType(-1)})
				self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")
			end
			self:finishtweening()
			self:diffusealpha(0.2)
			self:smooth(0.3)
			self:diffusealpha(0)
		end;
	}
	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleLeft";
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(-frameWidth/2+10,frameHeight)
			self:rotationz(-90)
		end;
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end;
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleRight";
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(-frameWidth/2+150-10,frameHeight)
			self:rotationz(90)
		end;
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end;
	}


	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:zoom(0.4)
			self:xy(-frameWidth/2+150/2,frameHeight)
		end;
		SetCommand = function(self)
			self:settext(ToEnumShortString(stepsType):gsub("%_"," "))
		end;
	}

	for i = 1, maxNumDifficulties do


		t[#t+1] = quadButton(6)..{
			InitCommand = function(self)
				self:zoomto(40, 25)
				self:y(frameHeight)
				self:diffuse(color("#000000")):diffusealpha(0)
				self:halign(0)
				self:x((-frameWidth/2)+155+45*(i-1)-10)
			end;
			SetCommand = function(self)
				local curSteps = stepsTable[i]
				if curSteps then
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end;
			ShowCommand = function(self)
				self:y(frameHeight)
				self:finishtweening()
				self:sleep((i-1)*0.05)
				self:easeOut(1)
				self:x((-frameWidth/2)+155+45*(i-1))
				self:diffusealpha(0.8)
			end;
			HideCommand = function(self)
				self:diffusealpha(0)
				self:y(SCREEN_HEIGHT*10)
				self:x((-frameWidth/2)+155+45*(i-1)-10)
			end;
			TopPressedCommand = function(self)
				MESSAGEMAN:Broadcast("SetSteps", {steps = stepsTable[i]})
			end;
		}

		t[#t+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				local stype = steps:GetStepsType()
				self:zoom(0.4)
				self:diffusealpha(0)
				self:xy((-frameWidth/2)+175+45*(i-1)-10, frameHeight)
				self:settext("0")
			end;
			SetCommand = function(self)
				local curSteps = stepsTable[i]
				if curSteps then
					self:settext(curSteps:GetMeter())
					self:diffuse(color(colorConfig:get_data().difficulty[curSteps:GetDifficulty()]))
					self:diffusealpha(0)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end;
			ShowCommand = function(self)
				self:finishtweening()
				self:sleep((i-1)*0.05)
				self:easeOut(1)
				self:x((-frameWidth/2)+175+45*(i-1))
				self:diffusealpha(1)
			end;
			HideCommand = function(self)
				self:finishtweening()
				self:easeOut(1)
				self:x((-frameWidth/2)+175+45*(i-1)-10)
				self:diffusealpha(0)
			end;
		}
	end


	return t
end

local function stepsBPMRow()
	local t = Def.ActorFrame{
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(150, 25)
			self:xy(frameWidth/2, frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
			self:halign(1)
		end;
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:zoomto(150, 25)
			self:xy(frameWidth/2, frameHeight)
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
			self:halign(1)
		end;
		TopPressedCommand = function(self, params)
			if params.input == "DeviceButton_right mouse button" then
				changeMusicRate(0.05)
				self:GetParent():GetChild("TriangleRight"):playcommand("Tween")
			else
				changeMusicRate(-0.05)
				self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")
			end
			self:finishtweening()
			self:diffusealpha(0.2)
			self:smooth(0.3)
			self:diffusealpha(0)
		end;
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleLeft";
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(frameWidth/2-150+10,frameHeight)
			self:rotationz(-90)
		end;
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end;
	}

	t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
		Name = "TriangleRight";
		InitCommand = function(self)
			self:zoom(0.15)
			self:diffusealpha(0.8)
			self:xy(frameWidth/2-10,frameHeight)
			self:rotationz(90)
		end;
		TweenCommand = function(self)
			self:finishtweening()
			self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
			self:smooth(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
		end;
	}

	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand = function(self)
			self:zoom(0.35)
			self:xy(frameWidth/2-75,frameHeight-4)
		end;
		SetStepsMessageCommand = function(self, params)
			if params.steps then
				local bpms = steps:GetTimingData():GetActualBPM()
				if bpms[1] == bpms[2] and bpms[1]~= nil then
					self:settext(string.format("BPM: %d",bpms[1]*getCurRateValue()))
				else
					self:settext(string.format("BPM: %d-%d (%d)",bpms[1]*getCurRateValue(),bpms[2]*getCurRateValue(),getCommonBPM(song:GetTimingData():GetBPMsAndTimes(true),song:GetLastBeat())))
				end
			end
		end;
	}
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:zoom(0.3)
			self:xy(frameWidth/2-75,frameHeight+4)
		end;
		SetStepsMessageCommand = function(self, params)
			self:settext(getCurRateDisplayString())
		end;
	}

	return t
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		MESSAGEMAN:Broadcast("SetStepsType",{st = stepsType})
		MESSAGEMAN:Broadcast("SetSteps",{steps = steps})
	end;
}


-- NO CLUE WHY THE PARENT ACTOR WON'T RECIEVE THESE BROADCASTS
t[#t+1] = Def.Actor{
	SetStepsMessageCommand = function(self, params)
		steps = params.steps
	end;
	CurrentRateChangedMessageCommand = function(self)
		MESSAGEMAN:Broadcast("SetSteps",{steps = steps})
	end;
}

t[#t+1] = topRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
	end;
}

t[#t+1] = stepsListRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
	end;
}

t[#t+1] = stepsBPMRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
	end;
}

t[#t+1] = LoadActor("stepsinfo") .. {
	InitCommand = function(self)
		self:xy(capWideScale(135,160),140)
	end;
}

t[#t+1] = LoadActor("ssrbreakdown") .. {
	InitCommand = function(self)
		self:xy(capWideScale(135,160),315)
	end;
}

t[#t+1] = LoadActor("infobox") .. {
	InitCommand = function(self)
		self:xy(capWideScale(270,320),110)
	end;
}


return t