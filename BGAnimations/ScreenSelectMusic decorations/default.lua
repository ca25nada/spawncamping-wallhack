reset_needs_defective_field_for_all_players()

local t = Def.ActorFrame{}
t[#t+1] = LoadActor("songinfo");
t[#t+1] = LoadActor("currenttime");
t[#t+1] = LoadActor("simfile");
t[#t+1] = LoadActor("score");
t[#t+1] = LoadActor("profile");
t[#t+1] = LoadActor("other");


t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(zoom,math.min(1,SCREEN_WIDTH/854);rotationz,-90);
	OffCommand=function(self)
		self:bouncebegin(0.2)
		self:zoomx(0)
	end;

	OnCommand=function(self)
		self:bouncebegin(0.2)
		self:xy(SCREEN_CENTER_X/2-150,270)
		self:zoomx(1)
		--self:playcommand("PositionSet")
	end;
	--[[Position bugs out with charts with steps not available with the current player count.
	PositionSetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		local count = 1
		if song then
			if GAMESTATE:GetNumPlayersEnabled() == 1 then
				count = #(song:GetAllSteps())
			else
				local stype
				local steps = GAMESTATE:GetCurrentSteps(GAMESTATE:GetEnabledPlayers()[1])
				if steps ~= nil then
					stype = steps:GetStepsType()
					count = #(song:GetStepsByStepsType(stype))
				end
			end
			self:x(SCREEN_CENTER_X/2-50*(math.min(3,count-1)))
		end;
	end;
	--]]
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