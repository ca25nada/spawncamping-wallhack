local t = Def.ActorFrame{}
t[#t+1] = LoadActor("songinfo");
t[#t+1] = LoadActor("simfile");
t[#t+1] = LoadActor("score");
t[#t+1] = LoadActor("profile");
t[#t+1] = LoadActor("other");

t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(rotationz,-90;xy,SCREEN_CENTER_X/2-WideScale(get43size(150),150),SCREEN_HEIGHT-50;diffusealpha,0);
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
			InitCommand=cmd(player,PLAYER_1;rotationz,90;diffusealpha,0.6);
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true);
					(cmd(zoom,0;bounceend,1;zoom,1))(self);
				end;
			end;
			PlayerUnjoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true);
					(cmd(bouncebegin,1;zoom,0))(self);
				end;
			end;
			Def.Quad{
				InitCommand=cmd(zoomto,65,65;diffuseshift;effectperiod,1;effectcolor1,color("#FFFFFF11");effectcolor2,PlayerColor(PLAYER_1));
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
				end;
				PlayerJoinedMessageCommand=cmd(playcommand,"Set");
				PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
			};
		};
		CursorP2 = Def.ActorFrame {
			InitCommand=cmd(player,PLAYER_2;diffusealpha,0.6);
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_2 then
					self:visible(true);
					(cmd(zoom,0;bounceend,1;zoom,1))(self);
				end;
			end;
			PlayerUnjoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_2 then
					self:visible(true);
					(cmd(bouncebegin,1;zoom,0))(self);
				end;
			end;
			Def.Quad{
				InitCommand=cmd(zoomto,65,65;sleep,0.5;diffuseshift;effectperiod,1;effectcolor2,color("#FFFFFF11");effectcolor1,PlayerColor(PLAYER_2));
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
				end;
				PlayerJoinedMessageCommand=cmd(playcommand,"Set");
				PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
			};
		};
		CursorP1Frame = Def.Actor{
			ChangeCommand=cmd(stoptweening;decelerate,0.1);
		};
		CursorP2Frame = Def.Actor{
			ChangeCommand=cmd(stoptweening;decelerate,0.1);
		};
	};
};

return t