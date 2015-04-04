local t = Def.ActorFrame {
        LoadFont("Common Normal") .. {
                Name="Player1BPM";
				InitCommand=cmd(x,5;y,25;halign,0;zoom,0.40;halign,0;shadowlength,1);
        };
        LoadFont("Common Normal") .. {
                Name="Player2BPM";
                InitCommand=cmd(x,SCREEN_WIDTH-5;y,25;halign,1;zoom,0.4;shadowlength,1);
        };
};

function getPlayerBPM(pn)
	local pn = GAMESTATE:GetMasterPlayerNumber()
	local songPosition = GAMESTATE:GetPlayerState(pn):GetSongPosition()
	local bpm = SCREENMAN:GetTopScreen():GetTrueBPS(pn) * 60
	return string.format("%03.2f",bpm)
end;

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		self:GetChild("Player1BPM"):settext(getPlayerBPM(PLAYER_1).." BPM")
	else
		self:GetChild("Player1BPM"):visible(false)
	end;

	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		self:GetChild("Player2BPM"):settext(getPlayerBPM(PLAYER_2).." BPM")
	else
		self:GetChild("Player2BPM"):visible(false)
	end;


end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


return t;