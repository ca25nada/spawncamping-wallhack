local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)

local user = playerConfig:get_data(pn_to_profile_slot(pn)).Username
local pass = playerConfig:get_data(pn_to_profile_slot(pn)).Password
if isAutoLogin() then
	DLMAN:LoginWithToken(user, pass)
end

local replayScore
local isEval

local t = Def.ActorFrame{
	LoginFailedMessageCommand = function(self)
		SCREENMAN:SystemMessage("Login Failed!")
	end,

	LoginMessageCommand=function(self)
		SCREENMAN:SystemMessage("Login Successful!")
		GHETTOGAMESTATE:setOnlineStatus("Online")
	end,

	LogOutMessageCommand=function(self)
		SCREENMAN:SystemMessage("Logged Out!")
		GHETTOGAMESTATE:setOnlineStatus("Local")
	end
}


t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:y(SCREEN_HEIGHT):halign(0):valign(1):zoomto(SCREEN_WIDTH,200):diffuse(getMainColor("background")):fadetop(1)
	end
}


t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("tabs")

t[#t+1] = StandardDecorationFromFileOptional("BPMDisplay","BPMDisplay")
t[#t+1] = StandardDecorationFromFileOptional("BPMLabel","BPMLabel")
t[#t+1] = LoadActor("../_cursor")

local largeImageText = string.format("%s: %5.2f",profile:GetDisplayName(), profile:GetPlayerRating())
GAMESTATE:UpdateDiscordMenu(largeImageText)

return t