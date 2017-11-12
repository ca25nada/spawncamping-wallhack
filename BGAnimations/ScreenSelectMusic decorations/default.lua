local t = Def.ActorFrame{}
t[#t+1] = LoadActor("songinfo");

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:rotationz(-90):xy(SCREEN_CENTER_X/2-WideScale(get43size(150),150),SCREEN_HEIGHT-50):diffusealpha(0)
	end;
	OffCommand=function(self)
		self:stoptweening()
		self:bouncy(0.3)
		self:y(SCREEN_HEIGHT-50)
		self:diffusealpha(0)
	end;

	OnCommand=function(self)
		self:stoptweening()
		self:bouncy(0.3)
		self:xy(SCREEN_CENTER_X/2-WideScale(get43size(150),150),270)
		self:diffusealpha(1)
		wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
	end;
	TabChangedMessageCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:playcommand("On");
		else 
			self:playcommand("Off");
		end;
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:playcommand("PositionSet")
	end;
	Def.StepsDisplayList {
		Name="StepsDisplayListRow";

		CursorP1 = Def.ActorFrame {
			InitCommand=function(self)
				self:player(PLAYER_1):rotationz(90):diffusealpha(0.6)
			end;
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true)
					self:zoom(0):bounceend(1):zoom(1)
				end;
			end;
			PlayerUnjoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true)
					self:zoom(0):bounceend(1):zoom(1)
				end;
			end;
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(65,65):diffuseshift():effectperiod(1):effectcolor1(color("#FFFFFF11")):effectcolor2(PlayerColor(PLAYER_1))
				end;
				BeginCommand=function(self)
					self:queuecommand("Set")
				end;
				SetCommand=function(self)
				end;
				PlayerJoinedMessageCommand=function(self)
					self:playcommand("Set")
				end;
				PlayerUnjoinedMessageCommand=function(self)
					self:playcommand("Set")
				end;
			};
		};
		CursorP2 = Def.ActorFrame {
			InitCommand=function(self)
				self:player(PLAYER_2):diffusealpha(0.6)
			end;
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_2 then
					self:visible(true);
					self:zoom(0):bounceend(1):zoom(1)
				end;
			end;
			PlayerUnjoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_2 then
					self:visible(true);
					self:zoom(0):bounceend(1):zoom(1)
				end;
			end;
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(65,65):sleep(0.5):diffuseshift():effectperiod(1):effectcolor2(color("#FFFFFF11")):effectcolor1(PlayerColor(PLAYER_2))
				end;
				BeginCommand=function(self)
					self:queuecommand("Set")
				end;
				SetCommand=function(self)
				end;
				PlayerJoinedMessageCommand=function(self)
					self:playcommand("Set")
				end;
				PlayerUnjoinedMessageCommand=function(self)
					self:playcommand("Set")
				end;
			};
		};
		CursorP1Frame = Def.Actor{
			ChangeCommand=function(self)
				self:stoptweening():decelerate(0.1)
			end;
		};
		CursorP2Frame = Def.Actor{
			ChangeCommand=function(self)
				self:stoptweening():decelerate(0.1)
			end;
		};
	};
};

return t