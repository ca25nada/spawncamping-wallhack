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
			local filterValue = playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter
			local value = scale(filterValue,0,1,1,#list )
			list[value] = true
		end,
		SaveSelections = function(self, list, pn)
			local pName = ToEnumShortString(pn)
			local found = false
			local value = 0
			for i=1,#list do
				if not found then
					if list[i] == true then
						value = scale(i,1,#list,0,1)
						found = true
					end
				end
			end
			playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
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
			local prefs = playerConfig:get_data(pn_to_profile_slot(pn)).JudgeType
			list[prefs+1] = true
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[3] then
				value = 2;
			elseif list[2] then
				value = 1;
			else
				value = 0;
			end;
			playerConfig:get_data(pn_to_profile_slot(pn)).JudgeType = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
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
			local prefs = playerConfig:get_data(pn_to_profile_slot(pn)).AvgScoreType
			list[prefs+1] = true
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[4] then
				value = 3;
			elseif list[3] then
				value = 2;
			elseif list[2] then
				value = 1;
			else
				value = 0;
			end;
			playerConfig:get_data(pn_to_profile_slot(pn)).AvgScoreType = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
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
			local prefs = playerConfig:get_data(pn_to_profile_slot(pn)).GhostScoreType
			list[prefs+1] = true
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[4] then
				value = 3;
			elseif list[3] then
				value = 2;
			elseif list[2] then
				value = 1;
			else
				value = 0;
			end;
			playerConfig:get_data(pn_to_profile_slot(pn)).GhostScoreType = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
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

function LaneCover()
	local t = {
		Name = "LaneCover";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = { THEME:GetString('OptionNames','Off'),'Sudden','Hidden'};
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).LaneCover
			list[pref+1] = true;
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 0
			elseif list[2] == true then
				value = 1
			else
				value = 2
			end;
			playerConfig:get_data(pn_to_profile_slot(pn)).LaneCover = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end;
	};
	setmetatable( t, t );
	return t;
end	

function NPSDisplay()
	local t = {
		Name = "NPSDisplay";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectMultiple";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = {"NPS Display","NPS Graph"};
		LoadSelections = function(self, list, pn)
			local npsDisplay = playerConfig:get_data(pn_to_profile_slot(pn)).NPSDisplay
			local npsGraph = playerConfig:get_data(pn_to_profile_slot(pn)).NPSGraph
			if npsDisplay then
				list[1] = true
			end
			if npsGraph then 
				list[2] = true
			end
		end;
		SaveSelections = function(self, list, pn)
			playerConfig:get_data(pn_to_profile_slot(pn)).NPSDisplay = list[1]
			playerConfig:get_data(pn_to_profile_slot(pn)).NPSGraph = list[2]
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end;
	};
	setmetatable( t, t );
	return t;
end

function CBHighlight()
	local t = {
		Name = "CBHighlight";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = { THEME:GetString('OptionNames','Off'),'On'};
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight
			if pref then
				list[2] = true;
			else
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			value = list[2]
			playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end;
	};
	setmetatable( t, t );
	return t;
end

--unused
--[[
function Avatars()
	local directory = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/")
	local t = {
		Name = "Avatars";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = directory;
		LoadSelections = function(self, list, pn)
			local profile = PROFILEMAN:GetProfile(pn)
			local GUID = profile:GetGUID()
			local pref = themeConfig:get_data().avatar[GUID]
			local found = false
			for i=1,#list do
				if pref == directory[i] then
					list[i] = true
					found = true
				end;
			end;
			if not found then
				list[1] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local profile = PROFILEMAN:GetProfile(pn)
			local GUID = profile:GetGUID()
			local value
			local found = false
			for i=1,#list do
				if not found then
					if list[i] == true then
						local value = directory[i];
						themeConfig:get_data().avatar[GUID] = value
						found = true
					end
				end
			end
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	
--]]

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

function EvalBGType()
	local t = {
		Name = "EvalBGType";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Song Background","Clear+Grade Background","Grade Background only"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().eval.SongBGType
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
			themeConfig:get_data().eval.SongBGType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	

function Particles()
	local t = {
		Name = "Particles";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.Particles
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
			themeConfig:get_data().global.Particles = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	


function RateSort()
	local t = {
		Name = "RateSort";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.RateSort
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
			themeConfig:get_data().global.RateSort = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	

function HelpMenu()
	local t = {
		Name = "HelpMenu";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.HelpMenu
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
			themeConfig:get_data().global.HelpMenu = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	

function NPSWindow()
	local t = {
		Name = "NPSWindow";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = {"1","2","3","4","5"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().NPSDisplay.MaxWindow
			if pref then
				list[pref] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			for k,v in ipairs(list) do
				if v then
					value = k
				end;
			end;
			themeConfig:get_data().NPSDisplay.MaxWindow = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end