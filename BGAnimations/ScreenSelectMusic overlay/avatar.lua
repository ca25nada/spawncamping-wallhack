local t = Def.ActorFrame{};


local path = "../../"..getAvatarPath(PLAYER_1)



t[#t+1] = LoadActor(path)..{
	Name="Avatar";
	InitCommand=cmd(visible,true;zoomto,70,70;halign,0;valign,1;xy,0,SCREEN_HEIGHT);
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,75,SCREEN_HEIGHT-60;halign,0;zoom,0.45;diffuse,getMainColor(3));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext("uwaaaaa")
	end;
};

return t;