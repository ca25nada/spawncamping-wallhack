local moveUpP1 = false
local moveDownP1 = false
local moveUpP2 = false
local moveDownP2 = false

local laneColor = color("#333333")

local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

local isCentered = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player")) and GAMESTATE:GetNumPlayersEnabled() == 1-- load from prefs later
local width = 64*cols
local padding = 8
local styleType = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

local enabledP1 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover and GAMESTATE:IsPlayerEnabled(PLAYER_1)
local isReverseP1 = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingReverse()

local enabledP2 = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).LaneCover  and GAMESTATE:IsPlayerEnabled(PLAYER_2)
local isReverseP2 = GAMESTATE:GetPlayerState(PLAYER_2):GetCurrentPlayerOptions():UsingReverse()

local heightP1 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCoverHeight
local heightP2 = playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).LaneCoverHeight

local P1X = SCREEN_CENTER_X
local P2X = SCREEN_CENTER_X
if not isCentered then
	P1X = THEME:GetMetric("ScreenGameplay",string.format("PlayerP1%sX",styleType))
	P2X = THEME:GetMetric("ScreenGameplay",string.format("PlayerP2%sX",styleType))
end;

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
		end;
		if params.PlayerNumber == PLAYER_2 then
			if params.Name == "LaneUp" then
				moveUpP2 = true
			elseif params.Name == "LaneDown" then
				moveDownP2 = true
			else
				moveDownP2 = false
				moveUpP2 = false
			end
		end;
		self:playcommand("SavePrefs")
	end;
	SavePrefsCommand=function(self)
		if enabledP1 then
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCoverHeight = heightP1
			playerConfig:set_dirty(pn_to_profile_slot(PLAYER_1))
			playerConfig:save(pn_to_profile_slot(PLAYER_1))
		end;
		if enabledP2 then
			playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).LaneCoverHeight = heightP2
			playerConfig:set_dirty(pn_to_profile_slot(PLAYER_2))
			playerConfig:save(pn_to_profile_slot(PLAYER_2))
		end;
	end;
}

if enabledP1 then
	t[#t+1] = Def.Quad{
		Name="CoverP1";
		InitCommand=cmd(xy,P1X,SCREEN_TOP;zoomto,width+padding,heightP1;valign,0;diffuse,laneColor);
		BeginCommand=function(self)
			if isReverseP1 then
				self:y(SCREEN_TOP)
				self:valign(0)
			else
				self:y(SCREEN_BOTTOM)
				self:valign(1)
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		Name="CoverTextP1";
		InitCommand=cmd(x,P1X;settext,0;valign,1;zoom,0.5;);
		BeginCommand=function(self)
			if isReverseP1 then
				self:y(heightP1-5)
				self:valign(1)
			else
				self:y(SCREEN_BOTTOM-heightP1+5)
				self:valign(0)
			end;
			self:finishtweening()
			self:diffusealpha(1)
			self:sleep(0.25)
			self:smooth(0.75)
			self:diffusealpha(0)
		end;
	};
end;

if enabledP2 then
	t[#t+1] = Def.Quad{
		Name="CoverP2";
		InitCommand=cmd(xy,P2X,SCREEN_TOP;zoomto,width+padding,heightP2;valign,0;diffuse,laneColor);
		BeginCommand=function(self)
			if isReverseP2 then
				self:y(SCREEN_TOP)
				self:valign(0)
			else
				self:y(SCREEN_BOTTOM)
				self:valign(1)
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		Name="CoverTextP2";
		InitCommand=cmd(x,P2X;settext,0;valign,1;zoom,0.5;);
		BeginCommand=function(self)
			if isReverseP2 then
				self:y(heightP2-5)
				self:valign(1)
			else
				self:y(SCREEN_BOTTOM-heightP2+5)
				self:valign(0)
			end;
			self:finishtweening()
			self:diffusealpha(1)
			self:sleep(0.25)
			self:smooth(0.75)
			self:diffusealpha(0)
		end;
	};
end;

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	if enabledP1 then
		if moveDownP1 then
			if isReverseP1 then
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1+1))
			else
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1-1))
			end;
		end;
		if moveUpP1 then
			if isReverseP1 then
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1-1))
			else
				heightP1 = math.min(SCREEN_BOTTOM,math.max(0,heightP1+1))
			end;
		end;

		self:GetChild("CoverP1"):zoomy(heightP1)
		self:GetChild("CoverTextP1"):settext(heightP1)
		if isReverseP1 then
			self:GetChild("CoverTextP1"):y(heightP1-5)
		else
			self:GetChild("CoverTextP1"):y(SCREEN_BOTTOM-heightP1+5)
		end;

		if moveDownP1 or moveUpP1 then
			self:GetChild("CoverTextP1"):finishtweening()
			self:GetChild("CoverTextP1"):diffusealpha(1)
			self:GetChild("CoverTextP1"):sleep(0.25)
			self:GetChild("CoverTextP1"):smooth(0.75)
			self:GetChild("CoverTextP1"):diffusealpha(0)
		end;

	end;

	if enabledP2 then
		if moveDownP2 then
			if isReverseP2 then
				heightP2 = math.min(SCREEN_BOTTOM,math.max(0,heightP2+1))
			else
				heightP2 = math.min(SCREEN_BOTTOM,math.max(0,heightP2-1))
			end;
		end;
		if moveUpP2 then
			if isReverseP2 then
				heightP2 = math.min(SCREEN_BOTTOM,math.max(0,heightP2-1))
			else
				heightP2 = math.min(SCREEN_BOTTOM,math.max(0,heightP2+1))
			end;
		end;
		self:GetChild("CoverP2"):zoomy(heightP2)
		self:GetChild("CoverTextP2"):settext(heightP2)
		if isReverseP2 then
			self:GetChild("CoverTextP2"):y(heightP2-5)
		else
			self:GetChild("CoverTextP2"):y(SCREEN_BOTTOM-heightP2+5)
		end;

		if moveDownP2 or moveUpP2 then
			self:GetChild("CoverTextP2"):finishtweening()
			self:GetChild("CoverTextP2"):diffusealpha(1)
			self:GetChild("CoverTextP2"):sleep(0.25)
			self:GetChild("CoverTextP2"):smooth(0.75)
			self:GetChild("CoverTextP2"):diffusealpha(0)
		end;
	end;
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


return t