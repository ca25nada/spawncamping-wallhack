return Def.ActorFrame{
	LoadFont("Common Normal") .. { --testing
        InitCommand=cmd(xy,-33,-1;zoom,0.5;maxwidth,20/0.5);
        SetGradeCommand=function(self,params)
        	local player = params.PlayerNumber
			local song = params.Song
			local sGrade = params.Grade or 'Grade_None';
			if GAMESTATE:GetNumPlayersEnabled() == 2 then
				if player == PLAYER_1 then
					self:valign(1)
					self:y(-5)
				elseif player == PLAYER_2 then
					self:valign(0)
					self:y(3)
				else
					self:valign(0.5)
					self:y(-1)
				end;
			else
				self:valign(0.5)
			end;
			self:settext(THEME:GetString("Grade",ToEnumShortString(sGrade)) or "")
			self:diffuse(getGradeColor(sGrade))
        end;
	};



	--[[ Revert to letter grades for the time being
	Def.Quad{
			InitCommand=cmd(halign,1;x,-30;y,-2;zoomto,8,24;diffuse,color("#ffcccc"););
			SetGradeCommand=function(self,params)
				local player = params.PlayerNumber
				local song = params.Song
				local sGrade = params.Grade or 'Grade_None';
				if GAMESTATE:GetNumPlayersEnabled() == 2 then
					self:zoomy(12)
					if player == PLAYER_1 then
						self:valign(1)
					elseif player == PLAYER_2 then
						self:valign(0)
					else
						self:valign(0.5)
					end;
				else
					self:zoomy(24)
					self:valign(0.5)
				end;
				self:diffuse(getGradeColor(sGrade))
				
			end;
	};
	Def.Quad{
		InitCommand=cmd(halign,1;x,-30;y,-2;zoomto,8,24;blend,Blend.Add;diffusealpha,0.25);
		OnCommand=cmd(effectclock,"beat";diffuseshift;effectcolor1,color("1,1,1,0.8");effectcolor2,color("1,1,1,0.2"););
		SetGradeCommand=function(self,params)
			local sGrade = params.Grade or 'Grade_None';
			self:diffusealpha(0)
			if sGrade ~= 'Grade_None' and sGrade ~= 'Grade_Failed' then
				self:diffusealpha(0.2)
			end;
		end;
	};
	--]]
}