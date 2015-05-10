local moveUp = false
local moveDown = false
local t = Def.ActorFrame{
	CodeMessageCommand = function(self, params)
		moveDown = false
		moveUp = false
		if params.Name == "LaneUp" then
			moveUp = true
		elseif params.Name == "LaneDown" then
			moveDown = true
		else
			moveDown = false
			moveUp = false
		end
	end;
}

local laneType = 0 --0  = off, 1 = notefield only, 2 = full width
local isReverse = 0 -- will be at top if reverse, bottom if not.

local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

local isCentered = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player")) -- load from prefs later
local width = 64*6+8
local height = 0

t[#t+1] = Def.Quad{
	Name="Cover";
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_TOP;zoomto,width,height;valign,0;diffuse,color("#000000"));
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="CoverText";
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_TOP;settext,0;valign,1;)

}


local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	if moveDown then
		height = height+1
		self:GetChild("Cover"):zoomy(height)
		self:GetChild("CoverText"):y(height)
		self:GetChild("CoverText"):settext(height)
		--moveDown = false
	end;
	if moveUp then
		height = height-1
		self:GetChild("Cover"):zoomy(height)
		self:GetChild("CoverText"):y(height)
		self:GetChild("CoverText"):settext(height)
		--moveUp = false
	end;
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


return t