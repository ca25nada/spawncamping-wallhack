local width = 300
local height = 5
local frameX = SCREEN_CENTER_X
local frameY = SCREEN_BOTTOM-20

local t = Def.ActorFrame {
    Def.Quad{
    	Name="ProgressBG";
    	InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;zoomto,width,height;halign,0;diffusealpha,0.7;);
    };
    Def.Quad{
    	Name="ProgressFG";
    	InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;zoomto,0,height;halign,0;diffuse,getMainColor(3));
    };
};
function getMusicProgress()
	local songLength = GAMESTATE:GetCurrentSong():GetStepsSeconds()
	local songPosition = GAMESTATE:GetSongPosition():GetMusicSeconds()
	songLength = math.max(1,songLength)
	return math.min(1,math.max(0,songPosition/songLength))
end;

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	self:GetChild("ProgressFG"):zoomx(width*getMusicProgress())
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


return t;