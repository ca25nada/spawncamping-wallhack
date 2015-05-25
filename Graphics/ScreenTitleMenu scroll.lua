local gc = Var("GameCommand");

return Def.ActorFrame {
	LoadFont("Common Normal") .. {
		Text=THEME:GetString("ScreenTitleMenu",gc:GetText());
		OnCommand=cmd(halign,0;zoom,0.5);
		GainFocusCommand=cmd(diffusealpha,1);
		LoseFocusCommand=cmd(diffusealpha,0.5);
	};
};