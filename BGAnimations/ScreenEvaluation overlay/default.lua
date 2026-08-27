local t = Def.ActorFrame{}
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)
local steps = GAMESTATE:GetCurrentSteps()


t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_mouse", "ScreenEvaluation")

--Group folder name
local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH-10
local frameY = 10

t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end,
	OnCommand = function(self)
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
	end,
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end,
	Def.Quad{
		InitCommand=function(self)
			self:halign(1):zoomto(frameWidth,frameHeight):diffuse(getMainColor('highlight')):diffusealpha(0.8)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:x(-frameWidth+5):halign(0):zoom(0.45):maxwidth((frameWidth-10)/0.45)
		end,
		BeginCommand=function(self)
			self:diffuse(color(colorConfig:get_data().main.headerFrameText))
			local song = GAMESTATE:GetCurrentSong()
			if song ~= nil then
				self:settext(song:GetGroupName())
			end
		end
	}
}

t[#t+1] = LoadActor("../_cursor")


return t