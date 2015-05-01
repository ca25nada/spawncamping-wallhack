local magnitude = 0.03
local maxDistX = SCREEN_WIDTH*magnitude
local maxDistY = SCREEN_HEIGHT*magnitude

local enabled = themeConfig:get_data().global.SongBGEnabled and not(GAMESTATE:IsCourseMode())
local moveBG = themeConfig:get_data().global.SongBGMouseEnabled and enabled
local brightness = 0.3

local function getPosX()
	local offset = magnitude*(INPUTFILTER:GetMouseX()-SCREEN_CENTER_X)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),maxDistX)
		end;
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),maxDistX)
		end;
	end;
	if neg then
		return SCREEN_CENTER_X+offset
	else 
		return SCREEN_CENTER_X-offset
	end;
end

local function getPosY()
	local offset = magnitude*(INPUTFILTER:GetMouseY()-SCREEN_CENTER_Y)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),maxDistY)
		end;
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),maxDistY)
		end;
	end;
	if neg then
		return SCREEN_CENTER_Y+offset
	else 
		return SCREEN_CENTER_Y-offset
	end;
end

local t = Def.ActorFrame{}
if enabled then
	t[#t+1] = Def.Sprite {
		Name="MouseXY";
		CurrentSongChangedMessageCommand=cmd(finishtweening;smooth,0.5;diffusealpha,0;sleep,0.35;queuecommand,"ModifySongBackground");
		--BeginCommand=cmd(scaletocover,0,0,SCREEN_WIDTH+maxDistX/4,SCREEN_BOTTOM+maxDistY/4;diffusealpha,0.3;);
		ModifySongBackgroundCommand=function(self)
			if GAMESTATE:GetCurrentSong() then
				if GAMESTATE:GetCurrentSong():GetBackgroundPath() then
					self:visible(true);
					self:LoadBackground(GAMESTATE:GetCurrentSong():GetBackgroundPath());
					if moveBG then
						self:scaletocover(0-maxDistY/8,0-maxDistY/8,SCREEN_WIDTH+maxDistX/8,SCREEN_BOTTOM+maxDistY/8);
					else
						self:scaletocover(0,0,SCREEN_WIDTH,SCREEN_BOTTOM);
					end;
					self:sleep(0.25)
					self:smooth(0.5)
					self:diffusealpha(brightness)
				else
					self:visible(false);
				end;
			else
				self:visible(false);
			end;
		end;
		OffCommand=cmd(smooth,0.5;diffusealpha,0)	
	};
end;


local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
    self:GetChild("MouseXY"):xy(getPosX(),getPosY())
end; 
if moveBG then
	t.InitCommand=cmd(SetUpdateFunction,Update);
end;
t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_WIDTH,0;halign,1;valign,0;zoomto,capWideScale(get43size(350),350),SCREEN_HEIGHT;diffuse,color("#33333399"));
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(xy,SCREEN_WIDTH-capWideScale(get43size(350),350),0;halign,0;valign,0;zoomto,4,SCREEN_HEIGHT;diffuse,color("#FFFFFF"));
};



return t
