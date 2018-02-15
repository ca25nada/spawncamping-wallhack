local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)

local user = playerConfig:get_data(pn_to_profile_slot(pn)).Username
local pass = playerConfig:get_data(pn_to_profile_slot(pn)).Password
if isAutoLogin() then
	DLMAN:Login(user, pass)
end


local t = Def.ActorFrame{
	LoginFailedMessageCommand = function(self)
		SCREENMAN:SystemMessage("Login Failed!")
	end;

	LoginMessageCommand=function(self)
		SCREENMAN:SystemMessage("Login Successful!")
	end;

	LogOutMessageCommand=function(self)
		SCREENMAN:SystemMessage("Logged Out!")
	end
}


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