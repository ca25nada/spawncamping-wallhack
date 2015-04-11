local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 0 then
			self:queuecommand("On");
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};

t[#t+1] = LoadFont("Common Normal") .. {
	Name = "currentTime";
	InitCommand=cmd(xy,10,50;halign,0;zoom,0.45;);
	};

local function Update(self)
	if update then
		local year = Year()
		local month = MonthOfYear()+1
		local day = DayOfMonth()
		local hour = Hour()
		local minute = Minute()
		local second = Second()
		self:GetChild("currentTime"):settextf("%04d-%02d-%02d %02d:%02d:%02d",year,month,day,hour,minute,second)
	end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update)

return t