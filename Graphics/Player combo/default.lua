local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local c
local player = Var "Player"


local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt")
local Pulse = function(self, param)
	self:stoptweening()
	self:zoom(1.125 * param.Zoom * MovableValues.ComboZoom)
	self:linear(0.05)
	self:zoom(param.Zoom * MovableValues.ComboZoom)
end

local PulseLabel = function(self, param)
	self:stoptweening()
	self:zoom(param.LabelZoom * MovableValues.ComboZoom)
	self:linear(0.05)
	self:zoom(param.LabelZoom * MovableValues.ComboZoom)
end

local NumberMinZoom = 0.4 -- 1 is 100% size zoom
local NumberMaxZoom = 0.5 -- 1 is 100% size zoom
local NumberMaxZoomAt = 100 -- the combo to be at max zoom
local numberCurrentZoom = NumberMinZoom -- keep track of current zoom for arbitraryfunction

local LabelMinZoom = 0.75 * 0.75 -- 1 is 100% size zoom
local LabelMaxZoom = 0.75 * 0.75

local function arbitraryComboX(value) 
	c.Label:x(value) 
	c.Number:x(value - 4)
	c.Border:x(value)
  end 

local function arbitraryComboZoom(value)
	c.Label:zoom(value * LabelMaxZoom)
	c.Number:zoom(value * numberCurrentZoom)
	if allowedCustomization then
		c.Border:playcommand("ChangeWidth", {val = c.Number:GetZoomedWidth() + c.Label:GetZoomedWidth()})
		c.Border:playcommand("ChangeHeight", {val = c.Number:GetZoomedHeight()})
	end
end

local t = Def.ActorFrame {

	LoadFont( "Combo", "numbers" ) .. {
		Name="Number",
		InitCommand = function(self)
			self:xy(MovableValues.ComboX - 4, MovableValues.ComboY):halign(1):valign(1):skewx(-0.125):visible(
				false
			)
		end,
		OnCommand = function(self)
			self:shadowlength(1):halign(1):valign(1):skewx(-0.125)
		end
	},
	LoadFont("Common Normal") .. {
		Name="Label",
		InitCommand = function(self)
			self:xy(MovableValues.ComboX, MovableValues.ComboY):diffusebottomedge(color("0.75,0.75,0.75,1")):halign(0):valign(
				1
			):visible(false)
		end,
		OnCommand = function(self)
			self:shadowlength(1):diffusebottomedge(color("0.75,0.75,0.75,1")):halign(0):valign(1)
		end
	},
	InitCommand = function(self)
		c = self:GetChildren()
		c.Number:visible(false)
		c.Label:visible(false)
		self:valign(1)
		self:draworder(350)
		if (allowedCustomization) then
			Movable.DeviceButton_3.element = c
			Movable.DeviceButton_4.element = c
			Movable.DeviceButton_3.condition = true
			Movable.DeviceButton_4.condition = true
			Movable.DeviceButton_3.Border = self:GetChild("Border")
			Movable.DeviceButton_3.DeviceButton_left.arbitraryFunction = arbitraryComboX 
			Movable.DeviceButton_3.DeviceButton_right.arbitraryFunction = arbitraryComboX 
			Movable.DeviceButton_4.DeviceButton_up.arbitraryFunction = arbitraryComboZoom
			Movable.DeviceButton_4.DeviceButton_down.arbitraryFunction = arbitraryComboZoom
		end
	end,
	OnCommand = function(self)
		if (allowedCustomization) then
			c.Label:settext("COMBO")
			c.Number:visible(true)
			c.Label:visible(true)
			c.Number:settext(1000)
			Movable.DeviceButton_3.propertyOffsets = {self:GetTrueX() -6, self:GetTrueY() + c.Number:GetHeight()*1.5}	-- centered to screen/valigned
			setBorderAlignment(c.Border, 0.5, 1)
		end
		arbitraryComboZoom(MovableValues.ComboZoom)
	end,

	ComboCommand = function(self, param)
		local iCombo = param.Misses or param.Combo
		if not iCombo or iCombo < ShowComboAt then
			c.Number:visible(false)
			c.Label:visible(false)
			return
		end

		local labeltext = ""
		if param.Combo then
			labeltext = "COMBO"
		else
			labeltext = "MISSES"
		end

		c.Label:settext( labeltext )

		param.Zoom = scale( iCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom )
		param.Zoom = clamp( param.Zoom, NumberMinZoom, NumberMaxZoom )
		
		param.LabelZoom = scale( iCombo, 0, NumberMaxZoomAt, LabelMinZoom, LabelMaxZoom )
		param.LabelZoom = clamp( param.LabelZoom, LabelMinZoom, LabelMaxZoom )
		
		c.Number:visible(true)
		c.Label:visible(true)

		c.Number:settext( string.format("%i", iCombo) )
		-- FullCombo Rewards
		if param.FullComboW1 then
			c.Number:diffuse(color("#00aeef"))
			c.Number:glowshift()
		elseif param.FullComboW2 then
			c.Number:diffuse(color("#fff568"))
			c.Number:glowshift()
		elseif param.FullComboW3 then
			c.Number:diffuse(color("#a4ff00"))
			c.Number:stopeffect()
		elseif param.Combo then
			c.Number:diffuse(Color("White"))
			c.Number:stopeffect()
			c.Label:diffuse(Color("White")):diffusebottomedge(color("0.5,0.5,0.5,1"))
		else
			c.Number:diffuse(color("#ff0000"))
			c.Number:stopeffect()
			c.Label:diffuse(Color("Red")):diffusebottomedge(color("0.5,0,0,1"))
		end
		-- Pulse
		Pulse( c.Number, param )
		PulseLabel( c.Label, param )
		numberCurrentZoom = param.Zoom
	end,
	MovableBorder(0, 0, 1, MovableValues.ComboX, MovableValues.ComboY)
}

return t
