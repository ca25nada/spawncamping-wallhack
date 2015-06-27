--Help overlay

local enabled = false -- is the overlay currently enabled?
local show = true -- whether to show after a certain amount of time as passed
local showTime = 5 --the "certain amount of time" from above in seconds
local curTime = GetTimeSinceStart() -- current time
local lastTime = GetTimeSinceStart() -- last input time


local function input(event)
	if event.type ~= "InputEventType_Release" then
		lastTime = GetTimeSinceStart()
		if event.DeviceInput.button == "DeviceButton_F12" then
			if not enabled then
				MESSAGEMAN:Broadcast("ShowHelpOverlay")
				enabled = true
			else
				MESSAGEMAN:Broadcast("HideHelpOverlay")
				enabled = false
			end;
		else
			MESSAGEMAN:Broadcast("HideHelpOverlay")
			enabled = false
		end;
	end;
	return false;
end

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	curTime = GetTimeSinceStart()
	if (not enabled) and (curTime-lastTime > showTime) then
		MESSAGEMAN:Broadcast("ShowHelpOverlay")
		enabled = true
	end;
	--self:GetChild("Timer"):playcommand("Set")
end; 

local t = Def.ActorFrame{
	InitCommand=cmd(SetUpdateFunction,Update);
	OnCommand=function(self) self:diffusealpha(0) SCREENMAN:GetTopScreen():AddInputCallback(input) end;
	ShowHelpOverlayMessageCommand=cmd(smooth,0.3;diffusealpha,0.8);
	HideHelpOverlayMessageCommand=cmd(smooth,0.3;diffusealpha,0);
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,0;halign,0;valign,0;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,color("#333333"););
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,0,35;halign,0;valign,1;zoomto,SCREEN_WIDTH/2,4;faderight,1;);
};

t[#t+1] = LoadFont("Common Large")..{
	InitCommand=cmd(xy,5,32;halign,0;valign,1;zoom,0.55;settext,"Help Menu:";);
};
	
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,5,SCREEN_HEIGHT-15;halign,0;valign,1;zoom,0.35;settext,"Press any key to hide this overlay.";);
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,5,SCREEN_HEIGHT-5;halign,0;valign,1;zoom,0.35;settext,"You can disable this overlay showing up automatically in Theme Options, but it can still be accessed by pressing F12.");
};

--[[ --debug
t[#t+1] = LoadFont("Common Large")..{
	Name="Timer";
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y+80;settext,"0.0");
	SetCommand=function(self)
		self:settextf("%0.2f %s",curTime-lastTime,tostring(curTime-showTime > lastTime))
	end;
};
--]]

return t