local co
local function update(self, delta)
	--SCREENMAN:SystemMessage(delta)
	if coroutine.status(co) ~= "dead" then
		coroutine.resume(co)
	end
end

local barMaxHeight = 200
local barCurMaxValue = 0
local maxMSD = 40
local MSDTable = {}
for i = 1, maxMSD+1 do
	MSDTable[i] = 0
end

local song = GAMESTATE:GetCurrentSong()
local group
if song == nil then
	group = GHETTOGAMESTATE.lastSelectedFolder
else
	group = song:GetGroupName()
end

local function updateFromGroup()
	local songs = SONGMAN:GetSongsInGroup(group)
	local steps
	local numSongs = #songs
	local numSteps = 0

	for k,v in ipairs(songs) do

		local steps = v:GetAllSteps()
		numSteps = numSteps + #steps

		for k2, v2 in ipairs(steps) do
			local msd = v2:GetMSD(getCurRateValue(), 1)
			if msd > maxMSD then
				MSDTable[maxMSD+1] = MSDTable[maxMSD+1]+  1
				barCurMaxValue = math.max(barCurMaxValue, MSDTable[maxMSD+1])

			else
				MSDTable[math.floor(msd)+1] = MSDTable[math.floor(msd)+1] + 1
				barCurMaxValue = math.max(barCurMaxValue, MSDTable[math.floor(msd)+1])

			end

		end
		MESSAGEMAN:Broadcast("Yield", {numSongs = k, numSteps = numSteps})
		coroutine.yield()
	end

	MESSAGEMAN:Broadcast("Update", {group = group, numSongs = numSongs, numSteps = numSteps})
end

local function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end
	end

	return false

end


local pn = GAMESTATE:GetEnabledPlayers()[1]

local frameWidth = SCREEN_WIDTH - 20
local frameHeight = 40

local function topRow()
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
			self:scaletoclipped(96, 30)
			local bnpath = SONGMAN:GetSongGroupBannerPath(group)
			if not bnpath or bnpath == "" then
				bnpath = THEME:GetPathG("Common", "fallback banner")
			end
			self:LoadBackground(bnpath)
		end
	}

	t[#t+1] = LoadFont("Common BLarge") .. {
		Name = "SongTitle",
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 96 +10, -2)
			self:zoom(0.3)
			self:halign(0)
			self:settext(group)
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-5,9)
			self:zoom(0.35)
			self:halign(1)
			self:playcommand("Set")
		end,
		YieldMessageCommand = function(self, params)
			self:settextf("%d Songs / %d Steps", params.numSongs, params.numSteps)
		end
	}

	return t
end

local function barGraphBars(i)
	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(20*i,SCREEN_HEIGHT-50)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(-5)
			self:diffuse(getMSDColor(i))
			self:valign(1)
		end,
		YieldMessageCommand = function(self)
			self:zoomto(10,MSDTable[i]/barCurMaxValue*barMaxHeight)
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		YieldMessageCommand = function(self)
			self:zoom(0.4)
			self:diffuse(color("#000000"))
			self:settextf("%d", MSDTable[i])
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:y(10)
			self:zoom(0.4)
			self:diffuse(getMSDColor(i))
			if i == 1 then
				self:settext("N/A")
			elseif i == maxMSD+1 then
				self:settextf("%d+", i-1)
			else
				self:settextf("%d", i-1)
			end
		end
	}

	return t

end


local top

local t = Def.ActorFrame {
	OnCommand = function(self)
		self:SetUpdateFunction(update)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		co = coroutine.create(updateFromGroup)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
	end
}

t[#t+1] = topRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
	end
}

for i=1, maxMSD+1 do
	t[#t+1] = barGraphBars(i)
end



t[#t+1] = LoadActor("../_mouse", "ScreenGroupInfo")

t[#t+1] = LoadActor("../_frame")
--[[
local tab = TAB:new({"Difficulty Distribution"})
t[#t+1] = tab:makeTabActors() .. {
	OnCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
		self:easeOut(0.5)
		self:y(SCREEN_HEIGHT-tab.height/2)
	end,
	OffCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2)
	end,
	TabPressedMessageCommand = function(self, params)
	end
}
]]

t[#t+1] = LoadActor("../_cursor")

return t