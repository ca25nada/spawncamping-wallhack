local timingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
local W5Window = PREFSMAN:GetPreference("TimingWindowSecondsW5") -- Timing window for Bads

local dotWidth = 2
local dotHeight = 2

-- shamelessly lifted straight from Til Death in Etterna .64:
local judges = {"marv", "perf", "great", "good", "boo", "miss"}
local tst = ms.JudgeScalers
local judge = GetTimingDifficulty()
local tso = tst[judge]

local enabledCustomWindows = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomEvaluationWindowTimings
judge = enabledCustomWindows and 0 or judge
local customWindowsData = timingWindowConfig:get_data()
local customWindows = customWindowsData.customWindows
local customWindow
local maxOffset = math.max(180, 180 * tso)


local dvt = {}
local nrt = {}
local ctt = {}
local ntt = {}
local wuab = {}
local finalSecond = GAMESTATE:GetCurrentSong(PLAYER_1):GetLastSecond()
local td = GAMESTATE:GetCurrentSteps(PLAYER_1):GetTimingData()

local handspecific = false
local left = false
local setWidth = 0
local setHeight = 0

local function fitX(x) -- Scale time values to fit within plot width.
	if finalSecond == 0 then
		return 0
	end
	return x / finalSecond * setWidth - setWidth / 2
end

local function fitY(y) -- Scale offset values to fit within plot height
	return -1 * y / maxOffset * setHeight / 2
end
local function setOffsetVerts(vt, x, y, c)
	vt[#vt + 1] = {{x - dotWidth/2, y + dotWidth/2, 0}, c}
	vt[#vt + 1] = {{x + dotWidth/2, y + dotWidth/2, 0}, c}
	vt[#vt + 1] = {{x + dotWidth/2, y - dotWidth/2, 0}, c}
	vt[#vt + 1] = {{x - dotWidth/2, y - dotWidth/2, 0}, c}
end
-----

local baralpha = 0.4

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:RunCommandsOnChildren(function(self)
			local params = {width = 0, height = 0, song = nil, steps = nil, nrv = {}, dvt = {}, ctt = {}, ntt = {}}
			self:playcommand("Update", params) end
		)
	end
}

t[#t+1] = Def.Quad{
	Name = "Background",
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end,
	UpdateCommand = function(self, params)
		setWidth = params.width
		setHeight = params.height
		self:zoomto(params.width, params.height)
	end
}

t[#t+1] = Def.Quad{
	Name = "Center Line",
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:diffusealpha(baralpha)
	end,
	UpdateCommand = function(self, params)
		self:xy(0,params.height/2)
		self:zoomto(params.width,1)
	end
}

local fantabars = {22.5, 45, 90, 135}
local bantafars = {"TapNoteScore_W2", "TapNoteScore_W3", "TapNoteScore_W4", "TapNoteScore_W5"}
for i = 1, #fantabars do
	t[#t + 1] =
		Def.Quad {
		InitCommand = function(self)
			self:halign(0):valign(0)
		end,
		UpdateCommand = function(self, params)
			self:zoomto(params.width, 1):diffuse(byJudgment(bantafars[i])):diffusealpha(baralpha)
			local fit = (enabledCustomWindows and judge ~= 0) and customWindow.judgeWindows[judges[i]] or tso * fantabars[i]
			self:y(fitY(fit) + params.height/2)
		end
	}
	t[#t + 1] =
		Def.Quad {
		InitCommand = function(self)
			self:halign(0):valign(0)
		end,
		UpdateCommand = function(self, params)
			self:zoomto(params.width, 1):diffuse(byJudgment(bantafars[i])):diffusealpha(baralpha)
			local fit = (enabledCustomWindows and judge ~= 0) and customWindow.judgeWindows[judges[i]] or tso * fantabars[i]
			self:y(fitY(-fit) + params.height/2)
		end
	}
end

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.3):halign(0):valign(0):diffusealpha(0.4)
	end,
	UpdateCommand = function(self)
		self:xy(5,5)
		self:settextf("Early (-%d ms)", maxOffset)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.3):halign(0):valign(1):diffusealpha(0.4)
	end,
	UpdateCommand = function(self, params)
		self:xy(5,params.height-5)
		self:settextf("Late (+%d ms)", maxOffset)
	end
}

t[#t+1] = Def.ActorMultiVertex{
	UpdateCommand = function(self, params)
		local verts = {}
		
		if params.song == nil or params.steps == nil or params.nrv == nil or params.dvt == nil then
			self:SetVertices(verts)
			self:SetDrawState{Mode="DrawMode_Quads", First = 1, Num = #verts}
			return
		end

		for i = 1, #params.nrv do
			wuab[i] = td:GetElapsedTimeFromNoteRow(params.nrv[i])
		end

		local songLength = params.song:GetLastSecond()

		for i=1, #params.nrv do
			local timestamp = params.steps:GetTimingData():GetElapsedTimeFromNoteRow(params.nrv[i])
			local offset = params.dvt[i]/1000

			local color =
				(enabledCustomWindows and judge ~= 0) and customOffsetToJudgeColor(params.dvt[i], customWindow.judgeWindows) or
				offsetToJudgeColor(params.dvt[i], tst[judge])

			local x = fitX(wuab[i]) + params.width / 2
			local y = fitY(params.dvt[i]) + params.height / 2
			--local x = (timestamp/songLength) * params.width
			--local y = (offset/W5Window/2/timingWindowScale) * params.height + (params.height/2)

			if math.abs(offset) > (W5Window * timingWindowScale) then
				-- Misses
				verts[#verts+1] = {{x-dotWidth/2, params.height,0}, Alpha(color, 0.3)}
				verts[#verts+1] = {{x+dotWidth/2, params.height,0}, Alpha(color, 0.3)}
				verts[#verts+1] = {{x+dotWidth/2, 0,0}, Alpha(color, 0.3)}
				verts[#verts+1] = {{x-dotWidth/2, 0,0}, Alpha(color, 0.3)}
			else
				-- Everything else
				setOffsetVerts(verts, x, y, color)
			end

		end

		self:SetVertices(verts)
		self:SetDrawState{Mode="DrawMode_Quads", First = 1, Num = #verts}
	end
}




return t