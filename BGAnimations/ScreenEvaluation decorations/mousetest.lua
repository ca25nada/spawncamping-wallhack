local t = Def.ActorFrame {
    LoadFont("Common Normal") .. {
        Name="MouseXY";
        InitCommand=cmd(xy,SCREEN_CENTER_X,390;zoom,0.35);
        BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." // "..GAMESTATE:GetCurrentSong():GetDisplayArtist(););
    };

};

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
    self:GetChild("MouseXY"):settextf("X:%5.2f Y:%5.2f",INPUTFILTER:GetMouseX(),INPUTFILTER:GetMouseY())
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


return t;