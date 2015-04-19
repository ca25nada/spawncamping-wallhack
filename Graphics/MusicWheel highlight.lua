return Def.ActorFrame{
	
	Def.Quad{
		Name="Horizontal";
		InitCommand=cmd(xy,SCREEN_WIDTH*(-50/853),-2;zoomto,SCREEN_WIDTH*(400/853),34;halign,0;);
		SetCommand=function(self)
			self:diffuseramp();
			self:effectclock("Beat")
			self:effectcolor1(color("#FFFFFF11"));
			self:effectcolor2(color("#FFFFFF33"));
		end;
		BeginCommand=cmd(queuecommand,"Set");
		OffCommand=cmd(visible,false);
	};

};