local t =  Def.ActorFrame{
	InitCommand=function(self)
		self:diffusealpha(0.8)
	end
}


t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(capWideScale(get43size(340),340),44)
		self:halign(0)
		self:zwrite(true):clearzbuffer(true):blend('BlendMode_NoEffect');
	end;
}

t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(0)
		self:zoomto(capWideScale(get43size(340),340),44)
		self:halign(0)
	end;
	SetCommand = function(self)
		self:diffuse(color("#111111"))
	end;
	BeginCommand = function(self) self:queuecommand('Set') end;
	OffCommand = function(self) self:visible(false) end;
}


t[#t+1] = Def.Quad{
	InitCommand= function(self) 
		self:x(30)
		self:zoomto(2,32)
		self:halign(0)
	end;

	BeginCommand = function(self) self:queuecommand('Set') end;
	OffCommand = function(self) self:visible(false) end;
}

if themeConfig:get_data().global.BannerWheel then
	t[#t+1] = Def.Banner{
		InitCommand = function(self)
			self:fadeleft(1)
			self:halign(1)
			self:x(capWideScale(get43size(340),340))
		 	self:diffusealpha(0.3)
		 	self:ztest(true):ztestmode('ZTestMode_WriteOnFail')
		end;
		SetMessageCommand = function(self,params)
			local song = params.Song
			local course = params.Course
			if song and not course then
				self:LoadFromSong(params.Song)
				self:scaletocover(0,-22,capWideScale(get43size(340),340),22)
			elseif course and not song then
				self:LoadFromCourse(params.Course)
				self:scaletocover(0,-22,capWideScale(get43size(340),340),22)
			end
		end;
	}
end

return t
