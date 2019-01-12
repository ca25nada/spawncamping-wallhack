local gc = Var("GameCommand")

return Def.ActorFrame {
	LoadFont("Common Normal") .. {
		Text=THEME:GetString("ScreenTitleMenu",gc:GetText()),
		OnCommand=function(self)
			self:halign(0):zoom(0.5)
		end,
		GainFocusCommand=function(self)
			self:diffusealpha(1)
		end,
		LoseFocusCommand=function(self)
			self:diffusealpha(0.5)
		end
	}
}