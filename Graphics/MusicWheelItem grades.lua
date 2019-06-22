return Def.ActorFrame{
	LoadFont("Common Bold") .. {
		InitCommand=function(self)
			self:xy(16,-1):zoom(0.5):maxwidth(WideScale(get43size(20),20)/0.5)
		end,
		SetGradeCommand=function(self,params)
			local player = params.PlayerNumber
				local song = params.Song
				local sGrade = params.Grade or 'Grade_None'
				self:valign(0.5)
				self:settext(THEME:GetString("Grade",ToEnumShortString(sGrade)) or "")
				self:diffuse(getGradeColor(sGrade))
		end
	},
	Def.Quad{
		InitCommand= function(self) 
			self:x(30)
			self:zoomto(2,32)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.MusicWheelDivider))
		end,

		BeginCommand = function(self) self:queuecommand('Set') end,
		OffCommand = function(self) self:visible(false) end,
		SetCommand = function(self, params)
			if params.Song then
				local goalType = GHETTOGAMESTATE:getLowestGoalTypeBySong(params.Song)
				if goalType == 0 then -- No goals
					self:diffusebottomedge(color(colorConfig:get_data().selectMusic.MusicWheelDivider))
				elseif goalType == 1 then -- Unfinished goals
					self:diffusebottomedge(color(colorConfig:get_data().selectMusic.UnfinishedGoalGradient))
				elseif goalType == 2 then -- All goals are finished
					self:diffusebottomedge(color(colorConfig:get_data().selectMusic.CompletedGoalGradient))
				end
			end
		end
	},
	LoadActor("mirror") .. {
		InitCommand = function(self)
			self:xy(3,16)
			self:zoom(0.2)
			self:wag()
			self:diffuse(Color.Blue)
		end,
		SetGradeCommand = function(self,params)
			self:visible(false)
			if params.PermaMirror then
				self:visible(true)
			end
		end
	}
	
}