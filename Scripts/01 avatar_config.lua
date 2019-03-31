local defaultConfig = {
	avatar = {
		default = "_fallback.png",
	},
}


avatarConfig = create_setting("avatarConfig", "avatarConfig.lua", defaultConfig, 0)
avatarConfig:load()


function findAvatar(ID)
	if avatarConfig:get_data().avatar[ID] ~= nil then
		return avatarConfig:get_data().avatar[ID]
	else
		return defaultConfig.avatar.default
	end
end