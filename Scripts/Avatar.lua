
--use global prefs instead of playerprefs as the playerprefs can't be grabbed when the profileslots aren't loaded.

-- Add a new profile to avatar config.
local function addProfileFromGUID(GUID)
	if not tableContains(avatarConfig:get_data().avatar,GUID) then
		avatarConfig:get_data().avatar[GUID] = avatarConfig:get_data().avatar.default
		avatarConfig:set_dirty()
		avatarConfig:save()
	end;
end;

-- returns the image path relative to the theme folder for the specified player.
function getAvatarPath(pn)
	
	local fileName = avatarConfig:get_data().avatar.default

	local profile = PROFILEMAN:GetProfile(pn)
	local GUID = profile:GetGUID()

	fileName = avatarConfig:get_data().avatar[GUID]
	if fileName == nil then
		-- make the new config for the profile and return the default image.
		fileName = avatarConfig:get_data().avatar.default
		addProfileFromGUID(GUID)
	end;


	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		return "Graphics/Player avatar/"..fileName
	else
		return "Graphics/Player avatar/_fallback.png"
	end;
end;

-- returns the image path relative to the theme folder from the profileID.
-- getAvatarPath should be used in the general case. this is really only needed for the profile select screen
-- where the profile isn't loaded into a player slot yet.
function getAvatarPathFromProfileID(id)
	local fileName = avatarConfig:get_data().avatar.default
	if id == nil then
		return fileName
	end

	local profile = PROFILEMAN:GetLocalProfile(id)
	local GUID = profile:GetGUID()

	fileName = avatarConfig:get_data().avatar[GUID]
	if fileName == nil then
		fileName = avatarConfig:get_data().avatar.default
		addProfileFromGUID(GUID)
	end;

	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		return "Graphics/Player avatar/"..fileName
	else
		return "Graphics/Player avatar/_fallback.png"
	end;
end;
