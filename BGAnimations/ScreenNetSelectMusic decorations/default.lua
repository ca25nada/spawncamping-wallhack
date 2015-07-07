local t = Def.ActorFrame{}

t[#t+1] = Def.Banner{
	InitCommand=cmd(x,10;y,60;halign,0;valign,0);
	SetMessageCommand=function(self)
		local top = SCREENMAN:GetTopScreen()
		if top:GetName() == "ScreenSelectMusic" then
			local song = GAMESTATE:GetCurrentSong()
			local course = GAMESTATE:GetCurrentCourse()
			local group = top:GetMusicWheel():GetSelectedSection()
			if song then
				self:LoadFromSong(song)
			elseif course then
				self:LoadFromCourse(song)
			elseif group then
				self:LoadFromSongGroup(group)
			end;
		elseif top:GetName() == "ScreenNetSelectMusic" then
			local song = GAMESTATE:GetCurrentSong()
			local course = GAMESTATE:GetCurrentCourse()
			local group = top:GetChild("MusicWheel"):GetSelectedSection()
			if song then
				self:LoadFromSong(song)
			elseif course then
				self:LoadFromCourse(song)
			elseif group then
				self:LoadFromSongGroup(group)
			end;
		end;
		self:scaletoclipped(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};


t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,10,60+capWideScale(get43size(120),120)-capWideScale(get43size(10),10);zoomto,capWideScale(get43size(384),384),capWideScale(get43size(20),20);halign,0;diffuse,color("#000000");diffusealpha,0.7);
}

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand=cmd(xy,15,60+capWideScale(get43size(120),120)-capWideScale(get43size(10),10);visible,true;halign,0;zoom,capWideScale(get43size(0.45),0.45);maxwidth,capWideScale(get43size(340),340)/capWideScale(get43size(0.45),0.45));
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

t[#t+1] = LoadFont("Common Normal") .. {
	Name="songLength";
	InitCommand=cmd(xy,5+(capWideScale(get43size(384),384)),60+capWideScale(get43size(120),120)-capWideScale(get43size(10),10);visible,true;halign,1;zoom,capWideScale(get43size(0.45),0.45);maxwidth,capWideScale(get43size(360),360)/capWideScale(get43size(0.45),0.45));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		local seconds = 0
		if song ~= nil then
			seconds = song:GetStepsSeconds() --song:MusicLengthSeconds()
			self:settext(SecondsToMMSS(seconds))
			self:diffuse(getSongLengthColor(seconds))
		else
			self:settext("")
		end
	end;
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
};


return t