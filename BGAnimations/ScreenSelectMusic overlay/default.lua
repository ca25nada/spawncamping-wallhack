local t = Def.ActorFrame{}
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)

t[#t+1] = Def.Actor{};

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:y(SCREEN_HEIGHT):halign(0):valign(1):zoomto(SCREEN_WIDTH,200):diffuse(getMainColor("background")):fadetop(1)
	end;
};


t[#t+1] = LoadActor("../_frame");

t[#t+1] = LoadActor("profilecard");
t[#t+1] = LoadActor("tabs");
t[#t+1] = LoadActor("currentsort");
t[#t+1] = StandardDecorationFromFileOptional("BPMDisplay","BPMDisplay");
t[#t+1] = StandardDecorationFromFileOptional("BPMLabel","BPMLabel");
t[#t+1] = LoadActor("../_cursor");
t[#t+1] = LoadActor("bgm");

local largeImageText = string.format("%s: %5.2f",profile:GetDisplayName(), profile:GetPlayerRating())
GAMESTATE:UpdateDiscordMenu(largeImageText)

return t