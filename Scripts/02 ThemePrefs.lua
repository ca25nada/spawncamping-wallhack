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