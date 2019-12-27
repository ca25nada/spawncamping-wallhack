-- Song Progress bar with current/end time and the song title+artist.

local bareBone = isBareBone()
--=======================================
--ONLY EDIT THESE VALUES
--=======================================
local width = SCREEN_WIDTH
local height = 15
local frameX = SCREEN_CENTER_X
local bottomModifier = -20  -- Negative value, how far up
local topModifier = 15       -- Positive value, how far down
local frameY = SCREEN_HEIGHT-height/2
local opacity = 1
--=======================================

local location = themeConfig:get_data().global.ProgressBar -- 1 is bottom, 2 is top

if location == 2 then
    frameY = height/2
end

local t = Def.ActorFrame {
    OnCommand = function(self)
        self:xy(frameX,frameY)
    end
}

t[#t+1] = Def.Quad{
	Name="ProgressBG",
	InitCommand=function(self)
		self:x(width/2):zoomto(width,height):halign(1):diffuse(color("#000000")):diffusealpha(opacity)
	end
}

t[#t+1] = Def.Quad{
	Name="ProgressFG",
	InitCommand=function(self)
		self:x(-width/2):zoomto(0,height):halign(0):diffuse(getMainColor('highlight')):diffusealpha(opacity)
	end
}


t[#t+1] = LoadFont("Common Normal") .. {
    Name="Song Name",
    InitCommand=function(self)
    	self:zoom(0.35):maxwidth((width-65)/0.35)
    end,
    SetCommand=function(self)
        local song = GAMESTATE:GetCurrentSong()
    	self:settextf("%s // %s",song:GetDisplayMainTitle(),song:GetDisplayArtist())
    end,
    BeginCommand = function(self) self:playcommand('Set') end,
    CurrentSongChangedMessageCommand = function(self) self:playcommand('Set') end
}

t[#t+1] = LoadFont("Common Normal") .. {
        Name="CurrentTime",
        InitCommand=function(self)
        	self:x(-width/2+5):halign(0):zoom(0.35):settext("0:00")
        end	
}

t[#t+1] = LoadFont("Common Normal") .. {
    Name="TotalTime",
    InitCommand=function(self)
    	self:x(width/2-5):halign(1):zoom(0.35)
    end,
    SetCommand=function(self)
        local song = GAMESTATE:GetCurrentSong()
        if song == nil then self:settext("") end
    	self:settext(SecondsToMSSMsMs(song:GetStepsSeconds()/GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate()))
    end,
    BeginCommand = function(self) self:playcommand('Set') end,
    CurrentSongChangedMessageCommand = function(self) self:playcommand('Set') end
}  



-- Returns the %of song played from 0~1.
local function getMusicProgress()
    local rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate()
	local songLength = GAMESTATE:GetCurrentSong():GetStepsSeconds()
	local songPosition = GAMESTATE:GetSongPosition():GetMusicSeconds()
    songPosition = songPosition/rate
	songLength = math.max(1,songLength/rate)
	return math.min(1,math.max(0,songPosition/songLength))
end

local function getCurrentTime()
    local rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate()
    local time = GAMESTATE:GetSongPosition():GetMusicSeconds()
    return SecondsToMSSMsMs(math.max(0,time/rate or 0))
end

local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end,
	self:GetChild("ProgressFG"):zoomx(width*getMusicProgress())
    if not bareBone then
        self:GetChild("CurrentTime"):settext(getCurrentTime())
    end
end

t.InitCommand=function(self)
    if barPosition ~= 0 then
        self:SetUpdateFunction(Update)
    else
        self:visible(false)
    end
end


return t