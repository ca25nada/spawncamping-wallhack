local t = Def.ActorFrame{}


--DO NOT REMOVE
t[#t+1] = Def.Actor{
	BeginCommand=function(self)
		resetTabIndex()
	end;
	CodeMessageCommand=function(self,params)
		if params.Name == "SwitchTab" then
			incrementTabIndex()
		end;
	end;
	PlayerJoinedMessageCommand=function(self)
		resetTabIndex()
	end;
}

-- Just for debug
--[[
t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,300,300;halign,0;zoom,2;diffuse,getMainColor(2));
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		self:settext(getTabIndex())
	end;
	CodeMessageCommand=cmd(queuecommand,"Set");
};
--]]
--======================================================================================

tabNames = {"General","Simfile","Score","Profile","Other"}

local frameWidth = (SCREEN_WIDTH*(403/854))/(#tabNames-1)
local frameX = frameWidth/2
local frameY = SCREEN_HEIGHT-70

function tabs(index)
	return Def.ActorFrame{
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:finishtweening()
			self:linear(0.1)
			--show tab if it's the currently selected one
			if getTabIndex() == index-1 then
				self:y(0)
				self:diffusealpha(1)
			else -- otherwise "Hide" them
				self:y(5)
				self:diffusealpha(0.9)
			end;
		end;
		CodeMessageCommand=cmd(queuecommand,"Set");
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");

		Def.Quad{
			InitCommand=cmd(xy,frameX+((index-1)*frameWidth),frameY;valign,0;zoomto,frameWidth,20);
		};
		
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,frameX+((index-1)*frameWidth),frameY+4;valign,0;zoom,0.45;diffuse,getMainColor(1));
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:settext(tabNames[index])
				if isTabEnabled(index) then
					self:diffuse(getMainColor(1))
				else
					self:diffuse(color("#666666"))
				end;
			end;
			PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
		};
	};
end;

--Make tabs
for i=1,#tabNames do
	t[#t+1] =tabs(i)
end;

return t