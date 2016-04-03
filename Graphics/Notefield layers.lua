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
			local filterAlpha = playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter
			if filterAlpha == 0 then
				self:visible(false)
				return
			end
			self:visible(true)
			self:SetHeight(SCREEN_HEIGHT*4096)
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

t[#t+1] = ScreenFilter()
t[#t+1] = FullCombo()

return t