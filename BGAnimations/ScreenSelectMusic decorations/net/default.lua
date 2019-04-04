local t = Def.ActorFrame{}
t[#t+1] = LoadActor("songinfo")

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:rotationz(-90):xy(SCREEN_CENTER_X/2-WideScale(get43size(150),150),270)
		self:delayedFadeIn(5)
	end,
	OffCommand=function(self)
		self:stoptweening()
		self:sleep(0.025)
		self:smooth(0.2)
		self:diffusealpha(0) 
	end,

	OnCommand=function(self)
		wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
	end,
	CurrentSongChangedMessageCommand=function(self)
		self:playcommand("PositionSet")
	end,
	Def.StepsDisplayList {
		Name="StepsDisplayListRow",
		CursorP1 = Def.ActorFrame {
			InitCommand=function(self)
				self:player(PLAYER_1):rotationz(90):diffusealpha(0.6)
			end,
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true)
					self:zoom(0):bounceend(1):zoom(1)
				end
			end,
			PlayerUnjoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true)
					self:zoom(0):bounceend(1):zoom(1)
				end
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(65,65):diffuseshift():effectperiod(1):effectcolor1(Alpha(PlayerColor(PLAYER_1), 0.5)):effectcolor2(PlayerColor(PLAYER_1))
				end
			}
		},
		CursorP2 = Def.ActorFrame {
		},
		CursorP1Frame = Def.Actor{
			ChangeCommand=function(self)
				self:stoptweening():easeOut(0.5)
			end
		},
		CursorP2Frame = Def.Actor{
		}
	}
}

return t