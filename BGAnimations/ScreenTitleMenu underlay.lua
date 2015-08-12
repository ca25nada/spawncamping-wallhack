t = Def.ActorFrame{}

local frameX = THEME:GetMetric("ScreenTitleMenu","ScrollerX")-10
local frameY = THEME:GetMetric("ScreenTitleMenu","ScrollerY")

t[#t+1] = Def.Quad{
	InitCommand=cmd(draworder,-300;xy,frameX,frameY;zoomto,SCREEN_WIDTH,120;halign,0;diffuse,getMainColor(1);diffusealpha,1)
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,SCREEN_WIDTH-5,frameY-60;zoom,0.5;valign,1;halign,1;);
	OnCommand=function(self)
		self:settext(string.format("%s v%s %s",getThemeName(),getThemeVersion(),getThemeDate()));
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,5,5;zoom,0.4;valign,0;halign,0;);
	OnCommand=function(self)
		self:settext(string.format("%s %s",ProductFamily(),ProductVersion()));
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,5,16;zoom,0.3;valign,0;halign,0;);
	OnCommand=function(self)
		self:settext(string.format("%s %s",VersionDate(),VersionTime()));
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,5,25;zoom,0.3;valign,0;halign,0;);
	OnCommand=function(self)
		self:settext(string.format("%s Songs in %s Groups",SONGMAN:GetNumSongs(),SONGMAN:GetNumSongGroups()));
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,5,SCREEN_HEIGHT-15;zoom,0.4;valign,1;halign,0;diffuse,color("#666666"));
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext("Online")
			self:diffuse(color("#4CBB17"))
		else
			self:settext("Offline");
		end;
	end;
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,5,SCREEN_HEIGHT-5;zoom,0.35;valign,1;halign,0;diffuse,color("#666666"));
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext(GetServerName())
			self:diffuse(color("#FFFFFF"))
		else
			self:settext("Not Available");
		end;
	end;
}

return t