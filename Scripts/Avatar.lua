--shamelessly copied from customspeedmod
local function ReadAvatarFile(path)
	local file = RageFileUtil.CreateRageFile()
	if not file:Open(path, 1) then
		file:destroy()
		return nil
	end

	local contents = file:Read()
	file:Close()
	file:destroy()

	return contents
end

-- Returns a path to the avatar image (relative to the theme folder) for the specified player.
function getAvatarPath(pn)
	if pn == nil then
		return "Graphics/Player avatar/generic.gif"
	end
	local profile
	local profilePath = ""
	local fileName = "generic.gif"
	if GAMESTATE:IsPlayerEnabled(pn) then
		profile = GetPlayerOrMachineProfile(pn)
		if pn == PLAYER_1 then
			profilePath = PROFILEMAN:GetProfileDir('ProfileSlot_Player1')
			fileName = ReadAvatarFile(profilePath.."/avatar.txt")
		elseif pn == PLAYER_2 then
			profilePath = PROFILEMAN:GetProfileDir('ProfileSlot_Player2')
			fileName = ReadAvatarFile(profilePath.."/avatar.txt")
		else
			fileName = nil
		end;	
		if fileName == nil then
			fileName = "generic.gif"
		end
	end

	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		return "Graphics/Player avatar/"..fileName
	else
		return "Graphics/Player avatar/generic.gif"
	end;
end;

function getAvatarPathFromProfileID(id)
	if id == nil then
		return "Graphics/Player avatar/generic.gif"
	end
	local profilePath = ""
	local fileName = "generic.gif"

	profilePath = PROFILEMAN:LocalProfileIDToDir(id)
	fileName = ReadAvatarFile(profilePath.."/avatar.txt")

	if fileName == nil then
		fileName = "generic.gif"
	end

	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		return "Graphics/Player avatar/"..fileName
	else
		return "Graphics/Player avatar/generic.gif"
	end;
end;

-- Creates an actor with the avatar image.
function getAvatar(pn)
	local profile
	local profilePath = ""
	local fileName = "generic.gif"
	if GAMESTATE:IsPlayerEnabled(pn) then
		profile = GetPlayerOrMachineProfile(pn)
		profilePath = PROFILEMAN:GetProfileDir('ProfileSlot_Player1')
		fileName = ReadAvatarFile(profilePath.."/avatar.txt")
		if fileName == nil then
			fileName = "generic.gif"
		end
	end

	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		t = LoadActor("../Graphics/Player avatar/"..fileName)..{
			Name="Avatar";
			InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,0;);
		};
	else
		t = LoadActor("../Graphics/Player avatar/generic")..{
			Name="Avatar";
			InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,0;);
		};
	end

	return t
end;
