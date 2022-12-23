local playeroptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Preferred")
playeroptions:Mini(2 - playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ReceptorSize / 50)

setMovableKeymode(getCurrentKeyMode())
setCurExp(PLAYER_1)

local t = Def.ActorFrame{}
t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:xy(0,0):halign(0):valign(0):zoomto(SCREEN_WIDTH,30):diffuse(color("#00000099")):fadebottom(0.8)
	end
}


return t