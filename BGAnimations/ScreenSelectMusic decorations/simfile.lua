local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set";visible,false);
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;diffusealpha,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;diffusealpha,1;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:queuecommand("On");
			self:visible(true)
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	TabChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
};

local frameX = 10
local frameY = 45
local frameWidth = capWideScale(320,400)
local frameHeight = 350
local fontScale = 0.4
local distY = 15
local offsetX1 = 100
local offsetX2 = 10
local offsetY = 20

local stringList = {"Title:","SubTitle:","Artist:","Group:","Song Length:","BPM:","Play Count:","Simfile SHA-1","Simfile MD5"}

local function makeText(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,offsetX1/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;halign,0;valign,0;diffuse,color("#333333CC"));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,offsetY;halign,0;valign,0;diffuse,color("#FFFFFF"));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+5,frameY+offsetY-9;zoom,0.6;halign,0;diffuse,getMainColor(1));
	BeginCommand=cmd(settext,"Simfile Info")
};


if GAMESTATE:GetNumPlayersEnabled() == 1 then
	local pn = GAMESTATE:GetEnabledPlayers()[1]
	local profile = GetPlayerOrMachineProfile(pn)


	t[#t+1] = Def.Sprite {
		InitCommand=cmd(xy,frameX+frameWidth-50-offsetX2,frameY+offsetY+40;diffusealpha,0.6;zoomy,0;sleep,0.5;decelerate,0.25;zoomy,1);
		Name="CDTitle";
		SetCommand=function(self)
			local song = GAMESTATE:GetCurrentSong();
			
			--cdtitle
			
			if song then
				if song:HasCDTitle() then
					self:visible(true);
					self:Load(song:GetCDTitlePath());
				else
					self:visible(false);
				end;
			else
				self:visible(false);
			end;

			local height = self:GetHeight();
			local width = self:GetWidth();
			
			if height >= 80 and width >= 100 then
				if height*(100/80) >= width then
				self:zoom(80/height);
				else
				self:zoom(100/width);
				end;
			elseif height >= 80 then
				self:zoom(80/height);
			elseif width >= 100 then
				self:zoom(100/width);
			else 
				self:zoom(1);
			end;
		end;
		BeginCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	for i=1,#stringList do 
		t[#t+1] = makeText(i)
	end;

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(1*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1-offsetX2*2)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					self:diffuse(color("#FFFFFF"))
					self:settext(song:GetDisplayMainTitle())
				else
					self:settext("Not Available")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(2*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1-offsetX2*2)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local song = GAMESTATE:GetCurrentSong()
				self:diffuse(color("#FFFFFF"))
				if song ~= nil then
					local text = song:GetDisplaySubTitle()
					if text == "" then
						text = "Not Available"
						self:diffuse(color("#666666"))
					end;
					self:settext(text)
				else
					self:settext("Not Available")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(3*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1-offsetX2*2)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					self:diffuse(color("#FFFFFF"))
					self:settext(song:GetDisplayArtist())
				else
					self:settext("Not Available")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(4*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1-offsetX2*2)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					self:diffuse(color("#FFFFFF"))
					self:settext(song:GetGroupName())
				else
					self:settext("Not Available")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(5*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1-offsetX2*2)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					local length =  song:GetStepsSeconds()
					self:settext(SecondsToMMSS(length))
					self:diffuse(getSongLengthColor(length))
				else
					self:settext("0:00")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(6*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1-offsetX2*2)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					self:diffuse(color("#FFFFFF"))
					if song:HasSignificantBPMChangesOrStops() then
						self:settextf("%04.2f~%04.2f",song:GetTimingData():GetActualBPM()[1],song:GetTimingData():GetActualBPM()[2])
					else
						self:settextf("%04.2f",song:GetTimingData():GetActualBPM()[1])
					end
				else
					self:settext("0.00")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(7*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local profile = GetPlayerOrMachineProfile(GAMESTATE:GetEnabledPlayers()[1])
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					self:diffuse(color("#FFFFFF"))
					self:settext(profile:GetSongNumTimesPlayed(song))
				else
					self:settext("0")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(8*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local pn = GAMESTATE:GetEnabledPlayers()[1]
				local song = GAMESTATE:GetCurrentSong()
				if song ~= nil then
					local path = song:GetSongDir()
					local files = FILEMAN:GetDirListing(path)
					self:diffuse(color("#FFFFFF"))
					for k,v in pairs(files) do
						if string.sub(v,-3,-1) == ".sm" then
							self:settext(SHA1FileHex(path.."/"..v))
						end;
					end;
					--local SHA1 = CRYPTMAN:SHA1String("uwaa") -- should be bdf6925c3cdfe16148ae952ba19a36604b9e40b6
					
				else
					self:settext("0")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(9*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local pn = GAMESTATE:GetEnabledPlayers()[1]
				local step = GAMESTATE:GetCurrentSteps(pn)
				if song ~= nil then
					self:diffuse(color("#FFFFFF"))
					self:settext(MD5FileHex(step:GetFilename()))
				else
					self:settext("0")
					self:diffuse(color("#666666"))
				end
			end
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(11*distY);zoom,fontScale;halign,0;)	;
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext("More to be added later o/~")
		end;
	};

else
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(1*distY);zoom,fontScale;halign,0;)	;
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext("Currently not available for multiplayer")
		end;
	};
end;


return t