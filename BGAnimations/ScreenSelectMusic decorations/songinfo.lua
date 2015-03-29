local t = Def.ActorFrame{};


t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,10,170;zoomto,384,20;halign,0;diffuse,color("#000000");diffusealpha,0.7);
}

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand=cmd(xy,15,170;visible,true;halign,0;zoom,0.45;maxwidth,360/0.45);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song ~= nil then
			self:settext(song:GetDisplayMainTitle().." // "..song:GetDisplayArtist())
		else
			self:settext("")
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};


return t