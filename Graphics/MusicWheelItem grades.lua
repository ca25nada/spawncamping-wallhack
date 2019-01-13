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
	}
}