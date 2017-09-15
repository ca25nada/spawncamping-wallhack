local t = Def.ActorFrame{}
local circleRadius = 100
local maxValue = 30
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = PROFILEMAN:GetProfile(pn)
local frameWidth = 300
local frameHeight = 270


local SkillSets = {
	"Stream", 
	"Jumpstream", 
	"Handstream", 
	"Stamina",
	"JackSpeed",
	"JackStamina",
	"Technical"
}

local SkillSetsShort = {
	"Stream", 
	"JS", 
	"HS", 
	"Stam",
	"Jack Speed",
	"Jack Stam",
	"Tech"
}


-- Angle in degrees
local function getPointOffset(distance, angle)
	local rad = math.rad(angle)
	return math.cos(rad)*distance, math.sin(rad)*distance
end

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:zoomto(frameWidth,frameHeight)
		self:diffuse(color(colorConfig:get_data().main.frame)):diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(-frameWidth/2+5, -frameHeight/2+10)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settext("SSR Breakdown")
	end;
}

local sepAngle = 360/#SkillSets-1
local verts = {}
local maxVerts = {}
local x,y
local ssr

local function makeSSRPoints(i)
	local x,y = getPointOffset(circleRadius,sepAngle*(i-1)-90)
	local ssr = profile:GetPlayerSkillsetRating(SkillSets[i])
	verts[#verts+1] = {{x*math.min(1,ssr/maxValue),y*math.min(1,ssr/maxValue),0},color(colorConfig:get_data().main.highlight)}
	verts[#verts+1] = {{0,0,0},color("#FFFFFF")}
	maxVerts[#maxVerts+1] = {{x,y,0},color("#FFFFFF66")}
	maxVerts[#maxVerts+1] = {{0,0,0},color("#FFFFFF66")}

	if i == #SkillSets then
		verts[#verts+1] = verts[1]
		verts[#verts+1] = {{0,0,0},color("#FFFFFF")}

		maxVerts[#maxVerts+1] = maxVerts[1]
		maxVerts[#maxVerts+1] = {{0,0,0},color("#FFFFFF66")}
	end

	local t = Def.ActorFrame{}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(x,y)
			self:zoom(0.3)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settextf("%s\n%0.2f",SkillSets[i], ssr)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand  = function(self)
			self:easeOut(1)
			self:xy(x*math.min(1,ssr/maxValue),y*math.min(1,ssr/maxValue))
			self:zoomto(2,2)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
	}

	return t
end

for i=1, #SkillSets do
	t[#t+1] = makeSSRPoints(i)
end

t[#t+1] = Def.ActorMultiVertex{
	Name= "SSR_MAX_Graph";
	InitCommand = function(self)
		self:SetDrawState{First= 1, Num= -1}
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
		self:queuecommand("Set")
	end;
	SetCommand = function(self)
		self:diffusealpha(0.2)
		self:SetVertices(maxVerts)
		self:SetDrawState{First= 1, Num= -1}
	end;
}

t[#t+1] = Def.ActorMultiVertex{
	Name= "SSR_Graph";
	InitCommand = function(self)
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
		self:queuecommand("Set")
	end;
	SetCommand = function(self)
		self:diffusealpha(0.5)
		self:easeOut(1)
		self:SetVertices(verts)
		self:SetDrawState{First= 1, Num= -1}
	end;
}

return t