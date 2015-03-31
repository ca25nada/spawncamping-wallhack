

local t = Def.ActorFrame{}
t[#t+1] = LoadActor("tabs")
--local t = LoadFallbackB();
t[#t+1] = LoadActor("songinfo");
t[#t+1] = LoadActor("currenttime");
t[#t+1] = LoadActor("stars");
--t[#t+1] = StandardDecorationFromFileOptional("StepsDisplayList","StepsDisplayList");
--t[#t+1] = LoadActor("../_frame");


t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(xy,410,72,halign,0;valign,0);
	OffCommand=cmd(bouncebegin,0.2;xy,410-500,72;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,410,72;);
	CodeMessageCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 0 then
			self:playcommand("On");
		else 
			self:playcommand("Off");
		end;
	end;
	CurrentSongChangedMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong(); 
		if song then
-- 			self:setaux(0);
			self:finishtweening();
			self:playcommand("TweenOn");
		elseif not song and self:GetZoomX() == 1 then
-- 			self:setaux(1);
			self:finishtweening();
			self:playcommand("TweenOff");
		end;
	end;
	Def.Quad {
		InitCommand=cmd(y,-14;zoomto,164,2;fadeleft,8/164;faderight,8/164);
		OnCommand=cmd(diffuse,Color("Black");diffusealpha,0;linear,0.35;diffusealpha,0.5);
	};
	Def.Quad {
		InitCommand=cmd(y,24*(5)-10;zoomto,164,2;fadeleft,8/164;faderight,8/164);
		OnCommand=cmd(diffuse,Color("Black");diffusealpha,0;linear,0.35;diffusealpha,0.5);
	};
	Def.StepsDisplayList {
		Name="StepsDisplayListRow";

		CursorP1 = Def.ActorFrame {
			InitCommand=cmd(x,55;player,PLAYER_1);
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
				InitCommand=cmd(zoomto,6,22;halign,1;valign,0.5);
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
					if GAMESTATE:GetNumPlayersEnabled()>=2 then
						self:zoomy(11);
						self:valign(1);
					else
						self:zoomy(22);
						self:valign(0.5);
					end;
				end;
				PlayerJoinedMessageCommand=cmd(playcommand,"Set");
				PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
			};
			LoadFont("Common Normal") .. {
				InitCommand=cmd(x,-1;halign,1;valign,0.5;zoom,0.3;diffuse,color("#000000"));
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
					self:settext('1')
					if GAMESTATE:GetNumPlayersEnabled()>=2 then
						self:y(-6)
					else
						self:y(0)
					end;
				end;
				PlayerJoinedMessageCommand=cmd(playcommand,"Set");
				PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
			};
		};
		CursorP2 = Def.ActorFrame {
			InitCommand=cmd(x,55;player,PLAYER_2);
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
				InitCommand=cmd(zoomto,6,22;halign,1;valign,0.5);
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
					if GAMESTATE:GetNumPlayersEnabled()>=2 then
						self:zoomy(11);
						self:valign(0);
					else
						self:zoomy(22);
						self:valign(0.5);
					end;
				end;
				PlayerJoinedMessageCommand=cmd(playcommand,"Set");
				PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
			};
			LoadFont("Common Normal") .. {
				InitCommand=cmd(x,-1;halign,1;valign,0.5;zoom,0.3;diffuse,color("#000000"));
				BeginCommand=cmd(queuecommand,"Set");
				SetCommand=function(self)
					self:settext('2')
					if GAMESTATE:GetNumPlayersEnabled()>=2 then
						self:y(6)
					else
						self:y(0)
					end;
				end;
				PlayerJoinedMessageCommand=cmd(playcommand,"Set");
				PlayerUnjoinedMessageCommand=cmd(playcommand,"Set");
			};
		};
		CursorP1Frame = Def.Actor{
			ChangeCommand=cmd(stoptweening;decelerate,0.05);
		};
		CursorP2Frame = Def.Actor{
			ChangeCommand=cmd(stoptweening;decelerate,0.05);
		};
	};
};

return t