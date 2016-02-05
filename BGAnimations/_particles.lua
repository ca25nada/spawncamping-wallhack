local t = Def.ActorFrame{}

local enabled = themeConfig:get_data().global.Particles

local particleAmount = 100
local particleSize = 3
local dx = {}
local dy = {}

local function isInScreen(particle)
	local half = particleSize/2
	local x = particle:GetX()
	local y = particle:GetY()
	return (x > -100-half and x < SCREEN_WIDTH+100+half) and (y > 0-half and y < SCREEN_HEIGHT+half)
end;

local function resetPosition(particle)
	particle:x(math.random(0,SCREEN_WIDTH))
	particle:y(0)
	--particle:y(math.random(0,SCREEN_HEIGHT))
	particle:rotationz(math.random()*360)
	return
end;

local function makeParticle(index,x,y,size,direction)
	return Def.Quad{
		Name="Particle"..index;
		InitCommand=cmd(xy,x,y;zoomto,size,size;rotationz,direction);
		BeginCommand=function (self)
			self:y(0)
			self:x(math.random(0,SCREEN_WIDTH))
			self:diffusealpha((math.random()/2)+0.2)
			dx[index] = 0
			dy[index] = math.random()*5+1
			self:sleep(math.random()*10)
			self:queuecommand('Move')
		end;
		MoveCommand = function(self,params)
			self:finishtweening()
			self:addy(dy[index])
			self:addx(dx[index])
			if not isInScreen(self) then
				self:sleep(1)
				self:queuecommand('ResetPosition')
			end;
			self:sleep(1/60)
			self:queuecommand('Move')
		end;
		ResetPositionCommand = function(self)
			self:diffusealpha((math.random()/2)+0.2)
			self:x(math.random(0,SCREEN_WIDTH))
			self:y(0)
			dx[index] = (INPUTFILTER:GetMouseX()-SCREEN_CENTER_X)/200
			dy[index] = math.random()*4+1
			self:queuecommand('Move')
		end;
	};
end;

if enabled then
	for i=1,particleAmount do
		t[#t+1] = makeParticle(i,math.random(0,SCREEN_WIDTH),math.random(0,SCREEN_HEIGHT),particleSize,math.random()*360);
		dx[#dx+1] = 0
		dy[#dy+1] = 0
	end;
end;


return t