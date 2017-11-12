local t = Def.ActorFrame{};

t[#t+1] = LoadFont("Common Normal") .. {
	Name = "currentTime";
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_BOTTOM-75):zoom(0.45):settext("")
	end;
};

local function Update(self)
	local year = Year()
	local month = MonthOfYear()+1
	local day = DayOfMonth()
	local hour = Hour()
	local minute = Minute()
	local second = Second()
	self:GetChild("currentTime"):settextf("%04d-%02d-%02d %02d:%02d:%02d",year,month,day,hour,minute,second)
end;

t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end	

return t