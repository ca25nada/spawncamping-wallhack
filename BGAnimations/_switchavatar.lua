

--Parameters.
local imgTypes = {".jpg",".png",".gif",".jpeg"}
local rawList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/")
local avatars = filterFileList(rawList,imgTypes)

local maxItems = 5
local itemHeight = 25
local itemWidth = 25
local border = 5
local width = maxItems*(itemWidth+border)+border

local frameX = SCREEN_CENTER_X/2 + capWideScale(get43size(390),390)/2 - width
local frameY = SCREEN_HEIGHT-106
local height = itemHeight+(border*2)


--search for avatar currently being used. if none are found, revert to _fallback.png which is assumed to be on index 1.
local function getInitAvatarIndex(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()
	local avatar = avatarConfig:get_data().avatar[GUID]
	for i=1,#avatars do
		if avatar == avatars[i] then
			return i
		end;
	end;

	return 1
end

--place cursor on center unless it's on the edge.
local function getInitCursorIndex(pn)
	local avatarIndex = getInitAvatarIndex(pn)

	if avatarIndex < math.ceil(maxItems/2) then
		return avatarIndex
	elseif avatarIndex > #avatars-math.ceil(maxItems/2) then
		return maxItems-(#avatars-avatarIndex)
	end
	return math.ceil(maxItems/2)
end

local data ={
	PlayerNumber_P1 = {
		cursorIndex = getInitCursorIndex(PLAYER_1),
		avatarIndex = getInitAvatarIndex(PLAYER_1),
	},
	PlayerNumber_P2 = {
		cursorIndex = getInitCursorIndex(PLAYER_2),
		avatarIndex = getInitAvatarIndex(PLAYER_2),
	},
}

local t = Def.ActorFrame{
	Name="AvatarSwitch";
}

--Shifts an actor by "1 index"
local function shift(actor,amount)
	actor:finishtweening()
	actor:smooth(0.1)
	actor:addx((itemWidth+border)*amount)
end

--Grabs the currently selected avatar.
local function getSelectedAvatar(pn)
	return avatars[data[pn]["avatarIndex"]]
end

--Save preferences and sends a systemmessage at the end.
local function saveAvatar(pn)
	local avatar = getSelectedAvatar(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()
	avatarConfig:get_data().avatar[GUID] = avatar
	avatarConfig:set_dirty()
	avatarConfig:save()
	SCREENMAN:SystemMessage(string.format("%s's Avatar set to: '%s'",PROFILEMAN:GetPlayerName(pn),avatar))
end

-- The main function that contains errything
local function avatarSwitch(pn)
	local t = Def.ActorFrame{
		Name="AvatarSwitch"..pn;
		BeginCommand=function(self)
			if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
				self:addx(SCREEN_WIDTH/2)
			end
			if getTabIndex() ~= 1 then
				self:y(49)
			end
			self:diffusealpha(0)
			self:decelerate(0.5)
			self:diffusealpha(1)
		end;
		CodeMessageCommand=function(self,params)
			if params.Name == "AvatarCancel" or params.Name == "AvatarExit" then
				self:smooth(0.2)
				self:y(SCREEN_HEIGHT)
			end;
		end;
	}

	t[#t+1] = Def.ActorFrame{
	CodeMessageCommand=function(self,params)
		--grab table/cursor and shift them by 1 to left/right everytime someone presses code for avatarleft/right
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
		--rq out of the screen if just canceling.
		if params.Name == "AvatarCancel" then
			SCREENMAN:GetTopScreen():Cancel()
		end;
		--save and exit if exiting. forcefully save both players when 2p as only the changes for the person who pressed exit will be applied.
		if params.Name == "AvatarExit" then
			for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
				saveAvatar(pn)
			end
			MESSAGEMAN:Broadcast("AvatarChanged")
			SCREENMAN:GetTopScreen():Cancel()
		end;
	end;
	}

	--Background Quad

	--MASKING SCKS
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY;zoomto,width,height;halign,0;valign,1;zwrite,true;clearzbuffer,false;blend,'BlendMode_NoEffect';);
	}


	--Cursor
	t[#t+1] = Def.Quad{
		Name="AvatarCursor";
		InitCommand=cmd(xy,frameX-2+border,frameY+2-border;zoomto,itemHeight+4,itemWidth+4;halign,0;valign,1;diffuse,color("#FFFFFF"));
		BeginCommand=function(self)
			shift(self,(data[pn]["cursorIndex"]-1))
		end;
	}

	--List of avatars
	local avatarTable = Def.ActorFrame{
		Name="AvatarTable";
		BeginCommand=function(self)
			shift(self,-(data[pn]["avatarIndex"]-1))
			shift(self,(data[pn]["cursorIndex"]-1))
		end;
	}
	t[#t+1] = avatarTable
	for k,v in pairs(avatars) do
		avatarTable[#avatarTable+1] = Def.Sprite {
			InitCommand=cmd(visible,true;halign,0;valign,1;xy,frameX+border+((border+itemWidth)*(k-1)),frameY-border;ztest,true;ztestmode,'ZTestMode_WriteOnFail');
			BeginCommand=cmd(queuecommand,"ModifyAvatar");
			ModifyAvatarCommand=function(self)
				self:finishtweening();
				self:LoadBackground(THEME:GetPathG("","Player avatar/"..v));
				self:zoomto(itemWidth,itemHeight)
			end;
		};
	end;

	--Text
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,frameX+width,frameY-height;halign,1;valign,1;zoom,0.35;diffuse,color("#111111"));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self,params)
			self:settext(avatars[data[pn]["avatarIndex"]])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
	return t
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = avatarSwitch(pn)
end

return t