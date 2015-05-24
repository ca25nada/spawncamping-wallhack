local show = true
local avatars = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/")
local maxItems = 5--math.min(7,#avatars)
local itemHeight = 30
local itemWidth = 30
local border = 5
local frameX = 0
local frameY = SCREEN_HEIGHT-55
local height = itemHeight+(border*2)
local width = maxItems*(itemWidth+border)+border

local cursorIndex = 1
local avatarIndex = 1

local t = Def.ActorFrame{
	Name="AvatarSwitch";
	BeginCommand=cmd(x,-width;smooth,0.2;x,0);
	CodeMessageCommand=function(self,params)
		if params.Name == "AvatarCancel" or params.Name == "AvatarExit" then
			self:smooth(0.2)
			self:x(-width)
		end;
	end;
}

local function shift(self,amount)
	self:finishtweening()
	self:smooth(0.1)
	self:addx((itemWidth+border)*amount)
end;

local function getCurrentAvatar()
	return avatars[avatarIndex]
end;

local function saveAvatar(pn)
	local avatar = getCurrentAvatar()
	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()
	themeConfig:get_data().avatar[GUID] = avatar
	themeConfig:set_dirty()
	themeConfig:save()
end;

t[#t+1] = Def.ActorFrame{
	CodeMessageCommand=function(self,params)
		local table = SCREENMAN:GetTopScreen():GetChildren().Overlay:GetChildren().AvatarSwitch:GetChildren().AvatarTable
		local cursor = SCREENMAN:GetTopScreen():GetChildren().Overlay:GetChildren().AvatarSwitch:GetChildren().AvatarCursor
		if params.Name == "AvatarLeft" then
			if avatarIndex > 1 and cursorIndex > 1 then
				shift(cursor,-1)
				avatarIndex = avatarIndex - 1
				cursorIndex = cursorIndex - 1 
			elseif avatarIndex > 1 and cursorIndex == 1 then
				shift(table,1)
				avatarIndex = avatarIndex - 1
			end;
		end;
		if params.Name == "AvatarRight" then
			if avatarIndex < #avatars and cursorIndex < maxItems then
				shift(cursor,1)
				avatarIndex = avatarIndex + 1
				cursorIndex = cursorIndex + 1 
			elseif avatarIndex < #avatars and cursorIndex == maxItems then
				shift(table,-1)
				avatarIndex = avatarIndex + 1
			end;
		end;
		if params.Name == "AvatarCancel" then
			SCREENMAN:GetTopScreen():Cancel()
		end;
		if params.Name == "AvatarExit" then
			saveAvatar(params.PlayerNumber)
			SCREENMAN:GetTopScreen():Cancel()
		end;
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,frameX,frameY;zoomto,width,height;halign,0;valign,1;diffuse,color("#00000066"));
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,width,0;zoomto,SCREEN_WIDTH-width,SCREEN_HEIGHT;halign,0;valign,0;diffuse,color("#00000066"));
	BeginCommand=cmd(zwrite,true;clearzbuffer,true;blend,'BlendMode_NoEffect';);
}

t[#t+1] = Def.Quad{
	Name="AvatarCursor";
	InitCommand=cmd(xy,frameX-2+border,frameY+2-border;zoomto,itemHeight+4,itemWidth+4;halign,0;valign,1;diffuse,color("#FFFFFF"));
}

local avatarTable = Def.ActorFrame{
	Name="AvatarTable";
}
t[#t+1] = avatarTable
for k,v in pairs(avatars) do
	avatarTable[#avatarTable+1] = Def.Sprite {
		InitCommand=cmd(visible,true;halign,0;valign,1;xy,frameX+border+((border+itemWidth)*(k-1)),frameY-border;ztest,true;);
		BeginCommand=cmd(queuecommand,"ModifyAvatar");
		ModifyAvatarCommand=function(self)
			self:finishtweening();
			self:LoadBackground(THEME:GetPathG("","Player avatar/"..v));
			self:zoomto(itemWidth,itemHeight)
		end;
	};
end;

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,frameX,frameY-height;halign,0;valign,1;zoom,0.35;settext,"Player 1 avatar:");
	CodeMessageCommand=function(self,params)
		--self:settextf("Player 1 avatar: ci%d ai%d",cursorIndex,avatarIndex)
		self:settextf("Player 1 avatar: %s",avatars[avatarIndex])
	end;
};

return t