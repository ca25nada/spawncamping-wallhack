-- StepMania 5 Default Theme Preferences Handler
local function OptionNameString(str)
	return THEME:GetString('OptionNames',str)
end


--[[ option rows ]]

-- screen filter
function OptionRowScreenFilter()
	return {
		Name="ScreenFilter",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = { THEME:GetString('OptionNames','Off'), '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0', },
		LoadSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			local filterValue = getenv("ScreenFilter"..pName)
			if filterValue ~= nil then
				local val = scale(tonumber(filterValue),0,1,1,#list )
				list[val] = true
			else
				setenv("ScreenFilter"..pName,0)
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			local found = false
			for i=1,#list do
				if not found then
					if list[i] == true then
						local val = scale(i,1,#list,0,1)
						setenv("ScreenFilter"..pName,val)
						found = true
					end
				end
			end
		end,
	}
end

function JudgeType()
	local t = {
		Name = "JudgeType";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = { THEME:GetString('OptionNames','Off'),'No Highlights','On'};
		LoadSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			if ReadPrefFromFile("JudgeType"..pName) ~= nil then
				if GetUserPref("JudgeType"..pName) == "3" then
					list[3] = true;
				elseif GetUserPref("JudgeType"..pName) == "2" then
					list[2] = true;
				else
					list[1] = true;
				end;
			else
				WritePrefToFile("JudgeType"..pName,"1");
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local val;
			local pName = ToEnumShortString(pn)
			if list[3] then
				val = "3";
			elseif list[2] then
				val = "2";
			else
				val = "1";
			end;
			WritePrefToFile("JudgeType"..pName,val);
			MESSAGEMAN:Broadcast("PreferenceSet", { Message == "Set Preference" } );
			--THEME:ReloadMetrics();
		end;
	};
	setmetatable( t, t );
	return t;
end	


function AvgScoreType()
	local t = {
		Name = "AvgScoreType";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = {THEME:GetString('OptionNames','Off'),'DP','%Score','MIGS' };
		LoadSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			if ReadPrefFromFile("AvgScoreType"..pName) ~= nil then
				if GetUserPref("AvgScoreType"..pName) == "4" then
					list[4] = true;
				elseif GetUserPref("AvgScoreType"..pName) == "3" then
					list[3] = true;
				elseif GetUserPref("AvgScoreType"..pName) == "2" then
					list[2] = true;
				else
					list[1] = true;
				end;
			else
				WritePrefToFile("AvgScoreType"..pName,"1");
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local val;
			local pName = ToEnumShortString(pn)
			if list[4] then
				val = "4";
			elseif list[3] then
				val = "3";
			elseif list[2] then
				val = "2";
			else
				val = "1";
			end;
			WritePrefToFile("AvgScoreType"..pName,val);
			MESSAGEMAN:Broadcast("PreferenceSet", { Message == "Set Preference" } );
			--THEME:ReloadMetrics();
		end;
	};
	setmetatable( t, t );
	return t;
end;

function GhostScoreType()
	local t = {
		Name = "GhostScoreType";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = { THEME:GetString('OptionNames','Off'),'DP','%Score','MIGS' };
		LoadSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			if ReadPrefFromFile("GhostScoreType"..pName) ~= nil then
				if GetUserPref("GhostScoreType"..pName) == "4" then
					list[4] = true;
				elseif GetUserPref("GhostScoreType"..pName) == "3" then
					list[3] = true;
				elseif GetUserPref("GhostScoreType"..pName) == "2" then
					list[2] = true;
				else
					list[1] = true;
				end;
			else
				WritePrefToFile("GhostScoreType"..pName,"1");
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local val;
			local pName = ToEnumShortString(pn)
			if list[4] then
				val = "4";
			elseif list[3] then
				val = "3";
			elseif list[2] then
				val = "2";
			else
				val = "1";
			end;
			WritePrefToFile("GhostScoreType"..pName,val);
			MESSAGEMAN:Broadcast("PreferenceSet", { Message == "Set Preference" } );
			--THEME:ReloadMetrics();
		end;
	};
	setmetatable( t, t );
	return t;
end;


local tChoices = {};
for i=1,100  do
tChoices[i] = tostring(i)..'%';
end;
function GhostTarget()
	local t = {
		Name = "GhostTarget";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = tChoices;
		LoadSelections = function(self, list, pn)
			local prefs = playerConfig:get_data(pn_to_profile_slot(pn)).GhostTarget
			list[prefs] = true;
		end;
		SaveSelections = function(self, list, pn)
			local found = false
			for i=1,#list do
				if not found then
					if list[i] == true then
						local value = i;
						playerConfig:get_data(pn_to_profile_slot(pn)).GhostTarget = value
						found = true
					end
				end
			end
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end
	}
	setmetatable( t, t )
	return t
end

function ErrorBar()
	local t = {
		Name = "ErrorBar";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = { THEME:GetString('OptionNames','Off'),'On'};
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).ErrorBar
			if pref then
				list[2] = true;
			else
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			value = list[2]
			playerConfig:get_data(pn_to_profile_slot(pn)).ErrorBar = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end;
	};
	setmetatable( t, t );
	return t;
end	

function PaceMaker()
	local t = {
		Name = "PaceMaker";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = { THEME:GetString('OptionNames','Off'),'On'};
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).PaceMaker
			if pref then
				list[2] = true;
			else
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			value = list[2]
			playerConfig:get_data(pn_to_profile_slot(pn)).PaceMaker = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end;
	};
	setmetatable( t, t );
	return t;
end	


--===============================================
--Globals

function DefaultScoreType()
	local t = {
		Name = "DefaultScoreType";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "DP","PS","MIGS"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.DefaultScoreType
			if pref == 1 then
				list[1] = true
			elseif pref == 2 then
				list[2] = true
			else 
				list[3] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 1
			elseif list[2] == true then
				value = 2
			else
				value = 3
			end;
			themeConfig:get_data().global.DefaultScoreType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	

function TipType()
	local t = {
		Name = "TipType";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","Tips","Random Phrases"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.TipType
			if pref == 1 then
				list[1] = true
			elseif pref == 2 then
				list[2] = true
			else 
				list[3] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 1
			elseif list[2] == true then
				value = 2
			else
				value = 3
			end;
			themeConfig:get_data().global.TipType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	

function SongBGEnabled()
	local t = {
		Name = "SongBGEnabled";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SongBGEnabled
			if pref then
				list[2] = true
			else 
				list[1] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end;
			themeConfig:get_data().global.SongBGEnabled = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	

function SongBGMouseEnabled()
	local t = {
		Name = "SongBGMouseEnabled";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SongBGMouseEnabled
			if pref then
				list[2] = true
			else 
				list[1] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end;
			themeConfig:get_data().global.SongBGMouseEnabled = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	