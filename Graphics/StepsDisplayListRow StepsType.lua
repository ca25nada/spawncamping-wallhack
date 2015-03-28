local sString;
local t = Def.ActorFrame{
	
	LoadFont("Common normal")..{
		InitCommand=cmd(zoom,0.3);
		SetMessageCommand=function(self,param)
			if param.StepsType then
				sString = THEME:GetString("StepsDisplay StepsType",ToEnumShortString(param.StepsType));
				self:settext(sString);
			end;
		end;
	};
};

return t;