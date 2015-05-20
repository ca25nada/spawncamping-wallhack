local t = Def.ActorFrame{}

local enabled = themeConfig:get_data().global.Particles

local particleAmount = 30
local particleSize = 3

function isInScreen(particle)
	local half = particleSize/2
	local x = particle:GetX()
	local y = particle:GetY()
	return (x > 0-half and x < SCREEN_WIDTH+half) and (y > 0-half and y < SCREEN_HEIGHT+half)
end;

function resetPosition(particle)
	particle:x(math.random(0,SCREEN_WIDTH))
	--particle:y(0)
	particle:y(math.random(0,SCREEN_HEIGHT))
	particle:rotationz(math.random()*360)
	return
end;

function makeParticle(index,x,y,size,direction)
	return Def.Quad{
		Name="Particle"..index;
		InitCommand=cmd(xy,x,y;zoomto,size,size;rotationz,direction);
		BeginCommand=cmd(diffusealpha,0;smooth,1;diffusealpha,0.5;diffuseshift;effectoffset,(0.1*index);effectcolor1,color("#FFFFFF");effectcolor2,Alpha(getMainColor(1),0.8);effectperiod,1);
	};
end;

if enabled then
	for i=1,particleAmount do
		t[#t+1] = makeParticle(i,math.random(0,SCREEN_WIDTH),math.random(0,SCREEN_HEIGHT),particleSize,math.random()*360);
	end;
end;

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	for i=1,particleAmount do
		local particle = self:GetChild("Particle"..i)
		particle:addrotationz((math.random()*0.2)-0.1);
		particle:addx(math.cos(particle:GetRotationZ())*(3))
		--particle:addy(math.random()*2+1)
		particle:addy(math.sin(particle:GetRotationZ())*(3))
		if not isInScreen(particle) then
			resetPosition(particle)
		end;
	end;
end; 
if enabled then
	t.InitCommand=cmd(SetUpdateFunction,Update);
end;


return t