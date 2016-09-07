local t = {}

local function ScreenFilter()
	return Def.Quad{
		InitCommand = function(self)
			self:visible(false)
		end;
		PlayerStateSetCommand = function(self,param)
			local pn = param.PlayerNumber
			local style = GAMESTATE:GetCurrentStyle(pn)
			local filterColor = color(colorConfig:get_data().gameplay.ScreenFilter)
			local filterAlpha = playerConfig:get_data(pn).ScreenFilter
			if filterAlpha == 0 then
				self:visible(false)
				return
			end
			self:visible(true)
			self:SetHeight(4096)
			self:diffuse(filterColor)
			self:diffusealpha(filterAlpha)
		end;
		WidthSetCommand = function(self,param)
			self:SetWidth(param.width)
		end;
	}
end

local function FullCombo()
	local style = GAMESTATE:GetCurrentStyle()
	local cols = style:ColumnsPerPlayer()
	local text = {'F','u','l','l',' ','C','o','m','b','o'} -- RIP
	local leamtokem = {28,20,14,14,16,32,36,36,30,30} -- THIS IS DUMB BUT WHATEVER
	local totalSpacing = 226 -- sun of above minus the last element.
	local barCount = cols*4
	local barHeight = 150
	local barWidth = 5
	local pn
	local randMagnitude = 0.3
	local zoom = 0.6

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:y(-SCREEN_CENTER_Y)
		end;
		PlayerStateSetCommand = function(self, param)
			pn = param.PlayerNumber
		end
	}

	-- Main fade-in gradient 
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:visible(false)
			self:y(SCREEN_BOTTOM*2)
			self:valign(1)
			self:fadetop(1)
			self:fadebottom(1)
			self:diffusealpha(0):diffuse(getMainColor('highlight'))
		end;
		WidthSetCommand = function(self, param)
			self:SetWidth(param.width)
		end;
		FullComboMessageCommand=function(self,param)
			if param.pn == pn then
				self:sleep(0.2)
				self:visible(true)
				self:diffusealpha(1)
				self:linear(1)
				self:diffusealpha(0)
				self:zoomy(SCREEN_HEIGHT*4)
			end
		end;
	}

	-- Random flying bar thing
	for i=1,barCount do
		t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:visible(false)
			self:valign(1)
			self:zoomto(barWidth,barHeight-math.random()*100)
			self:fadetop(0.5)
			self:fadebottom(0.5)
			self:fadeleft(0.2)
			self:faderight(0.2)
			self:diffusealpha(0)
		end;
		WidthSetCommand = function(self, param)
			self:x(-(param.width/2)+math.random(param.width)):y(SCREEN_BOTTOM+barHeight+400*math.random())
		end;
		FullComboMessageCommand=function(self,params)		
			if params.pn == pn then
				self:sleep(0.1)
				self:visible(true)
				self:diffusealpha(0.4)
				self:accelerate(2)
				self:diffusealpha(0)
				self:y((-SCREEN_HEIGHT)-(SCREEN_HEIGHT*math.random()*10))
			end
		end;
	}	
	end

	-- HAND KERNED TEXT
	for i=1,#text do
		t[#t+1] = LoadFont("Common Large") .. {
			InitCommand=function(self)
				local spacing = 0
				if i>1 then
					for j=1,i-1 do
						spacing = leamtokem[j]+spacing
					end
				end
				self:visible(false)
				self:settext(text[i])
				if i>1 then
					self:x((-totalSpacing/2)*zoom + spacing*zoom)
				else
					self:x((-totalSpacing/2)*zoom)
				end
				self:zoom(zoom)
				self:diffusealpha(0)
			end;
			FullComboMessageCommand=function(self,params)
				if params.pn == pn then
					--SCREENMAN:SystemMessage("FC")
					local random = math.random()*randMagnitude
					self:sleep(0.20+random)
					self:visible(true)
					self:y(SCREEN_BOTTOM-(400*math.random()))
					self:diffusealpha(0.0)
					self:decelerate(0.5-random)
					random = math.random()*randMagnitude
					self:y(SCREEN_CENTER_Y)
					self:diffusealpha(1)
					self:sleep(0.3)
					self:accelerate(0.6-random)
					self:diffusealpha(0.0)
				end
			end;
		}
	end

	return t
end

--returns 0 if top, 1 if bottom
local function getNoteCoverDirection(coverType,reverse)
	if coverType then 
		if reverse then
			return coverType-1
		else
			return 2-coverType
		end
	end
end

local function LaneCover()
	local pn
	local height = 0
	local reverse = false
	local coverType
	local direction

	local move = 0

	local t = Def.ActorFrame{
		PlayerStateSetCommand=function(self, param)
			pn = param.PlayerNumber
			coverType = playerConfig:get_data(pn).LaneCover
			height = playerConfig:get_data(pn).LaneCoverHeight
			direction = getNoteCoverDirection(coverType,reverse)

			if coverType == 0 then
				self:visible(false)
			else
				self:visible(true)
			end
			self:draworder(playerConfig:get_data(pn).LaneCoverLayer)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:SetHeight(4096)
			self:diffuse(color(colorConfig:get_data().gameplay.LaneCover))
		end;
		OnCommand=function(self)
			self:queuecommand("Set")
		end;
		SetCommand=function(self)
			height = height + move
			direction = getNoteCoverDirection(coverType,reverse)
			if direction == 0 then
				self:valign(1)
				self:y(-SCREEN_CENTER_Y+height)
			else
				self:valign(0)
				self:y(SCREEN_CENTER_Y-height)
			end
			self:sleep(0.01)
			if move ~= 0 then
				SCREENMAN:SystemMessage(string.format("%s's LaneCover Height Set to %d",PROFILEMAN:GetPlayerName(pn),height))
				self:queuecommand("Set") -- Keep updating until player lifted keys
			end
		end;
		WidthSetCommand=function(self, param)
			self:SetWidth(param.width)
		end;
		ReverseChangedMessageCommand=function(self, param)
			reverse = (param.sign == -1)
			self:queuecommand("Set")
		end;
		CodeMessageCommand=function(self, param)
			-- Do not move if the lanecover isn't even enabled.
			if playerConfig:get_data(pn).LaneCover == 0 then
				return
			end
			if param.PlayerNumber == pn then
				if param.Name == "LaneUp" then
					if direction == 0 then
						move = -1
					else
						move = 1
					end
				elseif param.Name == "LaneDown" then
					if direction == 0 then
						move = 1
					else
						move = -1
					end
				else -- Player lifted the keys
					move = 0
					self:queuecommand("Save")
				end
			end
			self:playcommand("Set")
		end;
		SaveCommand=function(self)
			playerConfig:get_data(pn).LaneCoverHeight = height
			playerConfig:set_dirty(pn)
			playerConfig:save(pn)
		end;
	}
	return t
end


t[#t+1] = ScreenFilter()
t[#t+1] = FullCombo()
t[#t+1] = LaneCover()
return t