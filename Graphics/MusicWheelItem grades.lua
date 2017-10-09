return Def.ActorFrame{
	LoadFont("Common Bold") .. {
        InitCommand=cmd(xy,16,-1;zoom,0.5;maxwidth,WideScale(get43size(20),20)/0.5);
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
}