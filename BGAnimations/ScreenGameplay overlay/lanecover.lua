local moveUpP1 = false
local moveDownP1 = false
local moveUpP2 = false
local moveDownP2 = false

local lockSpeedP1 = false
local lockSpeedP2 = false

local laneColor = color(colorConfig:get_data().gameplay.LaneCover)

local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()


local width = GHETTOGAMESTATE:getNoteFieldWidth(PLAYER_1)
local padding = 8
local styleType = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

local prefsP1 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover
local enabledP1 = prefsP1 ~= 0 and GAMESTATE:IsPlayerEnabled(PLAYER_1)
local isReverseP1 = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingReverse()
if prefsP1 == 2 then -- it's a Hidden LaneCover
	isReverseP1 = not isReverseP1
end

local heightP1 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCoverHeight

local P1X = GHETTOGAMESTATE.getNoteFieldPos(PLAYER_1)

local function getPlayerBPM(pn)
	local songPosition = GAMESTATE:GetPlayerState(pn):GetSongPosition()
	local ts = SCREENMAN:GetTopScreen()
	local bpm = 0
	if ts:GetScreenType() == 'ScreenType_Gameplay' then
		bpm = ts:GetTrueBPS(pn) * 60
	end
	return bpm
end

local function getMaxDisplayBPM(pn)
	local song = GAMESTATE:GetCurrentSong()
	local steps = GAMESTATE:GetCurrentSteps(pn)
	if steps:GetDisplayBPMType() ~= 'DisplayBPM_Random' then
		return steps:GetDisplayBpms()[2]
	else
		return steps:GetTimingData():GetActualBPM()[2]
	end
end

local function getSpeed(pn)
	local po = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
	if po:XMod() ~= nil then
		return po:XMod()*getPlayerBPM(pn)
	elseif po:CMod() ~= nil then
		return po:CMod()
	elseif po:MMod() ~= nil then
		return po:MMod()*(getPlayerBPM(pn)/getMaxDisplayBPM(pn))
	else
		return getPlayerBPM(pn)
	end
end

local function getNoteFieldHeight(pn)
	local reverse = GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():UsingReverse()
	if reverse then
		return SCREEN_CENTER_Y + THEME:GetMetric("Player","ReceptorArrowsYReverse")
	else
		return SCREEN_CENTER_Y - THEME:GetMetric("Player","ReceptorArrowsYStandard")
	end
end

local function getScrollSpeed(pn,LaneCoverHeight)
	local height = getNoteFieldHeight(pn)
	local speed = getSpeed(pn)

	if LaneCoverHeight < height then
		return speed*(height/(height-LaneCoverHeight))
	else
		return 0
	end
end

local t = Def.ActorFrame{
	CodeMessageCommand = function(self, params)
		moveDownP1 = false
		moveUpP1 = false
		moveDownP2 = false
		moveUpP2 = false
		if params.PlayerNumber == PLAYER_1 then
			if params.Name == "LaneUp" then
				moveUpP1 = true
			elseif params.Name == "LaneDown" then
				moveDownP1 = true
			else
				moveDownP1 = false
				moveUpP1 = false
			end
		end
		if params.PlayerNumber == PLAYER_2 then
			if params.Name == "LaneUp" then
				moveUpP2 = true
			elseif params.Name == "LaneDown" then
				moveDownP2 = true
			else
				moveDownP2 = false
				moveUpP2 = false
			end
		end
		self:playcommand("SavePrefs")
	end,
	SavePrefsCommand=function(self)
		if enabledP1 then
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCoverHeight = heightP1
			playerConfig:set_dirty(pn_to_profile_slot(PLAYER_1))
			playerConfig:save(pn_to_profile_slot(PLAYER_1))
		end
	end
}

if enabledP1 then
	t[#t+1] = Def.Quad{
		Name="CoverP1",
		InitCommand=function(self)
			self:xy(P1X,SCREEN_TOP):zoomto((width+padding)*GHETTOGAMESTATE:getNoteFieldScale(PLAYER_1),heightP1):valign(0):diffuse(laneColor)
		end,
		BeginCommand=function(self)
			if isReverseP1 then
				self:y(SCREEN_TOP)
				self:valign(0)
			else
				self:y(SCREEN_BOTTOM)
				self:valign(1)
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="CoverTextP1White",
		InitCommand=function(self)
			self:x(P1X-(width*GHETTOGAMESTATE:getNoteFieldScale(PLAYER_1)/8)):settext(0):valign(1):zoom(0.5)
		end,
		BeginCommand=function(self)
			self:settext(0)
			if isReverseP1 then
				self:y(heightP1-5)
				self:valign(1)
			else
				self:y(SCREEN_BOTTOM-heightP1+5)
				self:valign(0)
			end
			self:finishtweening()
			self:diffusealpha(1)
			self:sleep(0.25)
			self:smooth(0.75)
			self:diffusealpha(0)
		end
	}
	t[#t+1] = LoadFont("Common Normal")..{
		Name="CoverTextP1Green",
		InitCommand=function(self)
			self:x(P1X+(width*GHETTOGAMESTATE:getNoteFieldScale(PLAYER_1)/8)):settext(0):valign(1):zoom(0.5):diffuse(color("#4CBB17"))
		end,
		BeginCommand=function(self)
			self:settext(math.floor(getSpeed(PLAYER_1)))
			if isReverseP1 then
				self:y(heightP1-5)
				self:valign(1)
			else
				self:y(SCREEN_BOTTOM-heightP1+5)
				self:valign(0)
			end
			self:finishtweening()
			self:diffusealpha(1)
			self:sleep(0.25)
			self:smooth(0.75)
			self:diffusealpha(0)
		end
	}
end

local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end
	if enabledP1 then
		if moveDownP1 then
			if isReverseP1 then
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1+1))
			else
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1-1))
			end
		end
		if moveUpP1 then
			if isReverseP1 then
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1-1))
			else
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1+1))
			end
		end

		self:GetChild("CoverP1"):zoomy(heightP1)
		self:GetChild("CoverTextP1White"):settext(heightP1)
		if prefsP1 == 1 then -- don't update greennumber for hidden lanecovers
			self:GetChild("CoverTextP1Green"):settext(math.floor(getScrollSpeed(PLAYER_1,heightP1)))
		end
		if isReverseP1 then
			self:GetChild("CoverTextP1White"):y(heightP1-5)
			self:GetChild("CoverTextP1Green"):y(heightP1-5)
		else
			self:GetChild("CoverTextP1White"):y(SCREEN_BOTTOM-heightP1+5)
			self:GetChild("CoverTextP1Green"):y(SCREEN_BOTTOM-heightP1+5)
		end

		if moveDownP1 or moveUpP1 then
			self:GetChild("CoverTextP1White"):finishtweening()
			self:GetChild("CoverTextP1White"):diffusealpha(1)
			self:GetChild("CoverTextP1White"):sleep(0.25)
			self:GetChild("CoverTextP1White"):smooth(0.75)
			self:GetChild("CoverTextP1White"):diffusealpha(0)
			self:GetChild("CoverTextP1Green"):finishtweening()
			self:GetChild("CoverTextP1Green"):diffusealpha(1)
			self:GetChild("CoverTextP1Green"):sleep(0.25)
			self:GetChild("CoverTextP1Green"):smooth(0.75)
			self:GetChild("CoverTextP1Green"):diffusealpha(0)
		end

	end
end
t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end


return t