local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set";visible,false);
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;diffusealpha,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;diffusealpha,1;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 4 then
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

local frameX = 18
local frameY = 30
local frameWidth = capWideScale(get43size(390),390)
local frameHeight = 320
local fontScale = 0.4
local distY = 15
local offsetX1 = 100
local offsetX2 = 10
local offsetY = 20

local stringList1 = {
	[1] = "Soon"
}

local stringList2 = {
	[1] = "(tm)"
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY+offsetY;zoomto,frameWidth,frameHeight-offsetY;halign,0;valign,0;diffuse,color("#000000");diffusealpha,0.6);
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,offsetY;halign,0;valign,0;diffuse,color("#000000");diffusealpha,0.8);
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,frameX+5,frameY+offsetY-9;zoom,0.4;halign,0;diffuse,getMainColor('highlight'));
	BeginCommand=cmd(settext,THEME:GetString("ScreenSelectMusic","ProfileInfoHeader"))
};

local function makeText1(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,offsetX1/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList1[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

local function makeText2(index)
	return LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+offsetX1+offsetX2*2,frameY+offsetY+(index*distY);zoom,fontScale;halign,0;maxwidth,(frameWidth-offsetX1)/fontScale);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList2[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
end;

t[#t+1] = makeText1(1)
t[#t+1] = makeText2(1)

return t