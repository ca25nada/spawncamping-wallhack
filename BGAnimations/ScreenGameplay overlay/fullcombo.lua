-- Stuff that shows effects upon fullcombo ,etc.

local flag = false
local song = GAMESTATE:GetCurrentSong()
local curBeat = 0 
local lastBeat = song:GetLastBeat()

local t = Def.ActorFrame{}

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
    curBeat = GAMESTATE:GetSongBeat()
    if curBeat > lastBeat+1 and flag == false then
    	flag = true

    	for _,v in pairs(GAMESTATE:GetEnabledPlayers()) do
	    	if isFullCombo(v) then
	    		MESSAGEMAN:Broadcast("FullCombo",{pn = v})
	    	end
	    end
    end
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);

return t