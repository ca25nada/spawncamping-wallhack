return Def.ActorFrame{
	
	Def.Quad{
		Name="Horizontal";
		InitCommand=cmd(x,-4;zoomto,capWideScale(get43size(348),348),52;halign,0;);
		SetCommand=function(self)
			self:diffuseramp();
			self:effectperiod(1)
			self:effectcolor1(color("#FFFFFF00"));
			self:effectcolor2(Alpha(getDifficultyColor(GAMESTATE:GetHardestStepsDifficulty()),0.2));
		end;
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

};