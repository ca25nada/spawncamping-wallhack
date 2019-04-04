local playeroptions = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Preferred")
playeroptions:Mini(2 - playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ReceptorSize / 50)
local profile = PROFILEMAN:GetProfile(PLAYER_1)
local replaystate = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerController() == "PlayerController_Replay"
if profile:IsCurrentChartPermamirror() and not replaystate then -- turn on mirror if song is flagged as perma mirror
	playeroptions:Mirror(true)
end

setMovableKeymode(getCurrentKeyMode())


local t = Def.ActorFrame{}
t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:xy(0,0):halign(0):valign(0):zoomto(SCREEN_WIDTH,30):diffuse(color("#00000099")):fadebottom(0.8)
	end
}


return t