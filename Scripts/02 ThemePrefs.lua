-- StepMania 5 Default Theme Preferences Handler
local function OptionNameString(str)
	return THEME:GetString('OptionNames',str)
end

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

function MeasureLines()
	local t = {
		Name = "MeasureLines";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.MeasureLines
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
			themeConfig:get_data().global.MeasureLines = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end;
	};
	setmetatable( t, t );
	return t;
end

function ProgressBar()
	local t = {
		Name = "ProgressBar";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","Bottom", "Top",};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.ProgressBar
			if pref then
				list[pref+1] = true
			end;
		end;
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 0
			elseif list[2] == true then
				value = 1
			else
				value = 2;
			end;
			themeConfig:get_data().global.ProgressBar = value;
			themeConfig:set_dirty();
			themeConfig:save();
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

function SongPreview()
	local t = {
		Name = "SongPreview";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = {"SM Style","osu! Style (Current)","osu! Style (Old)"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SongPreview
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
			themeConfig:get_data().global.SongPreview = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end;
	};
	setmetatable( t, t );
	return t;
end

function BannerWheel()
	local t = {
		Name = "BannerWheel";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.BannerWheel
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
			themeConfig:get_data().global.BannerWheel = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end;
	};
	setmetatable( t, t );
	return t;
end

function BareBone()
	local t = {
		Name = "BareBone";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = true;
		ExportOnChange = true;
		Choices = { "Off","On"};
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.BareBone
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
			themeConfig:get_data().global.BareBone = value
			themeConfig:set_dirty()
			themeConfig:save()
		end;
	};
	setmetatable( t, t );
	return t;
end	