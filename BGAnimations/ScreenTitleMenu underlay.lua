if IsSMOnlineLoggedIn() then
	CloseConnection()
end

t = Def.ActorFrame{}

local frameX = THEME:GetMetric("ScreenTitleMenu","ScrollerX")-10
local frameY = THEME:GetMetric("ScreenTitleMenu","ScrollerY")

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:draworder(-300):xy(frameX,frameY):zoomto(SCREEN_WIDTH,136):halign(0):diffuse(getMainColor('highlight')):diffusealpha(1)
	end	
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(SCREEN_WIDTH-5,frameY-70):zoom(0.5):valign(1):halign(1)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s v%s %s",getThemeName(),getThemeVersion(),getThemeDate()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,5):zoom(0.4):valign(0):halign(0)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s %s",ProductFamily(),ProductVersion()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,16):zoom(0.3):valign(0):halign(0)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s Songs in %s Groups",SONGMAN:GetNumSongs(),SONGMAN:GetNumSongGroups()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,SCREEN_HEIGHT-15):zoom(0.4):valign(1):halign(0)
	end,
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext("Online")
			self:diffuse(getMainColor('enabled'))
		else
			self:settext("Offline")
			self:diffuse(getMainColor('disabled'))
		end
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,SCREEN_HEIGHT-5):zoom(0.35):valign(1):halign(0):diffuse(color("#666666"))
	end,
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext(GetServerName())
			self:diffuse(color("#FFFFFF"))
		else
			self:settext("Not Available")
		end
	end
}

return t