local settings_prefix= "/" .. THEME:GetThemeDisplayName() .. "_settings/"
global_cur_game= GAMESTATE:GetCurrentGame():GetName():lower()

function force_table_elements_to_match_type(candidate, must_match, depth_remaining)
	for k, v in pairs(candidate) do
		if type(must_match[k]) ~= type(v) then
			candidate[k]= nil
		elseif type(v) == "table" and depth_remaining ~= 0 then
			force_table_elements_to_match_type(v, must_match[k], depth_remaining-1)
		end
	end
	for k, v in pairs(must_match) do
		if type(candidate[k]) == "nil" then
			if type(v) == "table" then
				candidate[k]= DeepCopy(v)
			else
				candidate[k]= v
			end
		end
	end
end

local function slot_to_prof_dir(slot, reason)
	local prof_dir= "Save"
	if slot and slot ~= "ProfileSlot_Invalid" then
		prof_dir= PROFILEMAN:GetProfileDir(slot)
		if not prof_dir or prof_dir == "" then
			--Warn("Could not fetch profile dir to " .. reason .. ".")
			return
		end
	end
	return prof_dir
end

local function load_conf_file(fname)
	local file= RageFileUtil.CreateRageFile()
	local ret= {}
	if file:Open(fname, 1) then
		local data= loadstring(file:Read())
		setfenv(data, {})
		local success, data_ret= pcall(data)
		if success then
			ret= data_ret
		end
		file:Close()
	end
	file:destroy()
	return ret
end

local setting_mt= {
	__index= {
		init= function(self, name, file, default, match_depth)
			assert(type(default) == "table", "default for setting must be a table.")
			self.name= name
			self.file= file
			self.default= default
			self.match_depth= match_depth
			self.dirty_table= {}
			self.data_set= {}
			return self
		end,
		load= function(self, slot)
			slot= slot or "ProfileSlot_Invalid"
			local prof_dir= slot_to_prof_dir(slot, "read " .. self.name)
			if not prof_dir then
				self.data_set[slot]= DeepCopy(self.default)
			else
				local fname= prof_dir .. settings_prefix .. self.file
				if not FILEMAN:DoesFileExist(fname) then
					self.data_set[slot]= DeepCopy(self.default)
				else
					local from_file= load_conf_file(fname)
					if type(from_file) == "table" then
						if self.match_depth and self.match_depth ~= 0 then
							force_table_elements_to_match_type(
								from_file, self.default, self.match_depth-1)
						end
						self.data_set[slot]= from_file
					else
						self.data_set[slot]= DeepCopy(self.default)
					end
				end
			end
			return self.data_set[slot]
		end,
		get_data= function(self, slot)
			slot= slot or "ProfileSlot_Invalid"
			return self.data_set[slot] or self.default
		end,
		set_data= function(self, slot, data)
			slot= slot or "ProfileSlot_Invalid"
			self.data_set[slot]= data
		end,
		set_dirty= function(self, slot)
			slot= slot or "ProfileSlot_Invalid"
			self.dirty_table[slot]= true
		end,
		check_dirty= function(self, slot)
			slot= slot or "ProfileSlot_Invalid"
			return self.dirty_table[slot]
		end,
		clear_slot= function(self, slot)
			slot= slot or "ProfileSlot_Invalid"
			self.dirty_table[slot]= nil
			self.data_set[slot]= nil
		end,
		save= function(self, slot)
			slot= slot or "ProfileSlot_Invalid"
			if not self:check_dirty(slot) then return end
			local prof_dir= slot_to_prof_dir(slot, "write " .. self.name)
			if not prof_dir then return end
			local fname= prof_dir .. settings_prefix .. self.file
			local file_handle= RageFileUtil.CreateRageFile()
			if not file_handle:Open(fname, 2) then
				Warn("Could not open '" .. fname .. "' to write " .. self.name .. ".")
			else
				local output= "return " .. lua_table_to_string(self.data_set[slot])
				file_handle:Write(output)
				file_handle:Close()
				file_handle:destroy()
			end
		end,
		save_all= function(self)
			for slot, data in pairs(self.data_set) do
				self:save(slot)
			end
		end
}}

function create_setting(name, file, default, match_depth)
	return setmetatable({}, setting_mt):init(name, file, default, match_depth)
end

function write_str_to_file(str, fname, str_name)
	local file_handle= RageFileUtil.CreateRageFile()
	if not file_handle:Open(fname, 2) then
		Warn("Could not open '" .. fname .. "' to write " .. str_name .. ".")
	else
		file_handle:Write(str)
		file_handle:Close()
		file_handle:destroy()
	end
end
