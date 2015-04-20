return Def.ActorFrame{
	
	Def.Quad{
		Name="Horizontal";
		InitCommand=cmd(xy,capWideScale(get43size(-50),-50),-2;zoomto,854,34;halign,0;);
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