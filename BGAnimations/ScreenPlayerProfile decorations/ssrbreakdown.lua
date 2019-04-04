local t = Def.ActorFrame{}
local circleRadius = 100
local maxValue = 30
local softCap = 40/30
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = PROFILEMAN:GetProfile(pn)
local frameWidth = 300
local frameHeight = 310


local SkillSets = {
	"Stream", 
	"Jumpstream", 
	"Handstream", 
	"Stamina",
	"JackSpeed",
	"Chordjack",
	"Technical"
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

t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(-frameWidth/2+5, -frameHeight/2+10)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settext("Skill Rating Breakdown")
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(-frameWidth/2+5, -frameHeight/2+20)
		self:zoom(0.3)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand("Set")
	end,
	SetCommand = function(self)
		if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
			self:settext("Using server values")
		else
			self:settext("Using client values")
		end
	end,

	OnlineUpdateMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	LogOutMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	OnlineTogglePressedMessageCommand = function(self)
		self:queuecommand("Set")
	end
}

local sepAngle = 360/#SkillSets-1
local verts = {}
local maxVerts = {}

local function makeSSRPoints(i)
	return LoadFont("Common Normal")..{
		InitCommand  = function(self)
			local x,y = getPointOffset(circleRadius,sepAngle*(i-1)-90)
			self:xy(x,y)
			self:zoom(0.3)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			local SSR = 0
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				SSR = DLMAN:GetSkillsetRating(SkillSets[i])
			else
				SSR = profile:GetPlayerSkillsetRating(SkillSets[i])
			end

			self:settextf("%s\n%0.2f",SkillSets[i], SSR)
			self:AddAttribute(#SkillSets[i], {Length = -1, Diffuse = getMSDColor(SSR)})
		end,
		OnlineTogglePressedMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		LogOutMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		OnlineUpdateMessageCommand = function(self)
			self:queuecommand("Set")
		end
	}
end


t[#t+1] = Def.ActorMultiVertex{
	Name= "SSR_MAX_Graph",
	InitCommand = function(self)
		local x,y
		for i=1, #SkillSets do
			x,y = getPointOffset(circleRadius,sepAngle*(i-1)-90)

			maxVerts[#maxVerts+1] = {{x,y,0},color("#FFFFFF66")}
			maxVerts[#maxVerts+1] = {{0,0,0},color("#FFFFFF66")}
		end

		maxVerts[#maxVerts+1] = maxVerts[1]
		maxVerts[#maxVerts+1] = {{0,0,0},color("#FFFFFF66")}

		self:SetDrawState{First= 1, Num= -1}
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
		self:playcommand("Set")
	end,
	SetCommand = function(self)
		self:diffusealpha(0.2)
		self:SetVertices(maxVerts)
		self:SetDrawState{First= 1, Num= -1}
	end,
	OnlineUpdateMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	LogOutMessageCommand = function(self)
		self:queuecommand("Set")
	end
}

t[#t+1] = Def.ActorMultiVertex{
	Name= "SSR_Graph",
	InitCommand = function(self)
		self:diffusealpha(0.5)
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
		self:queuecommand("Set")
	end,
	OnlineUpdateMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	LogOutMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	OnlineTogglePressedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	SetCommand = function(self)
		verts = {}
		local x,y
		for i=1, #SkillSets do
			local SSR = 0
			x,y = getPointOffset(circleRadius,sepAngle*(i-1)-90)
			if GHETTOGAMESTATE:getOnlineStatus() == "Online" then
				SSR = DLMAN:GetSkillsetRating(SkillSets[i])
			else
				SSR = profile:GetPlayerSkillsetRating(SkillSets[i])
			end

			verts[#verts+1] = {{x*math.min(softCap,SSR/maxValue),y*math.min(softCap,SSR/maxValue),0},getMSDColor(SSR)}
			verts[#verts+1] = {{0,0,0},color("#FFFFFF")}
		end

		verts[#verts+1] = verts[1]
		verts[#verts+1] = {{0,0,0},color("#FFFFFF")}

		self:finishtweening()
		self:easeOut(1)
		self:SetVertices(verts)
		self:SetDrawState{First= 1, Num= -1}
	end

}

for i=1, #SkillSets do
	t[#t+1] = makeSSRPoints(i)
end

return t