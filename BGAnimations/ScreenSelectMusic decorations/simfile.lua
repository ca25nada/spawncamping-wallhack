local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set";visible,false);
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;);
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
	CodeMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
};

local frameX = 10
local frameY = 45
local frameWidth = 400
local frameHeight = 350
local fontScale = 0.4
local distY = 15
local offsetX1 = 100
local offsetX2 = 10
local offsetY = 20

local stringList = {"Title","SubTitle","Artist","Group"}

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
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;halign,0;valign,0;diffuse,color("#333333"));
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

	for i=1,#stringList do 
		t[#t+1] = makeText(i)
	end;

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(1*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
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
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(2*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
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
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(3*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
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
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(4*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
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