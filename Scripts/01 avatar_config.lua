local defaultConfig = {
	avatar = {
		default = "_fallback.png",
	},
}

avatarConfig = create_lua_config({name = "avatarConfig", file = "avatarConfig.lua", default = defaultConfig, match_depth = 0})
avatarConfig:load()