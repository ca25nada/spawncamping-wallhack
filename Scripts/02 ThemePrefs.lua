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
		ExportOnChange = false,
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
			local pName = ToEnumShortString(pn)
			if ReadPrefFromFile("GhostTarget"..pName) ~= nil then
				local loadval = GetUserPrefN("GhostTarget"..pName)+1;
				list[loadval] = true;
			else
				WritePrefToFile("GhostTarget"..pName,"1");
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local found = false
			for i=1,#list do
				if not found then
					if list[i] == true then
						local val = i-1;
						local pName = ToEnumShortString(pn)
						WritePrefToFile("GhostTarget"..pName,val);
						found = true
					end
				end
			end
			MESSAGEMAN:Broadcast("PreferenceSet", { Message == "Set Preference" } );
			--THEME:ReloadMetrics();
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
			local pName = ToEnumShortString(pn)
			if ReadPrefFromFile("ErrorBar"..pName) ~= nil then
				if GetUserPref("ErrorBar"..pName) == "1" then
					list[2] = true;
				else
					list[1] = true;
				end;
			else
				WritePrefToFile("ErrorBar"..pName,"0");
				list[1] = true;
			end;
		end;
		SaveSelections = function(self, list, pn)
			local val;
			local pName = ToEnumShortString(pn)
			if list[2] then
				val = "1";
			else
				val = "0";
			end;
			WritePrefToFile("ErrorBar"..pName,val);
			MESSAGEMAN:Broadcast("PreferenceSet", { Message == "Set Preference" } );
			--THEME:ReloadMetrics();
		end;
	};
	setmetatable( t, t );
	return t;
end	