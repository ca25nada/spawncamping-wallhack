return Def.ActorFrame{
	
	Def.Quad{
		Name="Horizontal";
		InitCommand=cmd(x,-4;zoomto,capWideScale(get43size(348),348),52;halign,0;);
		SetCommand=function(self)
			self:diffuseramp();
			self:effectperiod(1)
			self:effectcolor1(color("#FFFFFF11"));
			self:effectcolor2(Alpha(getMainColor("highlight"),0.3));
		end;
		BeginCommand=cmd(queuecommand,"Set");
		OffCommand=cmd(visible,false);
	};

};