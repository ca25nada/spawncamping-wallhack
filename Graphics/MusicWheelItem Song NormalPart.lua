local curFolder = ""
local top
local t =  Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
	end,
	SetCommand = function(self,params)
		self:name(tostring(params.Index))
	end
}


t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(capWideScale(get43size(340),340),44)
		self:halign(0)
		self:zwrite(true):clearzbuffer(true):blend('BlendMode_NoEffect')
	end
}

t[#t+1] = quadButton(1) .. {
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(capWideScale(get43size(340),340),44)
		self:halign(0)
		self:visible(false)
	end
}

t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(capWideScale(get43size(340),340),44)
		self:halign(0)
	end,
	SetCommand = function(self)
		self:name("Wheel"..tostring(self:GetParent():GetName()))
		self:diffuse(ColorLightTone(getMainColor("frame")))
		self:diffusealpha(0.8)
	end,
	BeginCommand = function(self) self:queuecommand('Set') end,
	OffCommand = function(self) self:visible(false) end
}

if themeConfig:get_data().global.BannerWheel then
	t[#t+1] = Def.Sprite {
		InitCommand = function(self)
			self:fadeleft(1)
			self:halign(1)
			self:x(capWideScale(get43size(340),340))
		 	self:diffusealpha(0.3)
		 	self:ztest(true):ztestmode('ZTestMode_WriteOnFail')
		end,
		SetMessageCommand = function(self,params)
			local song = params.Song
			local bnpath = nil
			if song then
				bnpath = params.Song:GetBannerPath()
				if not bnpath then
					bnpath = THEME:GetPathG("Common", "fallback banner")
				end
				self:LoadBackground(bnpath)
				self:scaletocover(0,-22,capWideScale(get43size(340),340),22)
			end
		end
	}
end

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(340-5,-22+5)
		self:halign(1)
		self:zoom(0.3)
	end,
	SetMessageCommand = function(self,params)
		local song = params.Song

		if song then
			local seconds = song:GetStepsSeconds()
			self:visible(true)
			if seconds > PREFSMAN:GetPreference("MarathonVerSongSeconds") then
				self:settext("Marathon")
			elseif seconds > PREFSMAN:GetPreference("LongVerSongSeconds") then
				self:settext("Long")
			else
				self:visible(false)
			end
			self:diffuse(getSongLengthColor(seconds))
		end
	end
}

t[#t+1] = LoadActor("round_star") .. {
	InitCommand = function(self)
		self:xy(3,-16)
		self:zoom(0.25)
		self:wag()
		self:diffuse(Color.Yellow)
	end,
	SetMessageCommand = function(self,params)
		local song = params.Song
		self:visible(false)
		if song then
			if song:IsFavorited() then
				self:visible(true)
			end
		end
	end
}

return t
