--=======================================
--ONLY EDIT THESE VALUES
--=======================================
local width = capWideScale(get43size(300),300)
local height = 7
local frameX = SCREEN_CENTER_X
local frameY = SCREEN_BOTTOM-20
--=======================================

local t = Def.ActorFrame {
    Def.Quad{
    	Name="ProgressBG";
    	InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;zoomto,width,height;halign,0;diffuse,color("#666666");diffusealpha,0.7;);
    };
    Def.Quad{
    	Name="ProgressFG";
    	InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;zoomto,0,height;halign,0;diffuse,getMainColor(2));
    };
    LoadFont("Common Normal") .. {
        Name="Song Name";
        InitCommand=cmd(xy,SCREEN_CENTER_X,frameY;zoom,0.35;maxwidth,(width-50)/0.35;);
        BeginCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." // "..GAMESTATE:GetCurrentSong():GetDisplayArtist(););
    };
    LoadFont("Common Normal") .. {
        Name="CurrentTime";
        InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;halign,0;zoom,0.35;settext,"0:00";)
    };
    LoadFont("Common Normal") .. {
        Name="TotalTime";
        InitCommand=cmd(xy,SCREEN_CENTER_X+(width/2),frameY;halign,1;zoom,0.35;);
        BeginCommand=cmd(settext,SecondsToMMSS(GAMESTATE:GetCurrentSong():GetStepsSeconds()));
    };  
};
local function getMusicProgress()
	local songLength = GAMESTATE:GetCurrentSong():GetStepsSeconds()
	local songPosition = GAMESTATE:GetSongPosition():GetMusicSeconds()
	songLength = math.max(1,songLength)
	return math.min(1,math.max(0,songPosition/songLength))
end;

local function getCurrentTime()
    return SecondsToMMSS(math.max(0,GAMESTATE:GetSongPosition():GetMusicSeconds() or 0))
end;

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	self:GetChild("ProgressFG"):zoomx(width*getMusicProgress())
    self:GetChild("CurrentTime"):settext(getCurrentTime())
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


return t;