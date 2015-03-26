--local t = Def.ActorFrame{};

local path = "../../"..getAvatarPath(PLAYER_1)
--local path = "../../Graphics/Player avatar/35d18de7965ebd26"

local t = LoadActor(path)..{
	Name="Avatar";
	InitCommand=cmd(visible,true;zoomto,70,70;halign,0;valign,1;xy,0,SCREEN_HEIGHT);
};

return t;