--==== Only edit these ====--
local maxTicks = 400 -- "Soft cap" on the number of ticks to display. Actual count displayed == math.floor(#offsetTable/math.floor(#offsetTable/maxTicks))
local maxTicksZoomed = 200 -- Number of ticks to display when after drilling down/zoomed in.
local maxMissTicks = 100 -- unused for now. To be used to limit the number of miss ticks displayed.

-- Positoning
local frameX = SCREEN_CENTER_X*3/2
local frameY = 150+250/2
local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
local frameHeight = 250
local frame2Height = 40

--Tick dimensions
local tickWidth = 2
local tickHeight = 2
--=========================--

local song = GAMESTATE:GetCurrentSong()
local songLength = song:GetLastSecond()
local timingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
local W5Window = PREFSMAN:GetPreference("TimingWindowSecondsW5") -- Timing window for Bads
local pn = GAMESTATE:GetEnabledPlayers()[1]
local offsetTable = getOffsetTableST(pn) -- Table containing offsets
local mean = getOffsetMeanST(pn)
local stddev = getOffsetStdDevST(pn)

local hidden = true

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX+100,frameY)
		self:diffusealpha(0)
	end;
	ShowCommand = function(self)
		self:stoptweening()
		self:bouncy(0.3)
		self:xy(frameX,frameY)
		self:diffusealpha(1)
		hidden = false
	end;
	OffCommand = function(self)
		self:stoptweening()
		self:bouncy(0.3)
		self:x(frameX+100)
		self:diffusealpha(0)
		hidden = true
	end;
	TabChangedMessageCommand = function(self, params)
		if params.index == 2 then
			self:playcommand("Show")
		else
			self:playcommand("Off")
		end
	end
}

-- Do binary search to find the table index for the timestamp of when the offset occured given the time.
local function binSearchTimeStamp(offsetTable,time)
	local min = 1
	local max = #offsetTable
	local mid = 0
	while min <= max do
		mid = math.floor((min+max)/2)
		if offsetTable[mid][1] > time then
			max = mid-1
		elseif offsetTable[mid][1] < time then
			min = mid+1
		else
			return mid
		end
		Trace(tostring(string.format("%d %d %d",min,max,mid)))
	end
	return mid
end

-- Converts mouse position to range of notes to drill down to.
-- Returns table containing the min/max values.
local function XtoNoteRange(mouseX)
	if maxTicksZoomed >= #offsetTable then
		return {1,#offsetTable}
	else
		local relX = mouseX - frameX + frameWidth/2
		local time = relX/frameWidth*songLength

		local index = binSearchTimeStamp(offsetTable,time)
		if index <= maxTicksZoomed/2 then
			return {1,maxTicksZoomed}
		elseif index >= #offsetTable-maxTicksZoomed/2 then
			return {#offsetTable-maxTicksZoomed,#offsetTable}
		else
			return {index-maxTicksZoomed/2,index+maxTicksZoomed/2}
		end
	end
end

-- Top background quad
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(frameWidth,frameHeight)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
	MouseLeftClickMessageCommand=function(self)
		if not hidden then
			if isOver(self) and #offsetTable > maxTicksZoomed then
				local params = XtoNoteRange(INPUTFILTER:GetMouseX())
				MESSAGEMAN:Broadcast("GraphLeftClick",{start = params[1], last = params[2]})
			end
		end
	end;
	MouseRightClickMessageCommand=function(self)
		if not hidden then
			if isOver(self) then
				MESSAGEMAN:Broadcast("GraphRightClick")
			end
		end
	end;
}

-- Top Masking quad
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(frameWidth,frameHeight)
		self:zwrite(true):clearzbuffer(true):blend('BlendMode_NoEffect');
	end;
}

-- Bottom Background quad
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(frameHeight/2+frame2Height/2+10):zoomto(frameWidth,frame2Height)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
}

-- Standard deviation
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(mean/W5Window*frameHeight/2):zoomto(frameWidth,stddev/W5Window*timingWindowScale*frameHeight)
		self:diffusealpha(0.2)
	end;
}

-- Center line
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(frameWidth,2)
		self:diffusealpha(0.8)
	end;
}

-- Parent actorframe for ticks
local ticks = Def.ActorFrame{
	InitCommand = function(self)
		self:x(-frameWidth/2)
	end;
}

for k,v in pairs(offsetTable) do
	ticks[#ticks+1] = Def.Quad{
		Name=k;
		InitCommand = function(self)
			self:zoomto(tickWidth,tickHeight)
			self:diffuse(offsetToJudgeColor(v[2])):diffusealpha(0.6)
			
			self:y(v[2]/(W5Window*timingWindowScale)*frameHeight/2)
			self:diffusealpha(0)
			self:playcommand("Default")
			self:ztest(true):ztestmode('ZTestMode_WriteOnFail')
		end;
		DefaultCommand = function(self)
			self:stoptweening()
			self:offsetTickTween(1)
			self:x(offsetTable[tonumber(self:GetName())][1]/songLength*frameWidth)
			if #offsetTable > maxTicks and tonumber(self:GetName())%(math.floor(#offsetTable/maxTicks)) ~= 0 then
				self:diffusealpha(0)
			else
				self:diffusealpha(0.6)
			end

		end;
		DrillDownCommand = function(self, params) -- params.start , params.last
			self:stoptweening()

			local index = tonumber(self:GetName())
			local length = offsetTable[params.last][1] - offsetTable[params.start][1]
			if index >= params.start and index <= params.last then
				self:offsetTickTween(1)
				self:diffusealpha(0.6)
				self:x((offsetTable[index][1]-offsetTable[params.start][1]) / length * frameWidth)
			else
				self:offsetTickTween(1)
				self:diffusealpha(0)
				self:x((offsetTable[index][1]-offsetTable[params.start][1]) / length * frameWidth)
			end
		end;
		GraphLeftClickMessageCommand=function(self)
			local params = XtoNoteRange(INPUTFILTER:GetMouseX())
			self:playcommand("DrillDown", {start = params[1], last = params[2]})
		end;
		GraphRightClickMessageCommand=function(self)
			self:playcommand("Default")
		end;

	}
end
t[#t+1] = ticks

-- Mean line
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(mean/W5Window*frameHeight/2):zoomto(frameWidth,1)
		self:diffusealpha(0.5)
	end;
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(-frameWidth/2+3,-frameHeight/2+7):halign(0):zoom(0.3)
		self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText)):diffusealpha(0.8)
		self:settext("Early")
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(-frameWidth/2+3,frameHeight/2-7):halign(0):zoom(0.3)
		self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText)):diffusealpha(0.8)
		self:settext("Late")
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(frameWidth/2-3,frameHeight/2-7):halign(1):zoom(0.3)
		self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText)):diffusealpha(0.8)
		if #offsetTable > maxTicks then
			self:settextf("Viewing all offsets. (%d Taps omitted)", #offsetTable - math.floor(#offsetTable/math.floor(#offsetTable/maxTicks)))
		else
			self:settext("Viewing all offsets.")
		end
	end;
	GraphLeftClickMessageCommand=function(self, params)
		self:settextf("Viewing offsets from Taps %d - %d (%0.2f Seconds)",params.start,params.last,offsetTable[params.last][1]-offsetTable[params.start][1] )
	end;
	GraphRightClickMessageCommand=function(self)
		if #offsetTable > maxTicks then
			self:settextf("Viewing all offsets. (%d Taps omitted)", #offsetTable - math.floor(#offsetTable/math.floor(#offsetTable/maxTicks)))
		else
			self:settext("Viewing all offsets.")
		end
	end;
}

-- Text for bottom quad
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(-frameWidth/2+3,frameHeight/2+10+frame2Height/3):halign(0):zoom(0.35)
		self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText)):diffusealpha(0.8)

		if mean >= 0 then
			self:settextf("Mean Offset: %0.2fms (Late)",mean*1000)
		elseif mean < 0 then
			self:settextf("Mean Offset: %0.2fms (Early)",-mean*1000)
		else
			self:settext("Mean Offset: n/a")
		end
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(-frameWidth/2+3,frameHeight/2+10+frame2Height/3*2):halign(0):zoom(0.35)
		self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText)):diffusealpha(0.8)

		if tostring(stddev) == tostring(0/0) then
			self:settext("Std. Deviation: n/a")
		else
			self:settextf("Std. Deviation: %0.2fms",stddev*1000)
		end
	end
}


return t