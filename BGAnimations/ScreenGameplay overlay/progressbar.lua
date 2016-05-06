-- Song Progress bar with current/end time and the song title+artist.

local barPosition = themeConfig:get_data().global.ProgressBar -- 0 = bottom, 1 = top, 2 = off. 

--=======================================
--ONLY EDIT THESE VALUES
--=======================================
local width = capWideScale(get43size(300),300)
local height = 7
local frameX = SCREEN_CENTER_X
local bottomModifier = -20;  -- Negative value, how far up
local topModifier = 15;       -- Positive value, how far down
local frameY = 0
--=======================================

if barPosition == 1 then  -- BOTTOM
    frameY = SCREEN_BOTTOM + bottomModifier
elseif barPosition == 2 then -- TOP
    frameY = SCREEN_TOP + topModifier 
end

local t = Def.ActorFrame {
    Def.Quad{
    	Name="ProgressBG";
    	InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;zoomto,width,height;halign,0;diffuse,color("#666666");diffusealpha,0.7;);
    };
    Def.Quad{
    	Name="ProgressFG";
    	InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY;zoomto,0,height;halign,0;diffuse,getMainColor('highlight'));
    };
    LoadFont("Common Normal") .. {
        Name="Song Name";
        InitCommand=cmd(xy,SCREEN_CENTER_X,frameY-1;zoom,0.35;maxwidth,(width-50)/0.35;);
        SetCommand=cmd(settext,GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." // "..GAMESTATE:GetCurrentSong():GetDisplayArtist());
        BeginCommand = function(self) self:playcommand('Set') end;
        CurrentSongChangedMessageCommand = function(self) self:playcommand('Set') end;
    };
    LoadFont("Common Normal") .. {
        Name="CurrentTime";
        InitCommand=cmd(xy,SCREEN_CENTER_X-(width/2),frameY-1;halign,0;zoom,0.35;settext,"0:00";)
    };
    LoadFont("Common Normal") .. {
        Name="TotalTime";
        InitCommand=cmd(xy,SCREEN_CENTER_X+(width/2),frameY-1;halign,1;zoom,0.35;);
        SetCommand=cmd(settext,SecondsToMSSMsMs(GAMESTATE:GetCurrentSong():GetStepsSeconds()/GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate()));
        BeginCommand = function(self) self:playcommand('Set') end;
        CurrentSongChangedMessageCommand = function(self) self:playcommand('Set') end;
    };  
};


-- Returns the %of song played from 0~1.
local function getMusicProgress()
    local rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate()
	local songLength = GAMESTATE:GetCurrentSong():GetStepsSeconds()
	local songPosition = GAMESTATE:GetSongPosition():GetMusicSeconds()
    songPosition = songPosition/rate
	songLength = math.max(1,songLength/rate)
	return math.min(1,math.max(0,songPosition/songLength))
end;

local function getCurrentTime()
    local rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate()
    local time = GAMESTATE:GetSongPosition():GetMusicSeconds()
    return SecondsToMSSMsMs(math.max(0,time/rate or 0))
end;

local function Update(self)
    	t.InitCommand=cmd(SetUpdateFunction,Update);
    	self:GetChild("ProgressFG"):zoomx(width*getMusicProgress())
        self:GetChild("CurrentTime"):settext(getCurrentTime())
end; 

t.InitCommand=function(self)
    if barPosition ~= 0 then
        self:SetUpdateFunction(Update)
    else
        self:visible(false)
    end
end


return t;