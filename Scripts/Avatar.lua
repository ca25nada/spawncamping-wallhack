
--use global prefs instead of playerprefs as the playerprefs can't be grabbed when the profileslots aren't loaded.
-- Add a new profile to avatar config.
local function addProfileFromGUID(GUID)
	if not tableContains(avatarConfig:get_data().avatar,GUID) then
		avatarConfig:get_data().avatar[GUID] = avatarConfig:get_data().avatar.default
		avatarConfig:set_dirty()
		avatarConfig:save()
	end;
end;

function ProfileManager.GetAvatarFolderPath()
	return "Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"
end

-- returns the image path relative to the theme folder for the specified player.
function ProfileManager.GetAvatarName(self, pn)
	
	local fileName = avatarConfig:get_data().avatar.default

	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()

	fileName = avatarConfig:get_data().avatar[GUID]
	if fileName == nil then
		-- make the new config for the profile and return the default image.
		fileName = avatarConfig:get_data().avatar.default
		addProfileFromGUID(GUID)
	end;


	if FILEMAN:DoesFileExist(self:GetAvatarFolderPath()..fileName) then
		return fileName
	else
		return "_fallback.png"
	end;
end;

function ProfileManager.GetAvatarPath(self, pn)
	return string.format("%s%s",self:GetAvatarFolderPath(),self:GetAvatarName(pn))
end;

function ProfileManager.GetAllAvatarNames()
	local imgTypes = {".jpg",".png",".gif",".jpeg"}
	local rawList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/")
	local avatars = filterFileList(rawList,imgTypes)

	return avatars
end

function ProfileManager.GetAllAvatarPaths()
	local imgTypes = {".jpg",".png",".gif",".jpeg"}
	local rawList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/", false, true)
	local avatars = filterFileList(rawList,imgTypes)

	return avatars
end

-- returns the image path relative to the theme folder from the profileID.
-- getAvatarPath should be used in the general case. this is really only needed for the profile select screen
-- where the profile isn't loaded into a player slot yet.
function ProfileManager.GetAvatarNameFromProfileID(self, id)
	local default = avatarConfig:get_data().avatar.default
	if id == nil then
		return default
	end

	local profile = PROFILEMAN:GetLocalProfile(id)
	local GUID = profile:GetGUID()

	local fileName = avatarConfig:get_data().avatar[GUID]

	if fileName == nil then
		return default
	else
		return fileName
	end
end

function ProfileManager.GetAvatarPathFromProfileID(self, id)
	return string.format("%s%s",self:GetAvatarFolderPath(),self:GetAvatarNameFromProfileID(id))
end

function ProfileManager.SaveAvatar(self, pn, name)
	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()
	avatarConfig:get_data().avatar[GUID] = name
	avatarConfig:set_dirty()
	avatarConfig:save()
	MESSAGEMAN:Broadcast("AvatarChanged", {pn = pn, name = name})
	SCREENMAN:SystemMessage(string.format("%s's Avatar set to: '%s'", PROFILEMAN:GetPlayerName(pn), name))
end