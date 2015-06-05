--file containing stuff for cursors.
--this should only be loaded by screen overlays, 
--otherwise the inputcallback function won't be able to find the actors.

local function input(event)
	local top = SCREENMAN:GetTopScreen():GetChildren().Overlay
	if event.DeviceInput.button == 'DeviceButton_left mouse button' then
		if event.type == "InputEventType_Release" then
			local click = top:GetChild("Cursor"):GetChild("CursorClick")
				click:finishtweening()
				click:xy(INPUTFILTER:GetMouseX(),INPUTFILTER:GetMouseY())
				click:diffusealpha(1)
				click:zoom(0)
				click:decelerate(0.3)
				click:diffusealpha(0)
				click:zoom(1)
		end;
	end;
return false;
end;

local t = Def.ActorFrame{
	Name="Cursor";
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(input) end;
}
--[[
t[#t+1] = LoadFont("Common Normal") .. {
    Name="MouseXY";
    InitCommand=cmd(xy,SCREEN_CENTER_X,390;zoom,0.35);
    BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." // "..GAMESTATE:GetCurrentSong():GetDisplayArtist(););
};
t[#t+1] = LoadFont("Common Normal") .. {
    Name="FullScreen";
    InitCommand=cmd(xy,SCREEN_CENTER_X,400;zoom,0.35);
};
--]]
t[#t+1] = Def.Quad{
	Name="Cursor";
	InitCommand=cmd(xy,0,0;zoomto,4,4;rotationz,45;);
};

t[#t+1] = LoadActor(THEME:GetPathG("","_circle")) .. {
	Name="CursorClick";
	InitCommand=cmd(diffusealpha,0);
};

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
    --self:GetChild("MouseXY"):settextf("X:%5.2f Y:%5.2f W:%5.2f",INPUTFILTER:GetMouseX(),INPUTFILTER:GetMouseY(),INPUTFILTER:GetMouseWheel())
    if not PREFSMAN:GetPreference("Windowed") then
   		self:GetChild("Cursor"):xy(INPUTFILTER:GetMouseX(),INPUTFILTER:GetMouseY())
   		self:GetChild("Cursor"):visible(true)
   	else
   		self:GetChild("Cursor"):visible(false)
   	end;
    --self:GetChild("FullScreen"):settextf("FullScreen: %s",tostring(not PREFSMAN:GetPreference("Windowed")))
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);

return t