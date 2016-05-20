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

	t[#t+1] = Def.ActorFrame{
		Name="MouseXY";
		Def.Sprite {
			OnCommand=cmd(finishtweening;smooth,0.5;diffusealpha,0;queuecommand,"ModifySongBackground");
			CurrentSongChangedMessageCommand=cmd(finishtweening;smooth,0.5;diffusealpha,0;sleep,0.35;queuecommand,"ModifySongBackground");
			ModifySongBackgroundCommand=function(self)
				self:finishtweening()
				if GAMESTATE:GetCurrentSong() then
					local song = GAMESTATE:GetCurrentSong();
					if song:HasBackground() then
						self:visible(true);
						self:LoadBackground(song:GetBackgroundPath());

						if moveBG then
							self:scaletocover(0-maxDistY/8,0-maxDistY/8,SCREEN_WIDTH+maxDistX/8,SCREEN_BOTTOM+maxDistY/8);
						else
							self:scaletocover(0,0,SCREEN_WIDTH,SCREEN_BOTTOM);
						end;

						self:smooth(0.5)
						self:diffusealpha(brightness)
					end;
				else
					self:visible(false);
				end;
			end;
			OffCommand=cmd(smooth,0.5;diffusealpha,0)	
		};
	}
end;

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
    self:GetChild("MouseXY"):xy(getPosX()-SCREEN_CENTER_X,getPosY()-SCREEN_CENTER_Y)
end; 
if moveBG then
	t.InitCommand=cmd(SetUpdateFunction,Update);
end;

return t
