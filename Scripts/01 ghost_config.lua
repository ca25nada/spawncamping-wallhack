local defaultConfig = {
}

ghostTable= create_lua_config({name = "ghostTable", file = "ghostData.lua", default = defaultConfig, match_depth = 0})
add_standard_lua_config_save_load_hooks(ghostTable)
--ghostTable:load()
