--Help overlay

--Something relevant from the consensual thread heh...
--"10. If you leave it alone for a few seconds it pops up a screen with stupid-high amounts of unhelpful gibberish"

local enabled = false -- is the overlay currently enabled?
local show = true -- whether to show after a certain amount of time as passed
local showTime = 30 --the "certain amount of time" from above in seconds
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
	ShowHelpOverlayMessageCommand=cmd(stoptweening;smooth,0.3;diffusealpha,0.8);
	HideHelpOverlayMessageCommand=cmd(stoptweening;smooth,0.3;diffusealpha,0);
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
	InitCommand=cmd(xy,5,SCREEN_HEIGHT-5;halign,0;valign,1;zoom,0.35;settext,"You can disable this overlay showing up automatically in Theme Options, but it can still be accessed by pressing F12. (oop i lied.. ya can't.... for now)");
};

--have these strings in a separate file...?
local stringList1 = {
	[1] = "Keys/Buttons/Actions",
	[2] = "1~5",
	[3] = "Doubletap <Select> or Clicking on avatar",
	[4] = "F12",
	[5] = "<EffectUp>",
	[6] = "<EffectDown>",
	[7] = "<EffectUp> while Holding <Select>",
	[8] = "<EffectDown> while Holding <Select>",
}

local stringList2 = {
	[1] = "Functions",
	[2] = "Switch to the corresponding tab. (e.g. 3=score, 4=profile, etc.)",
	[3] = "Open avatar switch overlay",
	[4] = "Open help overlay",
	[5] = "While the Score tab is selected, Selects the previous saved score.",
	[6] = "While the Score tab is selected, Selects the next saved score.",
	[7] = "While the Score tab is selected, Selects the next available rate when possible.",
	[8] = "While the Score tab is selected, Selects the previous available rate when possible.",
}
local function makeText(index)
	local t = Def.ActorFrame{}
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,5,50+(15*(index-1));zoom,0.4;halign,0;maxwidth,170/0.4);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList1[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,180,50+(15*(index-1));zoom,0.4;halign,0;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(stringList2[index])
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
	};
	return t
end;

--[[ --debug
t[#t+1] = LoadFont("Common Large")..{
	Name="Timer";
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y+80;settext,"0.0");
	SetCommand=function(self)
		self:settextf("%0.2f %s",curTime-lastTime,tostring(curTime-showTime > lastTime))
	end;
};
--]]

for i=1,#stringList1 do
	t[#t+1] = makeText(i)
end;
return t