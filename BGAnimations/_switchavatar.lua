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

local function getInitAvatarIndex(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()
	local avatar = themeConfig:get_data().avatar[GUID]
	for i=1,#avatars do
		if avatar == avatars[i] then
			return i
		end;
	end;

	return 1
end;

local data ={
	PlayerNumber_P1 = {
		cursorIndex = 1,
		avatarIndex = getInitAvatarIndex(PLAYER_1),
	},
	PlayerNumber_P2 = {
		cursorIndex = 1,
		avatarIndex = getInitAvatarIndex(PLAYER_2),
	},
}

local t = Def.ActorFrame{
	Name="AvatarSwitch";
}

local function shift(self,amount)
	self:finishtweening()
	self:smooth(0.1)
	self:addx((itemWidth+border)*amount)
end;

local function getCurrentAvatar(pn)
	return avatars[data[pn]["avatarIndex"]]
end;

local function saveAvatar(pn)
	local avatar = getCurrentAvatar(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()
	themeConfig:get_data().avatar[GUID] = avatar
	themeConfig:set_dirty()
	themeConfig:save()
	SCREENMAN:SystemMessage(string.format("%s Avatar set to: '%s'",pn,avatar))
end;

local function avatarSwitch(pn)
	local t = Def.ActorFrame{
		Name="AvatarSwitch"..pn;
		BeginCommand=function(self)
			if pn == PLAYER_1 then
				self:x(-width);
				self:smooth(0.2)
				self:x(0)
			end;
			if pn == PLAYER_2 then
				self:x(SCREEN_WIDTH)
				self:smooth(0.2)
				self:x(SCREEN_WIDTH-width)
			end;
		end;
		CodeMessageCommand=function(self,params)
			if params.Name == "AvatarCancel" or params.Name == "AvatarExit" then
				if pn == PLAYER_1 then
					self:smooth(0.2)
					self:x(-width)
				end
				if pn == PLAYER_2 then
					self:smooth(0.2)
					self:x(SCREEN_WIDTH)
				end
			end;
		end;
	}

	t[#t+1] = Def.ActorFrame{
	CodeMessageCommand=function(self,params)
		local table = SCREENMAN:GetTopScreen():GetChildren().Overlay:GetChildren().AvatarSwitch:GetChildren()["AvatarSwitch"..pn]:GetChildren().AvatarTable
		local cursor = SCREENMAN:GetTopScreen():GetChildren().Overlay:GetChildren().AvatarSwitch:GetChildren()["AvatarSwitch"..pn]:GetChildren().AvatarCursor
		if params.PlayerNumber == pn then
			if params.Name == "AvatarLeft" then
				if data[pn]["avatarIndex"] > 1 and data[pn]["cursorIndex"] > 1 then
					shift(cursor,-1)
					data[pn]["avatarIndex"] = data[pn]["avatarIndex"] - 1
					data[pn]["cursorIndex"] = data[pn]["cursorIndex"] - 1 
				elseif data[pn]["avatarIndex"] > 1 and data[pn]["cursorIndex"] == 1 then
					shift(table,1)
					data[pn]["avatarIndex"] = data[pn]["avatarIndex"] - 1
				end;
			end;
			if params.Name == "AvatarRight" then
				if data[pn]["avatarIndex"] < #avatars and data[pn]["cursorIndex"] < maxItems then
					shift(cursor,1)
					data[pn]["avatarIndex"] = data[pn]["avatarIndex"] + 1
					data[pn]["cursorIndex"] = data[pn]["cursorIndex"] + 1 
				elseif data[pn]["avatarIndex"] < #avatars and data[pn]["cursorIndex"] == maxItems then
					shift(table,-1)
					data[pn]["avatarIndex"] = data[pn]["avatarIndex"] + 1
				end;
			end;
		end;
		if params.Name == "AvatarCancel" then
			SCREENMAN:GetTopScreen():Cancel()
		end;
		if params.Name == "AvatarExit" then
			if GAMESTATE:GetNumPlayersEnabled() == 1 then
				saveAvatar(params.PlayerNumber)
				setAvatarUpdateStatus(pn,true)
			else
				saveAvatar(PLAYER_1)
				setAvatarUpdateStatus(PLAYER_1,true)
				saveAvatar(PLAYER_2)
				setAvatarUpdateStatus(PLAYER_2,true)
			end;
			SCREENMAN:GetTopScreen():Cancel()
		end;
	end;
	}

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY;zoomto,width,height;halign,0;valign,1;diffuse,color("#00000066"));
	}

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,width,0;zoomto,SCREEN_WIDTH-width,SCREEN_HEIGHT;halign,0;valign,0;zwrite,true;clearzbuffer,true;blend,'BlendMode_NoEffect';);
		BeginCommand=function(self)
			if pn == PLAYER_2 then
				self:x(0)
				self:halign(1)
			end;
		end;
	}

	t[#t+1] = Def.Quad{
		Name="AvatarCursor";
		InitCommand=cmd(xy,frameX-2+border,frameY+2-border;zoomto,itemHeight+4,itemWidth+4;halign,0;valign,1;diffuse,color("#FFFFFF"));
	}

	local avatarTable = Def.ActorFrame{
		Name="AvatarTable";
		BeginCommand=function(self)
			shift(self,-(data[pn]["avatarIndex"]-1))
		end;
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
		InitCommand=cmd(xy,frameX,frameY-height;halign,0;valign,1;zoom,0.35;);
		SetCommand=function(self,params)
			--self:settextf("Player 1 avatar: ci%d ai%d",cursorIndex,avatarIndex)
			if pn == PLAYER_1 then
				self:settextf("Player 1 avatar: %s",avatars[data[pn]["avatarIndex"]])
			end;
			if pn == PLAYER_2 then
				self:settextf("Player 2 avatar: %s",avatars[data[pn]["avatarIndex"]])
			end;
		end;
		CodeMessageCommand=cmd(queuecommand,"Set")
	};
	return t
end;

if GAMESTATE:IsHumanPlayer(PLAYER_1) then
	t[#t+1] = avatarSwitch(PLAYER_1)
end;
if GAMESTATE:IsHumanPlayer(PLAYER_2) then
	t[#t+1] = avatarSwitch(PLAYER_2)
end;

return t